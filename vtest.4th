\ vectors.4th tests

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

include vmatmul.4th
include ttester.fs

: df, ( r -- )
    here 1 dfloats allot df! ;

create x 1e df, 2e df,
create y 2 dfloats allot
T{ x 2 dfloats b@v y 2 dfloats b!v -> }T
T{ x 2 dfloats y over compare -> 0 }T
T{ x 2 dfloats b@v y 1 dfloats ' b!v catch 0= nip nip -> 0 }T

variable v1 0 v1 !
variable v2 0 v2 !
T{ x 2 dfloats b@v v1 v! -> }T
T{ v1 v@ v1 v! -> }T
T{ v1 v@' 3e df*vs v1 v! -> }T
T{ x 2 dfloats b@v -> }T
T{ v1 v@ 3e df*vs -> }T
T{ df+v -> }T
T{ v1 v@ df+v -> }T
T{ v2 v! -> }T
T{ v1 v@ v2 v@ df+v -> }T
T{ v2 v! -> }T
T{ v1 v@ v2 v@' df+v -> }T
T{ v2 v! -> }T

: init-matrix {: m ncols nrows nstart -- :}
    \ initialize m with dfloats nstart, nstart+1, ...
    nstart nrows 0 ?do
	ncols 0 ?do
	    dup 0 d>f m j ncols * i + dfloats + df! 1+
	loop
    loop
    drop ;

6 dfloats allocate throw constant a a 2 3 1 init-matrix
6 dfloats allocate throw constant b b 3 2 7 init-matrix
dfalign here 9 dfloats allot constant c
8 dfloats allocate throw constant e e 4 2 8 init-matrix
dfalign here 12 dfloats allot constant f

[undefined] f.rdp [if]
    : f.rdp ( r nr nd np -- )
        2drop drop f. ;
[then]

: mat. {: m ncols nrows -- :}
    nrows 0 ?do
	cr ncols 0 ?do
	    m j ncols * i + dfloats + df@ 7 0 1 f.rdp space
	loop
    loop ;

\ a 2 3 mat. cr
\ b 3 2 mat. cr
a b c 3 2 3 matmulr
\ c 3 3 mat. cr
\ a 2 3 mat. cr
\ e 4 2 mat. cr
a e f 3 2 4 matmulr
\ f 4 3 mat. cr bye

create d
27e df,  30e df,  33e df,
61e df,  68e df,  75e df,
95e df, 106e df, 117e df,

create g
    32e df,     35e df,     38e df,     41e df, 
    72e df,     79e df,     86e df,     93e df, 
   112e df,    123e df,    134e df,    145e df, 

\ c 3 3 mat.

\ f 4 3 mat.

T{ c 9 dfloats d 9 dfloats compare -> 0 }T
T{ f 12 dfloats g 12 dfloats compare -> 0 }T
cr