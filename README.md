# vectors - Forth vector words

This package implements a wordset for vector processing, ideally
implemented using SIMD instructions.

## Concepts

Vectors contain an array of integers or FP items.  All items in a
vector are of the same type and size, with currently supported integer
item sizes of 8, 16, 32, or 64 bits, and supported FP item sizes of 32
or 64 bits.  As usual in Forth, the system knows nothing about these
types and treats the contents of the vector as a bunch of bytes.

Vectors are an opaque data type that is represented by a single-cell
vector token in memory.  Vectors have value semantics, like cells or
floats, and unlike strings in memory: When you copy a vector, the copy
has an identity of its own, and it is unaffected by operations on the
original (and vice versa).  The vector words maintain and rely on this
property.  In order to maintain this property, you must not copy or
overwrite vector tokens with `@`, `!`, or `move`.  Use `v@` and `v!`
instead.

## Vector Types

prefix| name | scalar | description
----- | ---- | ------ | ----------------------------------
      |    v |        | General vector
    b |   bv |    n   | vector of   signed  8-bit integers
   ub |  ubv |    u   | vector of unsigned  8-bit integers
    w |   wv |    n   | vector of   signed 16-bit integers
   uw |  uwv |    u   | vector of unsigned 16-bit integers
    l |   lv |    n   | vector of   signed 32-bit integers
   ul |  ulv |    u   | vector of unsigned 32-bit integers
    x |   xv |    n   | vector of   signed 64-bit integers
   ux |  uxv |    u   | vector of unsigned 64-bit integers
   sf |  sfv |    r   | vector of 32-bit FPs
   df |  dfv |    r   | vector of 64-bit FPs

In the current implementation vectors of 64-bit integers are only
supported on 64-bit systems.

In the following "tv" and "ts" will be used as type parameters, with
"tv" being the vector type and "ts" the scalar (single element) type.
E.g., `df-vs` is in the category of words with the parameterized stack
effect `( tv1 ts -- tv )`.  The actual stack effect for `df-vs` is
`( dfv1 r -- dfv )`

## Vector stack and stack notation

There is a vector stack separate from the data, return, and FP stacks.
In the stack notation used here, vectors are always on the vector
stack, and therefore no separate vector stack notation is used (and
likewise for 'r' and the FP stack).  I.e. in `( dfv1 r -- dfv )`
`dfv1` and `dfv` are on the vector stack, and `r` is on the FP stack.

## Words

### Stack manipulation

Vector variants of stack manipulation words: `vdup vover vswap vrot
vdrop vpick vroll`.

### Memory access

#### Concrete memory access

`b@v ( c-addr u -- v )`

Create vector `v` with length `u` containing a copy of the `u` bytes
starting at `c-addr`.

`b!v ( v c-addr u -- )`

Store the contents of the vector `v` at `c-addr`.  If the vector does
not contain `u` bytes, throw an error.

#### Opaque vector loading and storing

`v-addr` is the address of a cell containing a vector token.

`v! ( v v-addr -- )`

Store the vector token for `v` at `v-addr`.

`v@ ( v-addr -- v )

Fetch the vector token `v` from `v-addr`.

`v@'` ( v-addr -- v )

Fetch the vector token `v` from `v-addr`, and store 0 at v-addr.  This
word is more efficient than `v@`.

###vector parallel

These words take one, two, or three vectors of the same length, and
apply the operation elementwise, producing a vector of the same
length.  E.g., consider `df-v ( dfv1 dfv2 -- dfv )`.  If you pass two
16-byte (two df elements) vectors to this word, then
dfv[0]=dfv1[0]-dfv2[0], dfv[1]=dfv1[1]-dfv2[1].

If you pass vectors of different lengths to such a word, iy will throw
an error.

These words have a `v` suffix.

#### Binary

Stack effect: ( tv1 tv2 -- tv )

Operations: `+ - * / mod and or xor lshift rshift < = > <= >= <> max
min`

`/` and `mod` may differ in symmetric/floored and exception behaviour
from the underlying system.  Comparison operations produce all-bits-0
or all-bits-1 for the number of bits in the element.  `And or xor` are
bitwise and therefore don't have variants for different types.

