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
field: cgen-xt \ xt of the nameless code generator
cfield: cgen-stype \ scalar type ('r' or 'n')
field: cgen-nt \ nt of the constant with the name of the cgen
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

$3fff constant quad-op-mask     \ operation number
$4000 constant quad-result-mask \ bit is set if the result needs to be written
\ MSB not used here so that the quad fits in 6 base-36 digits on big-endian

: quad-op-cgen ( quad -- cgenp )
    quad-op w@ quad-op-mask and /cgen * cgens + ;

: quad-result ( quad -- f )
    quad-op w@ quad-result-mask and 0<> ;

: set-quad-result ( quad -- )
    quad-op dup w@ quad-result-mask xor swap w! ; 

: current-cgen ( -- cgenp )
    cgens ncgens @ /cgen * + ;

: typer ( c-addr u1 u2 -- )
    tuck umin tuck - >r type r> spaces ;

: cgen. ( cgen -- )
    cgen-nt @ name>string 10 typer ;

: quad. {: qp -- :}
    qp quad-op-cgen cgen.
    qp quad-in1 c@ 3 .r
    qp quad-in2 c@ 3 .r ;

: print-trace ( -- )
    cr ." rscalars:" nrscalars @ 0 ?do
	rscalars i floats + f@ space 7 5 1 f.rdp loop
    cr ." xscalars:" nxscalars @ 0 ?do
	xscalars i th + @ . loop
    max-inputs ninputs @ +do
	cr 17 spaces vects i th @ vect.short ."  :" i 2 .r loop
    nquads @ max-inputs +do
	cr quads i /quad * + quad. space
	vects i th @ vect.short ."  :" i 2 .r loop ;

: in-trace? {: vect -- f :}
    vect vect-traceentry c@ {: u :}
    u ninputs @ nquads @ within if \ check if u is from the current trace
	vects u th @ vect = exit then
    false ;

\ replacement words

: vect-data-alloc ( u -- addr )
    vector-granularity tuck naligned aligned_alloc dup 0= -59 and throw ;

: vect-alloc ( u -- vect )
    /vect allocate throw >r
    dup vect-data-alloc r@ vect-datap !
    [defined] use-refcount [if]
	0 r@ vect-refs !
    [then]
    r@ vect-bytes !
    r> ;

: vect-free {: vect -- :}
    vect if
	vect vect-refs @ assert( dup 0>= ) dup if
	    1- vect vect-refs ! exit then
	drop vect in-trace? ?exit
	vect vect-data free throw vect free throw
    then ;

also c-lib
: >c ( ... xt -- )
    >string-execute 2dup write-c-prefix-line drop free throw ;
previous

\ C code generators for vector words

: binary-c-inputs ( quadp -- n2 n1 )
    \ get input argument numbers (in reverse order)
    dup quad-in2 c@ swap quad-in1 c@ ;

