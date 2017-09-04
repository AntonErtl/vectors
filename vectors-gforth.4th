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
	."  = ((void *)" type ." ) + " 0 vect-data dec. ." ;" ;] >c ;

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
    genv-binary-c    bplusv_  vb *v1 +  *v2
    genv-binary-c    wplusv_  vw *v1 +  *v2  
    genv-binary-c    lplusv_  vl *v1 +  *v2  
    genv-binary-c    xplusv_  vx *v1 +  *v2  
    genv-binary-c   sfplusv_ vsf *v1 +  *v2
    genv-binary-c   dfplusv_ vdf *v1 +  *v2
    genv-binary-c   bminusv_  vb *v1 -  *v2  
    genv-binary-c   wminusv_  vw *v1 -  *v2  
    genv-binary-c   lminusv_  vl *v1 -  *v2  
    genv-binary-c   xminusv_  vx *v1 -  *v2  
    genv-binary-c  sfminusv_ vsf *v1 -  *v2
    genv-binary-c  dfminusv_ vdf *v1 -  *v2
    genv-unary-c   bnegatev_  vb - *v1  
    genv-unary-c   wnegatev_  vw - *v1  
    genv-unary-c   lnegatev_  vl - *v1  
    genv-unary-c   xnegatev_  vx - *v1  
    genv-unary-c  sfnegatev_ vsf - *v1
    genv-unary-c  dfnegatev_ vdf - *v1
    genv-unary-c      babsv_  vb (*v1 + (*v1 < 0)) ^ (*v1 < 0)  
    genv-unary-c      wabsv_  vw (*v1 + (*v1 < 0)) ^ (*v1 < 0)  
    genv-unary-c      labsv_  vl (*v1 + (*v1 < 0)) ^ (*v1 < 0)  
    genv-unary-c      xabsv_  vx (*v1 + (*v1 < 0)) ^ (*v1 < 0)  
