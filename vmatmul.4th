\ matrix multiplication, using the vector wordset

\ Copyright (C) 2017 Anton Ertl

\ This file is part of vectors

\ vectors is free software; you can redistribute it and/or
\ modify it under the terms of the GNU General Public License
\ as published by the Free Software Foundation, either version 3
\ of the License, or (at your option) any later version.

\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\ GNU General Public License for more details.

\ You should have received a copy of the GNU General Public License
\ along with this program. If not, see http://www.gnu.org/licenses/.

include vectors.4th
synonym f*vs df*vs
synonym f+v df+v
[defined] use-vaxpy [defined] use-vaxpy2 or [if]
    require vaxpy.4th
[then]

: mat@ {: vs rows cols f-addr -- :}
    rows 0 ?do
	f-addr i cols * dfloats + cols dfloats b@v vs i th v!
    loop ;

: mat! {: vs rows cols f-addr -- :}
    rows 0 ?do
	vs i th v@' f-addr i cols * dfloats + cols dfloats b!v
    loop ;


[undefined] use-vaxpy [if]
    : f*+vvs ]] f*vs f+v [[ ; immediate
    
: matmulr {: a b c n1 n2 n3 | b1 c1 -- :}
    \ C = A x B, where A has n1 rows and n2 columns,
    \ B has n2 rows and n3 columns, and C has n1 rows and n3 columns
    n2 cells allocate throw to b1 b1 n2 cells erase b1 n2 n3 b mat@
    c n1 n3 * dfloats erase
    n1 cells allocate throw to c1 c1 n1 cells erase c1 n1 n3 c mat@
    n1 0 ?do
	c1 i th dup v@'
	[undefined] use-vaxpy2 [if]
	    n2 0 ?do
		b1 i th v@ a j n2 * i + dfloats + df@ f*+vvs
	    loop
	[else]
	    n2 1 and if
		b1 v@  a j n2 * dfloats + df@ f*+vvs then
	    n2 n2 1 and ?do
		b1 i th v@  b1 i 1+ th v@
		a j n2 * i + dfloats + dup df@ dfloat+ df@ f*+*+vvvss
	    2 +loop
	[then]
	v!
    loop
    c1 n1 n3 c mat! ;

[then]