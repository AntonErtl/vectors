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