Words: ```
b+v w+v l+v x+v sf+v df+v
b-v w-v l-v x-v sf-v df-v
b*v w*v l*v x*v sf*v df*v
b/v w/v l/v x/v ub/v uw/v ul/v ux/v sf/v df/v
bmodv wmodv lmodv xmodv ubmodv uwmodv ulmodv uxmodv
andv
orv
xorv
blshiftv wlshiftv llshiftv xlshiftv
brshiftv wrshiftv lrshiftv xrshiftv ubrshiftv uwrshiftv ulrshiftv uxrshiftv
b<v w<v l<v x<v ub<v uw<v ul<v ux<v sf<v df<v
b=v w=v l=v x=v sf=v df=v
b>v w>v l>v x>v ub>v uw>v ul>v ux>v sf>v df>v
b<=v w<=v l<=v x<=v ub<=v uw<=v ul<=v ux<=v sf<=v df<=v
b>=v w>=v l>=v x>=v ub>=v uw>=v ul>=v ux>=v sf>=v df>=v
b<>v w<>v l<>v x<>v sf<>v df<>v
bmaxv wmaxv lmaxv xmaxv ubmaxv uwmaxv ulmaxv uxmaxv sfmaxv dfmaxv
bminv wminv lminv xminv ubminv uwminv ulminv uxminv sfminv dfminv```

#### Unary

Stack effect: ( tv1 -- tv )

Operations: `invert negate abs`

Words: ```
invertv
bnegatev wnegatev lnegatev xnegatev sfnegatev dfnegatev
babsv wabsv labsv xabsv sfabsv dfabsv```

#### Ternary

muxv ( v1 v2 v3 -- v )

For each bit in v3: if the bit is 1, the corresponding result bit is
the corresponding bit in v1, otherwise in v2.

### Vector/scalar parallel



These words take one vector and one scalar, and apply the operation
elementwise (always using the same scalar).  In the `vs`-suffixed
words, the scalar is the second operand, while in the `sv`-suffixed
words (only for non-commutative operations), the scalar is the first
operand.  E.g., consider `df-sv ( r dfv1 -- dfv ): If you pass a
16-byte vector to this word, then dfv[0]=r-dfv1[0], dfv[1]=r-dfv1[1].

The operations are the same as for the binary words above.

#### Vector/scalar words

Suffix: `vs`
Stack effect: ( tv1 ts -- tv )

```
b+vs w+vs l+vs x+vs sf+vs df+vs
b-vs w-vs l-vs x-vs sf-vs df-vs
b*vs w*vs l*vs x*vs sf*vs df*vs
b/vs w/vs l/vs x/vs ub/vs uw/vs ul/vs ux/vs sf/vs df/vs
bmodvs wmodvs lmodvs xmodvs ubmodvs uwmodvs ulmodvs uxmodvs
andvs
orvs
xorvs
blshiftvs wlshiftvs llshiftvs xlshiftvs
brshiftvs wrshiftvs lrshiftvs xrshiftvs ubrshiftvs uwrshiftvs ulrshiftvs uxrshiftvs
b<vs w<vs l<vs x<vs ub<vs uw<vs ul<vs ux<vs sf<vs df<vs
b=vs w=vs l=vs x=vs sf=vs df=vs
b>vs w>vs l>vs x>vs ub>vs uw>vs ul>vs ux>vs sf>vs df>vs
b<=vs w<=vs l<=vs x<=vs ub<=vs uw<=vs ul<=vs ux<=vs sf<=vs df<=vs
b>=vs w>=vs l>=vs x>=vs ub>=vs uw>=vs ul>=vs ux>=vs sf>=vs df>=vs
b<>vs w<>vs l<>vs x<>vs sf<>vs df<>vs
bmaxvs wmaxvs lmaxvs xmaxvs ubmaxvs uwmaxvs ulmaxvs uxmaxvs sfmaxvs dfmaxvs
bminvs wminvs lminvs xminvs ubminvs uwminvs ulminvs uxminvs sfminvs dfminvs```

#### Scalar/Vector words

Suffix: `sv`
Stack effect: ( ts tv1 -- tv )

```
b-sv w-sv l-sv x-sv sf-sv df-sv
b/sv w/sv l/sv x/sv ub/sv uw/sv ul/sv ux/sv sf/sv df/sv
bmodsv wmodsv lmodsv xmodsv ubmodsv uwmodsv ulmodsv uxmodsv
blshiftsv wlshiftsv llshiftsv xlshiftsv
brshiftsv wrshiftsv lrshiftsv xrshiftsv ubrshiftsv uwrshiftsv ulrshiftsv uxrshiftsv
b<sv w<sv l<sv x<sv ub<sv uw<sv ul<sv ux<sv sf<sv df<sv
b>sv w>sv l>sv x>sv ub>sv uw>sv ul>sv ux>sv sf>sv df>sv
b<=sv w<=sv l<=sv x<=sv ub<=sv uw<=sv ul<=sv ux<=sv sf<=sv df<=sv
b>=sv w>=sv l>=sv x>=sv ub>=sv uw>=sv ul>=sv ux>=sv sf>=sv df>=sv```