\   genv-unary-c     sfabsv_ vsf (*v1 + (*v1 < 0)) ^ (*v1 < 0)
\   genv-unary-c     dfabsv_ vdf (*v1 + (*v1 < 0)) ^ (*v1 < 0)
    genv-binary-c   btimesv_  vb *v1 *  *v2  
    genv-binary-c   wtimesv_  vw *v1 *  *v2  
    genv-binary-c   ltimesv_  vl *v1 *  *v2  
    genv-binary-c   xtimesv_  vx *v1 *  *v2  
    genv-binary-c  sftimesv_ vsf *v1 *  *v2
    genv-binary-c  dftimesv_ vdf *v1 *  *v2
    genv-binary-c   bslashv_  vb *v1 /  *v2  
    genv-binary-c   wslashv_  vw *v1 /  *v2  
    genv-binary-c   lslashv_  vl *v1 /  *v2  
    genv-binary-c   xslashv_  vx *v1 /  *v2  
    genv-binary-c  ubslashv_ vub *v1 /  *v2  
    genv-binary-c  uwslashv_ vuw *v1 /  *v2  
    genv-binary-c  ulslashv_ vul *v1 /  *v2  
    genv-binary-c  uxslashv_ vux *v1 /  *v2  
    genv-binary-c  sfslashv_ vsf *v1 /  *v2
    genv-binary-c  dfslashv_ vdf *v1 /  *v2
    genv-binary-c     bmodv_  vb *v1 %  *v2  
    genv-binary-c     wmodv_  vw *v1 %  *v2  
    genv-binary-c     lmodv_  vl *v1 %  *v2  
    genv-binary-c     xmodv_  vx *v1 %  *v2  
    genv-binary-c    ubmodv_ vub *v1 %  *v2  
    genv-binary-c    uwmodv_ vuw *v1 %  *v2  
    genv-binary-c    ulmodv_ vul *v1 %  *v2  
    genv-binary-c    uxmodv_ vux *v1 %  *v2  
    genv-binary-c     bandv_  vb *v1 &  *v2  
    genv-binary-c      borv_  vb *v1 |  *v2  
    genv-binary-c     bxorv_  vb *v1 ^  *v2
    genv-unary-c   binvertv_  vb ~ *v1
    genv-ternary-c    bmuxv_  vb (*v1 & *v3) | (*v2 & ~*v3)
    genv-binary-c  blshiftv_  vb *v1 << *v2   
    genv-binary-c  wlshiftv_  vw *v1 << *v2   
    genv-binary-c  llshiftv_  vl *v1 << *v2   
    genv-binary-c  xlshiftv_  vx *v1 << *v2   
    genv-binary-c  brshiftv_  vb *v1 >> *v2   
    genv-binary-c  wrshiftv_  vw *v1 >> *v2   
    genv-binary-c  lrshiftv_  vl *v1 >> *v2   
    genv-binary-c  xrshiftv_  vx *v1 >> *v2   
    genv-binary-c ubrshiftv_ vub *v1 >> *v2   
    genv-binary-c uwrshiftv_ vuw *v1 >> *v2   
    genv-binary-c ulrshiftv_ vul *v1 >> *v2   
    genv-binary-c uxrshiftv_ vux *v1 >> *v2
    genv-binary-c      bltv_  vb *v1 <  *v2  
    genv-binary-c      wltv_  vw *v1 <  *v2  
    genv-binary-c      lltv_  vl *v1 <  *v2  
    genv-binary-c      xltv_  vx *v1 <  *v2  
    genv-binary-c     ubltv_ vub *v1 <  *v2  
    genv-binary-c     uwltv_ vuw *v1 <  *v2  
    genv-binary-c     ulltv_ vul *v1 <  *v2  
    genv-binary-c     uxltv_ vux *v1 <  *v2  
    genv-binary-c     sfltv_ vsf *v1 <  *v2
    genv-binary-c     dfltv_ vdf *v1 <  *v2
    genv-binary-c      beqv_  vb *v1 == *v2  
    genv-binary-c      weqv_  vw *v1 == *v2  
    genv-binary-c      leqv_  vl *v1 == *v2  
    genv-binary-c      xeqv_  vx *v1 == *v2  
    genv-binary-c     sfeqv_ vsf *v1 == *v2
    genv-binary-c     dfeqv_ vdf *v1 == *v2
    genv-binary-c      bgtv_  vb *v1 >  *v2  
    genv-binary-c      wgtv_  vw *v1 >  *v2  
    genv-binary-c      lgtv_  vl *v1 >  *v2  
    genv-binary-c      xgtv_  vx *v1 >  *v2  
    genv-binary-c     ubgtv_ vub *v1 >  *v2  
    genv-binary-c     uwgtv_ vuw *v1 >  *v2  
    genv-binary-c     ulgtv_ vul *v1 >  *v2  
    genv-binary-c     uxgtv_ vux *v1 >  *v2  
    genv-binary-c     sfgtv_ vsf *v1 >  *v2
    genv-binary-c     dfgtv_ vdf *v1 >  *v2
    genv-binary-c      blev_  vb *v1 <= *v2   
    genv-binary-c      wlev_  vw *v1 <= *v2   
    genv-binary-c      llev_  vl *v1 <= *v2   
    genv-binary-c      xlev_  vx *v1 <= *v2   
    genv-binary-c     ublev_ vub *v1 <= *v2   
    genv-binary-c     uwlev_ vuw *v1 <= *v2   
    genv-binary-c     ullev_ vul *v1 <= *v2   
    genv-binary-c     uxlev_ vux *v1 <= *v2   
    genv-binary-c     sflev_ vsf *v1 <= *v2
    genv-binary-c     dflev_ vdf *v1 <= *v2
    genv-binary-c      bgev_  vb *v1 >= *v2   
    genv-binary-c      wgev_  vw *v1 >= *v2   
    genv-binary-c      lgev_  vl *v1 >= *v2   
    genv-binary-c      xgev_  vx *v1 >= *v2   
    genv-binary-c     ubgev_ vub *v1 >= *v2   
    genv-binary-c     uwgev_ vuw *v1 >= *v2   
    genv-binary-c     ulgev_ vul *v1 >= *v2   
    genv-binary-c     uxgev_ vux *v1 >= *v2   
    genv-binary-c     sfgev_ vsf *v1 >= *v2
    genv-binary-c     dfgev_ vdf *v1 >= *v2
    genv-binary-c      bnev_  vb *v1 != *v2   
    genv-binary-c      wnev_  vw *v1 != *v2   
    genv-binary-c      lnev_  vl *v1 != *v2   
    genv-binary-c      xnev_  vx *v1 != *v2   
    genv-binary-c     sfnev_ vsf *v1 != *v2
    genv-binary-c     dfnev_ vdf *v1 != *v2
    genv-binary-c     bmaxv_  vb ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2
    genv-binary-c     wmaxv_  vw ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2  
    genv-binary-c     lmaxv_  vl ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2  
    genv-binary-c     xmaxv_  vx ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2  
    genv-binary-c    ubmaxv_ vub ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2  
    genv-binary-c    uwmaxv_ vuw ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2  
    genv-binary-c    ulmaxv_ vul ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2  
    genv-binary-c    uxmaxv_ vux ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2  
