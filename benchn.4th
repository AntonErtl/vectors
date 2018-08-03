\ matrix muliplication overhead benchmark

\ define vectlen before including this:

[undefined] {: [if]
    [undefined] parse-name [if]
	s" extensions/parse-name.fs" included
    [then]
    s" extensions/locals.fs" included
[then]

: init-matrix {: m ncols nrows nstart -- :}
    \ initialize m with floats nstart, nstart+1, ...
    nstart nrows 0 ?do
	ncols 0 ?do
	    dup 0 d>f m j ncols * i + floats + f! 1+
	loop
    loop
    drop ;

50 constant dim
dim dup     * floats allocate throw constant a a dim     dim     1 init-matrix
dim vectlen * floats allocate throw constant b b vectlen dim 30000 init-matrix
dim vectlen * floats allocate throw constant c

: bench
    500 0 do
	a b c dim dim vectlen matmulr
    loop ;
bench