: gen ( c-addr u -- ) \ 2dup type
    type ; \ ]] 2literal type [[ ;

: varg ( n c-addr u -- ) ( generated code: -- )
    "((" gen gen ")v" gen
    0 .r ")" gen ;
: sarg ( n char -- ) ( generated code: -- )
    emit 0 .r ;

0 0 2value t
'x' value s

: genv-c ( "name" "type" "forth-code\n" -- )
    ncgens @ constant latest parse-name save-mem to t 0 ( nt stypef )
    :noname ( quadp -- ) ]] binary-c-inputs [[ -1 parse evaluate ]] ; [[
    current-cgen tuck cgen-xt ! tuck cgen-stype c! cgen-nt ! 1 ncgens +! ;

: genv-vs-c ( "name" "vtype" "stypef" "forth-code\n" -- )
    ncgens @ constant latest parse-name save-mem to t
    parse-name dup assert( 1 = ) drop c@ dup to s
    :noname ( quadp -- ) ]] binary-c-inputs [[ -1 parse evaluate ]] ; [[
    current-cgen tuck cgen-xt ! tuck cgen-stype c! cgen-nt ! 1 ncgens +! ;

synonym genv-binary-c genv-c
synonym genv-unary-c genv-c
synonym genv-sv-c genv-vs-c

include genc.4th

\ code generation for a whole trace

: .n 0 .r ;
\ narrow prining

: trace-name ( -- c-addr u )
    <# [: nquads @ assert( dup max-inputs - 16 cells 6 / <= ) max-inputs ?do
	    quads i /quad * + l@ 0 6 0 do # loop 2drop
	loop ;] #36 base-execute 't' hold 0 0 #> ;

: trace-code {: d: tname -- :}
    \ code generation for the trace
    cr ." void " tname type ." (Vect *vs[], Cell ns[], Float rs[], long bytes) {"
    cr ."   long i;
    max-inputs ninputs @ ?do
	cr ."   vb *pv" i .n ."  = vs[" i .n .\" ]->vect_data; /* printf(\"\\nvs[i]=%p pv" i .n .\" =%p\",vs[" i .n .\" ], pv" i .n ." ); */" loop
    nquads @ max-inputs ?do
	quads i /quad * + quad-result  if
	    cr ."   vb *pv" i .n ."  = vs[" i .n ." ]->vect_data;" then
    loop
    nxscalars @ 0 ?do
	cr ."   Cell n" i .n ."  = ns[" i .n ." ];" loop
    nrscalars @ 0 ?do
	cr ."   Float r" i .n ."  = rs[" i .n ." ];" loop
    cr ."   for (i=0; i*sizeof(vb)<bytes; i++) {"
    max-inputs ninputs @ ?do
	cr ."     vb v" i .n ."  = pv" i .n ." [i];" loop
    nquads @ max-inputs ?do
	cr ."     vb v" i .n ."  = (vb)("
	quads i /quad * + {: q :} q q quad-op-cgen cgen-xt @ execute ." );"
	q quad-result if ."  pv" i .n ." [i] = v" i .n ." ;" then
    loop
    .\" \n  }\n}" ;

: c-code {: d: tname -- :}
    cr ." #define SIMD_SIZE " simd-size dec.
    cr ." #include <stddef.h>"
    cr ." #include <stdlib.h>"
    cr ." #include <stdint.h>"
    cr ." #include <stdio.h>"
    cr ." typedef  int8_t   sb;"
    cr ." typedef uint8_t  sub;"
    cr ." typedef  int16_t  sw;"
    cr ." typedef uint16_t suw;"
    cr ." typedef  int32_t  sl;"
    cr ." typedef uint32_t sul;"
    cr ." typedef  int64_t  sx;"
    cr ." typedef uint64_t sux;"
    cr ." typedef   float  ssf;"
    cr ." typedef   double sdf;"
    cr ." typedef  int8_t   vb __attribute__ ((vector_size (SIMD_SIZE)));" 
    cr ." typedef uint8_t  vub __attribute__ ((vector_size (SIMD_SIZE)));"
    cr ." typedef  int16_t  vw __attribute__ ((vector_size (SIMD_SIZE)));" 
    cr ." typedef uint16_t vuw __attribute__ ((vector_size (SIMD_SIZE)));" 
    cr ." typedef  int32_t  vl __attribute__ ((vector_size (SIMD_SIZE)));" 
    cr ." typedef uint32_t vul __attribute__ ((vector_size (SIMD_SIZE)));" 
    cr ." typedef  int64_t  vx __attribute__ ((vector_size (SIMD_SIZE)));" 
    cr ." typedef uint64_t vux __attribute__ ((vector_size (SIMD_SIZE)));" 
    cr ." typedef   float  vsf __attribute__ ((vector_size (SIMD_SIZE)));" 
    cr ." typedef   double vdf __attribute__ ((vector_size (SIMD_SIZE)));"
    cr ." typedef long Cell;"
    cr ." typedef double Float;"
    cr ." typedef struct {"
    cr ." Cell vect_refs;"
    cr ." Cell vect_bytes;"
    cr ." vb *vect_data;"
    cr ." char vect_traceentry;"
    cr ." } Vect;"
    tname trace-code ;


: current-execute ( wid xt -- )
    \ perform xt while current is wid
    get-current {: old :} swap set-current ~~ catch ~~ old set-current ~~ throw ;

table constant traces \ contains all the chain words generated in this session

also c-lib
: trace-c-function ( tname -- )
    [: 2dup type space type ."  a a a n -- void" ;] >string-execute
    2dup ['] c-function traces ['] execute-parsing current-execute drop free throw ;
previous

: trace-libcc ( -- xt )
    trace-name save-mem {: d: tname :}
    tname traces find-name-in dup 0= if
	drop
	tname ['] c-library execute-parsing
	tname ['] c-code >c
	tname trace-c-function
	end-c-library
	tname traces find-name-in
    then
    name>interpret ;

: finish-trace ( -- )
    nquads @ max-inputs = ?exit
    print-trace
    nquads @ max-inputs +do
	vects i th @ dup vect-refs @ -1 = if
	    dup vect-data free throw free throw
	else
	    assert( dup vect-data 0= )
	    dup vect-bytes @ vect-data-alloc swap vect-datap !
	    quads i /quad * + set-quad-result
	then
    loop
    vects xscalars rscalars trace-bytes @ trace-libcc dup xt-see execute
    max-inputs ninputs @ +do
	vects i th @ dup vect-refs @ -1 = if
	    dup vect-data free throw dup free throw then
	drop loop
    0 nrscalars ! 0 nxscalars ! max-inputs ninputs ! max-inputs nquads ! ;

\ vector word definers

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
    vect in-trace? if
	vect vect-traceentry c@ exit then
    \ otherwise the vector is an input vector for the current trace
    ninputs @ 1- {: u :} assert( u 0>= )
    u ninputs !
    vect vects u th !
    u vect vect-traceentry c!
    u ;

: new-vect ( ubytes utraceentry -- vect )
    /vect allocate throw {: vect :}
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
    vect2 vect-bytes @ bytes <> vectlen-ex and throw
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
    vsp @ @ {: vect1 :}
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
	nrscalars @ dup 1+ nrscalars ! dup floats rscalars + f!
    else
	nxscalars @ dup 1+ nxscalars ! tuck cells  xscalars + !
    then ;

: do-vs ( v1 scalar uop -- v ) {: uop :}
    \ type of scalar determined by cgen-stype
    vsp @ @ {: vect1 :}
    vect1 vect-bytes @ {: bytes :}
    bytes check-bytes
    uop do-scalar {: sindex :}
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