\   genv-binary-c    sfmaxv_ vsf ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2
\   genv-binary-c    dfmaxv_ vdf ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v2
    genv-binary-c     bminv_  vb ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1
    genv-binary-c     wminv_  vw ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1  
    genv-binary-c     lminv_  vl ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1  
    genv-binary-c     xminv_  vx ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1  
    genv-binary-c    ubminv_ vub ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1  
    genv-binary-c    uwminv_ vuw ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1  
    genv-binary-c    ulminv_ vul ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1  
    genv-binary-c    uxminv_ vux ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1  
\   genv-binary-c    sfminv_ vsf ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1
\   genv-binary-c    dfminv_ vdf ((*v1 >= *v2) & (*v1 ^ *v2)) ^ *v1

    genv-vs-c    bplusvs_  vb n *v1 +  s2
    genv-vs-c    wplusvs_  vw n *v1 +  s2  
    genv-vs-c    lplusvs_  vl n *v1 +  s2  
    genv-vs-c    xplusvs_  vx n *v1 +  s2  
    genv-vs-c   sfplusvs_ vsf r *v1 +  s2
    genv-vs-c   dfplusvs_ vdf r *v1 +  s2
    genv-vs-c   bminusvs_  vb n *v1 -  s2  
    genv-vs-c   wminusvs_  vw n *v1 -  s2  
    genv-vs-c   lminusvs_  vl n *v1 -  s2  
    genv-vs-c   xminusvs_  vx n *v1 -  s2  
    genv-vs-c  sfminusvs_ vsf r *v1 -  s2
    genv-vs-c  dfminusvs_ vdf r *v1 -  s2
    genv-vs-c   btimesvs_  vb n *v1 *  s2  
    genv-vs-c   wtimesvs_  vw n *v1 *  s2  
    genv-vs-c   ltimesvs_  vl n *v1 *  s2  
    genv-vs-c   xtimesvs_  vx n *v1 *  s2  
    genv-vs-c  sftimesvs_ vsf r *v1 *  s2
    genv-vs-c  dftimesvs_ vdf r *v1 *  s2
    genv-vs-c   bslashvs_  vb n *v1 /  s2  
    genv-vs-c   wslashvs_  vw n *v1 /  s2  
    genv-vs-c   lslashvs_  vl n *v1 /  s2  
    genv-vs-c   xslashvs_  vx n *v1 /  s2  
    genv-vs-c  ubslashvs_ vub u *v1 /  s2  
    genv-vs-c  uwslashvs_ vuw u *v1 /  s2  
    genv-vs-c  ulslashvs_ vul u *v1 /  s2  
    genv-vs-c  uxslashvs_ vux u *v1 /  s2  
    genv-vs-c  sfslashvs_ vsf r *v1 /  s2
    genv-vs-c  dfslashvs_ vdf r *v1 /  s2
    genv-vs-c     bmodvs_  vb n *v1 %  s2  
    genv-vs-c     wmodvs_  vw n *v1 %  s2  
    genv-vs-c     lmodvs_  vl n *v1 %  s2  
    genv-vs-c     xmodvs_  vx n *v1 %  s2  
    genv-vs-c    ubmodvs_ vub u *v1 %  s2  
    genv-vs-c    uwmodvs_ vuw u *v1 %  s2  
    genv-vs-c    ulmodvs_ vul u *v1 %  s2  
    genv-vs-c    uxmodvs_ vux u *v1 %  s2  
    genv-vs-c     bandvs_  vb n *v1 &  s2  
    genv-vs-c      borvs_  vb n *v1 |  s2  
    genv-vs-c     bxorvs_  vb n *v1 ^  s2
    genv-vs-c  blshiftvs_  vb n *v1 << s2   
    genv-vs-c  wlshiftvs_  vw n *v1 << s2   
    genv-vs-c  llshiftvs_  vl n *v1 << s2   
    genv-vs-c  xlshiftvs_  vx n *v1 << s2   
    genv-vs-c  brshiftvs_  vb n *v1 >> s2   
    genv-vs-c  wrshiftvs_  vw n *v1 >> s2   
    genv-vs-c  lrshiftvs_  vl n *v1 >> s2   
    genv-vs-c  xrshiftvs_  vx n *v1 >> s2   
    genv-vs-c ubrshiftvs_ vub u *v1 >> s2   
    genv-vs-c uwrshiftvs_ vuw u *v1 >> s2   
    genv-vs-c ulrshiftvs_ vul u *v1 >> s2   
    genv-vs-c uxrshiftvs_ vux u *v1 >> s2
    genv-vs-c      bltvs_  vb n *v1 <  s2  
    genv-vs-c      wltvs_  vw n *v1 <  s2  
    genv-vs-c      lltvs_  vl n *v1 <  s2  
    genv-vs-c      xltvs_  vx n *v1 <  s2  
    genv-vs-c     ubltvs_ vub u *v1 <  s2  
    genv-vs-c     uwltvs_ vuw u *v1 <  s2  
    genv-vs-c     ulltvs_ vul u *v1 <  s2  
    genv-vs-c     uxltvs_ vux u *v1 <  s2  
    genv-vs-c     sfltvs_ vsf r *v1 <  s2
    genv-vs-c     dfltvs_ vdf r *v1 <  s2
    genv-vs-c      beqvs_  vb n *v1 == s2  
    genv-vs-c      weqvs_  vw n *v1 == s2  
    genv-vs-c      leqvs_  vl n *v1 == s2  
    genv-vs-c      xeqvs_  vx n *v1 == s2  
    genv-vs-c     sfeqvs_ vsf r *v1 == s2
    genv-vs-c     dfeqvs_ vdf r *v1 == s2
    genv-vs-c      bgtvs_  vb n *v1 >  s2  
    genv-vs-c      wgtvs_  vw n *v1 >  s2  
    genv-vs-c      lgtvs_  vl n *v1 >  s2  
    genv-vs-c      xgtvs_  vx n *v1 >  s2  
    genv-vs-c     ubgtvs_ vub u *v1 >  s2  
    genv-vs-c     uwgtvs_ vuw u *v1 >  s2  
    genv-vs-c     ulgtvs_ vul u *v1 >  s2  
    genv-vs-c     uxgtvs_ vux u *v1 >  s2  
    genv-vs-c     sfgtvs_ vsf r *v1 >  s2
    genv-vs-c     dfgtvs_ vdf r *v1 >  s2
    genv-vs-c      blevs_  vb n *v1 <= s2   
    genv-vs-c      wlevs_  vw n *v1 <= s2   
    genv-vs-c      llevs_  vl n *v1 <= s2   
    genv-vs-c      xlevs_  vx n *v1 <= s2   
    genv-vs-c     ublevs_ vub u *v1 <= s2   
    genv-vs-c     uwlevs_ vuw u *v1 <= s2   
    genv-vs-c     ullevs_ vul u *v1 <= s2   
    genv-vs-c     uxlevs_ vux u *v1 <= s2   
    genv-vs-c     sflevs_ vsf r *v1 <= s2
    genv-vs-c     dflevs_ vdf r *v1 <= s2
    genv-vs-c      bgevs_  vb n *v1 >= s2   
    genv-vs-c      wgevs_  vw n *v1 >= s2   
    genv-vs-c      lgevs_  vl n *v1 >= s2   
    genv-vs-c      xgevs_  vx n *v1 >= s2   
    genv-vs-c     ubgevs_ vub u *v1 >= s2   
    genv-vs-c     uwgevs_ vuw u *v1 >= s2   
    genv-vs-c     ulgevs_ vul u *v1 >= s2   
    genv-vs-c     uxgevs_ vux u *v1 >= s2   
    genv-vs-c     sfgevs_ vsf r *v1 >= s2
    genv-vs-c     dfgevs_ vdf r *v1 >= s2
    genv-vs-c      bnevs_  vb n *v1 != s2   
    genv-vs-c      wnevs_  vw n *v1 != s2   
    genv-vs-c      lnevs_  vl n *v1 != s2   
    genv-vs-c      xnevs_  vx n *v1 != s2   
    genv-vs-c     sfnevs_ vsf r *v1 != s2
    genv-vs-c     dfnevs_ vdf r *v1 != s2
    genv-vs-c     bmaxvs_  vb n ((*v1 >= s2) & (*v1 ^ s2)) ^ s2
    genv-vs-c     wmaxvs_  vw n ((*v1 >= s2) & (*v1 ^ s2)) ^ s2  
    genv-vs-c     lmaxvs_  vl n ((*v1 >= s2) & (*v1 ^ s2)) ^ s2  
    genv-vs-c     xmaxvs_  vx n ((*v1 >= s2) & (*v1 ^ s2)) ^ s2  
    genv-vs-c    ubmaxvs_ vub u ((*v1 >= s2) & (*v1 ^ s2)) ^ s2  
    genv-vs-c    uwmaxvs_ vuw u ((*v1 >= s2) & (*v1 ^ s2)) ^ s2  
    genv-vs-c    ulmaxvs_ vul u ((*v1 >= s2) & (*v1 ^ s2)) ^ s2  
    genv-vs-c    uxmaxvs_ vux u ((*v1 >= s2) & (*v1 ^ s2)) ^ s2  
