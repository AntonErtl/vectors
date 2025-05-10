\ gforth-specific implementations of helper words for vectors.4th

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

also c-lib

: >c ( ... xt -- )
    >string-execute 2dup write-c-prefix-line drop free throw ;

: +=vect-data ( c-addr u )
    [:  ."   " 2dup type
	."  = *(void **)(((void *)" type ." ) + " 0 vect-datap dec. ." );" ;] >c ;

: genv-binary-c ( "name" "type" "expression\n" -- )
    parse-name parse-name -1 parse {: d: n d: t d: x :}
    t n [: ." static void " type ." ("
	2dup type ." *v1, " 2dup type ." *v2, " type ." *v, size_t bytes)" ;] >c
    s" {" write-c-prefix-line
    s"   size_t i;" write-c-prefix-line
    "v1" +=vect-data "v2" +=vect-data "v" +=vect-data
    s"   for (i=0; i<bytes; ) {" write-c-prefix-line
    unroll-factor 0 ?do
	x [: ."     *v = " type ." ; i+=SIMD_SIZE, v1++, v2++, v++;" ;] >c
    loop
    "  }" write-c-prefix-line
    "}" write-c-prefix-line
    n [: 2dup type space type ."  a a a u -- void" ;] >string-execute
    2dup ['] c-function execute-parsing drop free throw ;

: genv-unary-c ( "name" "type" "expression\n" -- )
    parse-name parse-name -1 parse {: d: n d: t d: x :}
    t n [: ." static void " type ." ("
	2dup type ." *v1, " type ." *v, size_t bytes)" ;] >c
    s" {" write-c-prefix-line
    s"   size_t i;" write-c-prefix-line
    s" v1" +=vect-data s" v" +=vect-data
    s"   for (i=0; i<bytes; ) {" write-c-prefix-line
    unroll-factor 0 ?do
	x [: ."     *v = " type ." ; i+=SIMD_SIZE, v1++, v++;" ;] >c
    loop
    "  }" write-c-prefix-line
    "}" write-c-prefix-line
    n [: 2dup type space type ."  a a u -- void" ;] >string-execute
    2dup ['] c-function execute-parsing drop free throw ;

: genv-ternary-c ( "name" "type" "expression\n" -- )
    parse-name parse-name -1 parse {: d: n d: t d: x :}
    t n [: ." static void " type ." ("
	2dup type ." *v1, " 2dup type ." *v2, " 2dup type ." *v3, "
	type ." *v, size_t bytes)" ;] >c
    s" {" write-c-prefix-line
    s"   size_t i;" write-c-prefix-line
    "v1" +=vect-data "v2" +=vect-data "v3" +=vect-data "v" +=vect-data
    s"   for (i=0; i<bytes;) {" write-c-prefix-line
    unroll-factor 0 ?do
	x [: ."     *v = " type ." ; i+=SIMD_SIZE, v1++, v2++, v3++, v++;" ;] >c
    loop
    "  }" write-c-prefix-line
    "}" write-c-prefix-line
    n [: 2dup type space type ."  a a a a u -- void" ;] >string-execute
    2dup ['] c-function execute-parsing drop free throw ;

: genv-vs-c ( "name" "vtype" "stypef" "expression\n" -- )
    parse-name parse-name parse-name -1 parse
    {: d: n d: vt d: stf d: x :}
    vt n [: ." static void " type ." ("
	2dup type ."  *v1, s" 2dup 1 /string type ."  s2, " type ."  *v, size_t bytes)" ;] >c
    s" {" write-c-prefix-line
    s"   size_t i;" write-c-prefix-line
    "v1" +=vect-data "v" +=vect-data
    s"   for (i=0; i<bytes;) {" write-c-prefix-line
    unroll-factor 0 ?do
	x [: ."     *v = " type ." ; i+=SIMD_SIZE, v1++, v++;" ;] >c
    loop
    "  }" write-c-prefix-line
    "}" write-c-prefix-line
    stf n [: 2dup type space type ."  a " type ."  a u -- void" ;] >string-execute
    2dup ['] c-function execute-parsing drop free throw ;

: genv-sv-c ( "name" "vtype" "stypef" "expression\n" -- )
    parse-name parse-name parse-name -1 parse
    {: d: n d: vt d: stf d: x :}
    vt n [: ." static void " type ." ("
	." s" 2dup 1 /string type ."  s1, " 2dup type ."  *v2, " type ."  *v, size_t bytes)" ;] >c
    s" {" write-c-prefix-line
    s"   size_t i;" write-c-prefix-line
    "v2" +=vect-data "v" +=vect-data
    s"   for (i=0; i<bytes;) {" write-c-prefix-line
    unroll-factor 0 ?do
	x [: ."     *v = " type ." ; i+=SIMD_SIZE, v2++, v++;" ;] >c
    loop
    "  }" write-c-prefix-line
    "}" write-c-prefix-line
    stf n [: 2dup type space type space type ."  a a u -- void" ;] >string-execute
    2dup ['] c-function execute-parsing drop free throw ;

previous

c-library vectors
    [: ." #define SIMD_SIZE " simd-size dec. ;] >c
    \c #if defined(__x86_64__) && SIMD_SIZE == 32
    \c #pragma GCC target "avx2"
    \c #endif
    \c #if defined(__x86_64__) && SIMD_SIZE == 64
    \c #pragma GCC target "arch=x86-64-v4"
    \c #endif
    \c #include <stddef.h>
    \c #include <stdlib.h>
    \c #include <stdint.h>
    \c typedef  int8_t   sb;
    \c typedef uint8_t  sub;
    \c typedef  int16_t  sw;
    \c typedef uint16_t suw;
    \c typedef  int32_t  sl;
    \c typedef uint32_t sul;
    \c typedef  int64_t  sx;
    \c typedef uint64_t sux;
    \c typedef   float  ssf;
    \c typedef   double sdf;
    \c typedef  int8_t   vb __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef uint8_t  vub __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef  int16_t  vw __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef uint16_t vuw __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef  int32_t  vl __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef uint32_t vul __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef  int64_t  vx __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef uint64_t vux __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef   float  vsf __attribute__ ((vector_size (SIMD_SIZE))); 
    \c typedef   double vdf __attribute__ ((vector_size (SIMD_SIZE))); 
    c-function aligned_alloc aligned_alloc u u -- a
    include genv-c.4th
end-c-library

