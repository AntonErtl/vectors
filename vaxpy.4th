require vectors.4th

c-library vaxpy
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

    \c static void vaxpy(sdf a, vdf *x, vdf* y, vdf *z, size_t bytes)
    \c {
    \c   size_t i;
    "x" +=vect-data "y" +=vect-data "z" +=vect-data
    \c   for (i=0; i<bytes;) {
    unroll-factor 0 [do] "    *z = (a * *x)+*y;  i+=SIMD_SIZE, x++, y++, z++;" write-c-prefix-line [loop]
    \c   }
    \c }
    \c static void vaxpy2(sdf a, sdf b, vdf *w, vdf *x, vdf* y, vdf *z, size_t bytes)
    \c {
    \c   size_t i;
    "w" +=vect-data "x" +=vect-data "y" +=vect-data "z" +=vect-data
    \c   for (i=0; i<bytes;) {
    unroll-factor 0 [do] "    *z = *w + (a * *x)+(b * *y);  i+=SIMD_SIZE, w++, x++, y++, z++;" write-c-prefix-line [loop]
    \c   }
    \c }
    c-function vaxpy vaxpy r a a a u -- void
    c-function vaxpy2 vaxpy2 r r a a a a u -- void
end-c-library

: f*+vvs ( v1 v2 r -- v )
    vsp @ dup @ swap cell+ @
    { vect1 vect2 | vect }
    vect1 vect-bytes @ vect2 vect-bytes @ <> vectlen-ex and throw
    vect1 vect-refs @ if
	-1 vect1 vect-refs +!
	vect2 vect-refs @ if
	    -1 vect2 vect-refs +!
	    vect1 vect-bytes @ vect-alloc
	else
	    vect2 then
    else
	vect1 then
    to vect
    [defined] use-vaxpy [if]
	vect1 vect2 vect vect vect-bytes @ vaxpy
    [else]
	abort
    [then]
    vect vect1 = if
	vect2 vect-free then
    vect vsp @ cell+ dup vsp ! ! ;

: f*+*+vvvss ( v1 v2 v3 r2 r3 -- v )
    \ v=v1+v2*r2+v3*r3
    vsp @ dup @ dup vect-bytes @ { vect3 u }
    cell+ dup @ u ?vectlen swap cell+ @ u ?vectlen { vect2 vect1 }
    vect1 vect-refs @ if
	-1 vect1 vect-refs +!
	vect1 vect2 vect3 u vect-alloc dup >r u vaxpy2
	r> vsp @ [ 2 cells ] literal + !
    else
	vect1 vect2 vect3 vect1 u vaxpy2
    then
    vect2 vect-free
    vect3 vect-free
    [ 2 cells ] literal vsp +! ;