\   genv-vs-c    sfmaxvs_ vsf r ((*v1 >= s2) & (*v1 ^ s2)) ^ s2
\   genv-vs-c    dfmaxvs_ vdf r ((*v1 >= s2) & (*v1 ^ s2)) ^ s2
    genv-vs-c     bminvs_  vb n ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1
    genv-vs-c     wminvs_  vw n ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1  
    genv-vs-c     lminvs_  vl n ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1  
    genv-vs-c     xminvs_  vx n ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1  
    genv-vs-c    ubminvs_ vub u ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1  
    genv-vs-c    uwminvs_ vuw u ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1  
    genv-vs-c    ulminvs_ vul u ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1  
    genv-vs-c    uxminvs_ vux u ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1  
\   genv-vs-c    sfminvs_ vsf r ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1
\   genv-vs-c    dfminvs_ vdf r ((*v1 >= s2) & (*v1 ^ s2)) ^ *v1

    genv-sv-c   bminussv_  vb n s1 -  *v2  
    genv-sv-c   wminussv_  vw n s1 -  *v2  
    genv-sv-c   lminussv_  vl n s1 -  *v2  
    genv-sv-c   xminussv_  vx n s1 -  *v2  
    genv-sv-c  sfminussv_ vsf r s1 -  *v2
    genv-sv-c  dfminussv_ vdf r s1 -  *v2
    genv-sv-c   bslashsv_  vb n s1 /  *v2  
    genv-sv-c   wslashsv_  vw n s1 /  *v2  
    genv-sv-c   lslashsv_  vl n s1 /  *v2  
    genv-sv-c   xslashsv_  vx n s1 /  *v2  
    genv-sv-c  ubslashsv_ vub u s1 /  *v2  
    genv-sv-c  uwslashsv_ vuw u s1 /  *v2  
    genv-sv-c  ulslashsv_ vul u s1 /  *v2  
    genv-sv-c  uxslashsv_ vux u s1 /  *v2  
    genv-sv-c  sfslashsv_ vsf r s1 /  *v2
    genv-sv-c  dfslashsv_ vdf r s1 /  *v2
    genv-sv-c     bmodsv_  vb n s1 %  *v2  
    genv-sv-c     wmodsv_  vw n s1 %  *v2  
    genv-sv-c     lmodsv_  vl n s1 %  *v2  
    genv-sv-c     xmodsv_  vx n s1 %  *v2  
    genv-sv-c    ubmodsv_ vub u s1 %  *v2  
    genv-sv-c    uwmodsv_ vuw u s1 %  *v2  
    genv-sv-c    ulmodsv_ vul u s1 %  *v2  
    genv-sv-c    uxmodsv_ vux u s1 %  *v2  
    genv-sv-c  blshiftsv_  vb n s1 << *v2   
    genv-sv-c  wlshiftsv_  vw n s1 << *v2   
    genv-sv-c  llshiftsv_  vl n s1 << *v2   
    genv-sv-c  xlshiftsv_  vx n s1 << *v2   
    genv-sv-c  brshiftsv_  vb n s1 >> *v2   
    genv-sv-c  wrshiftsv_  vw n s1 >> *v2   
    genv-sv-c  lrshiftsv_  vl n s1 >> *v2   
    genv-sv-c  xrshiftsv_  vx n s1 >> *v2   
    genv-sv-c ubrshiftsv_ vub u s1 >> *v2   
    genv-sv-c uwrshiftsv_ vuw u s1 >> *v2   
    genv-sv-c ulrshiftsv_ vul u s1 >> *v2   
    genv-sv-c uxrshiftsv_ vux u s1 >> *v2
    genv-sv-c      bltsv_  vb n s1 <  *v2  
    genv-sv-c      wltsv_  vw n s1 <  *v2  
    genv-sv-c      lltsv_  vl n s1 <  *v2  
    genv-sv-c      xltsv_  vx n s1 <  *v2  
    genv-sv-c     ubltsv_ vub u s1 <  *v2  
    genv-sv-c     uwltsv_ vuw u s1 <  *v2  
    genv-sv-c     ulltsv_ vul u s1 <  *v2  
    genv-sv-c     uxltsv_ vux u s1 <  *v2  
    genv-sv-c     sfltsv_ vsf r s1 <  *v2
    genv-sv-c     dfltsv_ vdf r s1 <  *v2
    genv-sv-c      bgtsv_  vb n s1 >  *v2  
    genv-sv-c      wgtsv_  vw n s1 >  *v2  
    genv-sv-c      lgtsv_  vl n s1 >  *v2  
    genv-sv-c      xgtsv_  vx n s1 >  *v2  
    genv-sv-c     ubgtsv_ vub u s1 >  *v2  
    genv-sv-c     uwgtsv_ vuw u s1 >  *v2  
    genv-sv-c     ulgtsv_ vul u s1 >  *v2  
    genv-sv-c     uxgtsv_ vux u s1 >  *v2  
    genv-sv-c     sfgtsv_ vsf r s1 >  *v2
    genv-sv-c     dfgtsv_ vdf r s1 >  *v2
    genv-sv-c      blesv_  vb n s1 <= *v2   
    genv-sv-c      wlesv_  vw n s1 <= *v2   
    genv-sv-c      llesv_  vl n s1 <= *v2   
    genv-sv-c      xlesv_  vx n s1 <= *v2   
    genv-sv-c     ublesv_ vub u s1 <= *v2   
    genv-sv-c     uwlesv_ vuw u s1 <= *v2   
    genv-sv-c     ullesv_ vul u s1 <= *v2   
    genv-sv-c     uxlesv_ vux u s1 <= *v2   
    genv-sv-c     sflesv_ vsf r s1 <= *v2
    genv-sv-c     dflesv_ vdf r s1 <= *v2
    genv-sv-c      bgesv_  vb n s1 >= *v2   
    genv-sv-c      wgesv_  vw n s1 >= *v2   
    genv-sv-c      lgesv_  vl n s1 >= *v2   
    genv-sv-c      xgesv_  vx n s1 >= *v2   
    genv-sv-c     ubgesv_ vub u s1 >= *v2   
    genv-sv-c     uwgesv_ vuw u s1 >= *v2   
    genv-sv-c     ulgesv_ vul u s1 >= *v2   
    genv-sv-c     uxgesv_ vux u s1 >= *v2   
    genv-sv-c     sfgesv_ vsf r s1 >= *v2
    genv-sv-c     dfgesv_ vdf r s1 >= *v2
    
end-c-library

