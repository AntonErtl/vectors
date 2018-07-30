\ chaining

\ trace

\ a trace consists of quadruples.  A quadruple is split into a
\ quad (op and input operands), and the output operand vect.  This
\ split is performed, because only the quad part is looked up in
\ the hash table.

\ real quads start at max-inputs; lower indexes represent input
\ vectors, and just the vects are filled

\ scalar inputs have their own array SCALARS, with their own counter

256 constant max-trace
16 constant max-inputs

0
wfield: quad-op  \ operation and (in high bit) whether output is written
cfield: quad-in1 \ trace index of input operand (0 if unneeded)
cfield: quad-in2 \ trace index of input operand (0 if unneeded)
\ position in trace determines output, vector reference in trace-vects
constant /quad

0
wfield: cgen-xt
cfield: cgen-stype \ scalar type ('r' or 'n')
aligned constant /cgen

create quads max-trace /quad * allot
variable nquads max-inputs nquads ! 
create vects max-trace cells allot \ outputs of corresponding quads (or inputs)
variable ninputs max-inputs ninputs ! \ grows down
create rscalars max-trace floats allot
variable nrscalars 0 nrscalars !
create xscalars max-trace cells allot
variable nxscalars 0 nxscalars !
variable trace-bytes
\ all vectors in a trace must have the same length, so they can be
\ processed in one loop.  But this length is a parameter at run-time
\ (i.e., the code generated for a trace can be used for different
\ vector lengths).

350 constant max-cgens \ xt ( quadp -- ) that outputs C code for a quad
create cgens  max-cgens /cgen * allot
variable ncgens 0 ncgens !

: current-cgen ( -- cgenp )
    cgens ncgens @ /cgen * + ;

\ replacement words

: vect-alloc ( u -- vect )
    /vect allocate throw >r
    vector-granularity 2dup naligned aligned_alloc dup 0= -59 and throw
    r@ vect-datap !
    [defined] use-refcount [if]
	0 r@ vect-refs !
    [then]
    r@ vect-bytes !
    r> ;

: vect-free ( vect -- )
    ?dup-if
	dup vect-refs @ assert( dup 0>= ) dup if
	    1- swap vect-refs ! exit then
	drop dup vect-data free throw free throw
    then ;

\ C code generators for vector words

: binary-c-inputs ( quadp -- n2 n1 )
    \ get input argument numbers (in reverse order)
    dup quad-in2 c@ swap quad-in1 c@ ;

: gen ( c-addr u -- ) \ 2dup type
    type ; \ ]] 2literal type [[ ;

: varg ( n c-addr u -- ) ( generated code: -- )
    "((" gen gen ")v" gen
    0 .r ")" gen ;
: sarg ( n c-addr u -- ) ( generated code: -- )
    "((" gen gen ")s" gen
    0 .r ")" gen ;

0 0 2value t

: genv-c ( "name" "type" "forth-code\n" -- )
    ncgens @ constant parse-name save-mem to t 0
    :noname ( quadp -- ) ]] binary-c-inputs [[ -1 parse evaluate ]] ; [[
    current-cgen tuck cgen-xt ! cgen-stype c! 1 ncgens +! ;

: genv-vs-c ( "name" "vtype" "stypef" "forth-code\n" -- )
    ncgens @ constant parse-name save-mem to t
    parse-name dup assert( 1 = ) drop c@
    :noname ( quadp -- ) ]] binary-c-inputs [[ -1 parse evaluate ]] ; [[
    current-cgen tuck cgen-xt ! cgen-stype c! 1 ncgens +! ;

synonym genv-binary-c genv-c
synonym genv-unary-c genv-c
synonym genv-sv-c genv-vs-c

include genc.4th


\ code generation for a whole trace


\ vector word definers

: finish-trace ( -- ) ;

: check-bytes ( u -- )
    \ check if the length u of the current vector fits with the trace.
    \ If not, finish the trace and start a new one
    trace-bytes @ over = if drop exit then
    nquads @ max-inputs <> if \ there is at least one quad in the trace
	finish-trace then
    trace-bytes ! ;

: consume {: vect -- u :}
    \ reduces the reference count of this vector, and puts it into
    \ vects, if it is not already there.  u is the index of vect in
    \ vects
    assert( vect vect-refs @ 0>= )
    -1 vect vect-refs +!
    scope vect vect-traceentry c@ {: u :}
    u ninputs @ nquads @ within if \ check if u is from the current trace
	vects u th @ vect = if
	    u exit then then \ if so, return it
    endscope
    \ otherwise the vector is an input vector for the current trace
    ninputs @ 1- {: u :} assert( u 0>= )
    u ninputs !
    vect vects u th !
    u vect vect-traceentry c!
    u ;

: new-vect ( ubytes utraceentry -- vect )
    vect allocate throw {: vect :}
    0 vect vect-refs !
    0 vect vect-datap !
    vect vect-traceentry c!
    vect vect-bytes !
    vect ;

: quad! ( op in1 in2 quad -- )
    tuck quad-in2 c!
    tuck quad-in1 c!
    quad-op w! ;

: do-binary ( v1 v2 uop -- v ) {: uop :}
    vsp @ dup @ {: vect2 :} cell+ dup @ {: vect1 :} vsp !
    vect1 vect-bytes @ {: bytes :}
    bytes check-bytes
    vect2 vect-bytes @ <> vectlen-ex and throw
    nquads @ dup {: n :} 1+ nquads !
    uop vect1 consume vect2 consume quads n /quad * + quad!
    bytes n new-vect {: vect :}
    vect vects n th !
    vect vsp @ ! ;

: genv-binary ( "name" "codegen" "type" "word" -- )
    type?exit :
    parse-name find-name name>int execute ]] literal [[ 
    parse-name 2drop parse-name 2drop ]] do-binary ; [[ ;

: do-unary ( v1 uop -- v ) {: uop :}
    vsp @ dup @ {: vect1 :}
    vect1 vect-bytes @ {: bytes :}
    bytes check-bytes
    nquads @ dup {: n :} 1+ nquads !
    uop vect1 consume 0 quads n /quad * + quad!
    bytes n new-vect {: vect :}
    vect vects n th !
    vect vsp @ ! ;

: genv-unary ( "name" "codegen" "type" "word" -- )
    type?exit :
    parse-name find-name name>int execute ]] literal [[ 
    parse-name 2drop parse-name 2drop ]] do-unary ; [[ ;

: do-scalar ( scalar uop -- uindex )
    \ store the scalar in RSCALARS or XSCALARS, depending on type;
    \ uindex is the index into that array.
    /cgen * cgens + cgen-stype c@ assert( dup 'r' = over 'n' = or ) 'r' = if
	nrscalars @ dup 1+ nrscalars ! floats rscalars + f!
    else
	nxscalars @ dup 1+ nxscalars ! cells  xscalars + !
    then ;

: do-vs ( v1 scalar uop -- v ) {: uop :}
    \ type of scalar determined by cgen-stype
    uop do-scalar {: sindex :}
    vsp @ dup @ {: vect1 :}
    vect1 vect-bytes @ {: bytes :}
    bytes check-bytes
    nquads @ dup {: n :} 1+ nquads !
    uop vect1 consume sindex quads n /quad * + quad!
    bytes n new-vect {: vect :}
    vect vects n th !
    vect vsp @ ! ;

: genvs ( "name" "codegen" "type" "word" -- )
    type?exit :
    parse-name find-name name>int execute ]] literal [[ 
    parse-name 2drop parse-name 2drop ]] do-vs ; [[ ;

synonym gensv genvs ( "name" "codegen" "type" "word" -- )