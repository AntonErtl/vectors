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
constant quad

create quads max-trace quad * allot
variable nquads max-inputs nquads !
create vects max-trace cells allot
variable ninputs 0 ninputs !
create scalars max-trace 1 cells 1 floats max * allot
variable nscalars 0 nscalars !

350 constant max-cgens
create cgens  max-cgens cells allot
variable ncgens 0 ncgens !

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
    parse-name {: d: n :} parse-name save-mem to t
    :noname ( quadp -- ) ]] binary-c-inputs [[ -1 parse evaluate ]] ; [[
    dup cgens ncgens @ th ! 1 ncgens +! n nextname constant ;

synonym genv-binary-c genv-c
synonym genv-unary-c genv-c
synonym genv-vs-c genv-c
synonym genv-sv-c genv-c

include genc.4th

\ : genv-binary ( xt "name" "replacement" "type" "word" -- )
    