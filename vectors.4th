\ vector words

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

\ configuration parameters

[undefined] simd-size [if]
    #16 constant simd-size
[then]

[undefined] unroll-factor [if]
    1 constant unroll-factor
[then]

[defined] use-chaining [if]
    1 constant use-refcount
[then]

\ missing features on some Forth systems

[undefined] parse-name [if]
    include extensions/parse-name.fs
[then]

[undefined] field: [if]
    include extensions/structures.fs
[then]

[undefined] {: [if]
    include extensions/locals.fs
[then]

[undefined] synonym [if]
    [defined] enter-swift [if]
	\ probably does not work for immediate words
	: synonym ( "new" "old" )
	    >in @ bl word drop ' swap >in ! >code header ,jmp bl word drop ;
    [then]
[then]

[undefined] naligned [if]
: naligned ( addr1 n -- addr2 ) \ gforth
 1- tuck +  swap invert and ;
[then]

[undefined] exception [if]
    : exception 2drop -4096 ;
[then]

[undefined] ?dup-if [if]
    : ?dup-if postpone ?dup postpone if ; immediate
[then]

[undefined] f.rdp [if]
    : f.rdp drop 2drop f. ;
[then]

[undefined] th [if]
    : th cells + ;
[then]

[undefined] u/ [if]
    : u/   0 swap um/mod nip ;
[then]

[undefined] umod [if]
    : umod 0 swap um/mod drop ;
[then]

[undefined] arshift [if]
    [defined] rshifta [if]
	synonym arshift rshifta
    [then]
[then]

[undefined] u<= [if]
    : u<= u> 0= ;
[then]

[undefined] u>= [if]
    : u>= u< 0= ;
[then]

[undefined] f<= [if]
    : f<= f> 0= ;
[then]
[undefined] f>= [if]
    : f>= f< 0= ;
[then]
[undefined] f<> [if]
    : f<> f= 0= ;
[then]


1 cells 4 = [if]
    synonym sl@ @
    synonym ul@ @
    synonym l! !
[then]

[defined] vfxforth [if]
    synonym sb@ c@s
    synonym sw@ w@s
    synonym uw@ w@
[then]

[defined] enter-swift [if]
    synonym uw@ w@
    synonym sw@ h@
[then]

[undefined] mux [if]
    : mux tuck invert and rot rot and or ;
[then]

[undefined] ]] [if]
    include compat/macros.fs
[then]

\ data structure

simd-size unroll-factor * constant vector-granularity

0
[defined] use-refcount [if]
    field: vect-refs \ reference count-1
[then]
field: vect-bytes
[defined] use-chaining [if]
    field:  vect-datap
    cfield: vect-traceentry
    : vect-data vect-datap @ ;
    aligned
[else]
    simd-size naligned
    0 +field vect-data
[then]
constant /vect
synonym vect /vect

\ type descriptors

0
field: type-@ \ xt of e.g., f@
field: type-! \ xt of e.g., f!
field: type-dup  \ xt of e.g., fdup
field: type-over \ xt of e.g., fover
field: type-drop \ xt of e.g., fdrop
field: type-size \ number of bytes
constant type-descriptor

[undefined] sb@ [if]
    [undefined] c>s [if]
	: masksx ( w1 mask -- w2 )
	    \ apply the mask of the form 0..01..1 in a sign-extending way
	    2dup dup 1 rshift invert and and 0<> ( w1 mask fneg )
	    over invert and ( w1 mask highbits )
	    rot rot and or ;
	: c>s $ff   masksx ;
    [then]

    : sb@ ( c-addr -- n )
	c@ c>s ;
[then]

create  b-type ' sb@ , '  c! , '  dup , '  over , '  drop , 1 , 
create ub-type '  c@ , '  c! , '  dup , '  over , '  drop , 1 , 
create  w-type ' sw@ , '  w! , '  dup , '  over , '  drop , 2 , 
create uw-type ' uw@ , '  w! , '  dup , '  over , '  drop , 2 , 
create  l-type ' sl@ , '  l! , '  dup , '  over , '  drop , 4 , 
create ul-type ' ul@ , '  l! , '  dup , '  over , '  drop , 4 , 
1 cells 8 = [if]
create  x-type ' sx@ , '  x! , '  dup , '  over , '  drop , 8 , 
create ux-type ' ux@ , '  x! , '  dup , '  over , '  drop , 8 ,
[then]
create sf-type ' sf@ , ' sf! , ' fdup , ' fover , ' fdrop , 4 ,
create df-type ' df@ , ' df! , ' fdup , ' fover , ' fdrop , 8 ,

[undefined] use-scalar [undefined] use-chaining and [if]
    s" gforth" environment? [if]
	2drop
	include vectors-gforth.4th
    [then]
    \ insert other system-specific includes here
[then]

[undefined] aligned_alloc [if]
    : aligned_alloc nip allocate throw ;
[then]

\ vector management

#10 constant vect-stack-items
create vect-stack vect-stack-items cells allot

variable vsp \ vector stack pointer
vect-stack vect-stack-items cells + vsp !

s" buffer/vector length mismatch" exception constant vbuflen-ex
s" vector length mismatch" exception constant vectlen-ex

: >v ( vect -- v )
    vsp @ [ -1 cells ] literal + dup vsp ! ! ;

: v> ( v -- vect )
    vsp @ dup cell+ vsp ! @ ;

[undefined] use-chaining [if]
: vect-free ( vect -- )
    [defined] use-refcount [if]
	?dup-if
	    dup vect-refs @ if
		-1 swap vect-refs +!
	    else
		free throw then
	then
    [else]
	free throw
    [then] ;

: vect-alloc ( u -- vect )
    vector-granularity 2dup naligned vect-data aligned_alloc dup 0= -59 and throw >r
    [defined] use-refcount [if]
	0 r@ vect-refs !
    [then]
    r@ vect-bytes !
    r> ;

: finish-trace ; immediate \ a noop when not chaining
[then]

: short-vect. ( vect -- )
    [defined] use-refcount [if] ." refs=" dup vect-refs @ 1 .r [then]
    ."  bytes=" dup vect-bytes @ dup 2 .r ;

: vect. ( vect -- )
    cr dup short-vect.
    4 dfloats min 0 do
	dup vect-data i + df@ 7 5 1 space f.rdp
    1 dfloats +loop
    drop ;

: v.s ( -- )
    vect-stack vect-stack-items th vsp @ ?do
	i @ vect.
    1 cells +loop ;

\ locals are used in the gen-...-inner words, to avoid needing to know
\ the stack effect of the type-@ words.  This necessitates EVALUATE,
\ but fortunately, these are internal-use words, so we control the
\ environment.

: ignore-undefined-type ( xt "name" "replacement" "type" "word" -- xt "name" "replacement" "type" "word" false | true )
    \ skip this set of inputs if type is unknown
    >in @ parse-name 2drop parse-name {: d: repl :} bl word find 0<>
    [defined] use-chaining [if]
	repl find-name 0<> and [then]
    if
	drop >in ! false exit then
    parse-name 2drop 2drop true ;

: type?exit ]] ignore-undefined-type if exit then [[ ; immediate


[defined] use-chaining [if]
    require chaining.4th
[else]

: genv-binary-inner ( "replacement" "type" "word" -- )
    ( run-time: addr1 addr2 addr u -- )
    >in @ postpone [defined] if \ replacement present
	>in ! parse-name evaluate parse-name 2drop parse-name 2drop
    else
	drop ' execute >r
	s" {: addr1 addr2 addr u :} u" evaluate
	]] vect-data [[ 0 vect-data ]] literal ?do
	    [[ s" addr1" evaluate ]] i + [[ r@ type-@ @ compile, ]]
	    [[ s" addr2" evaluate ]] i + [[ r@ type-@ @ compile,
	    parse-name evaluate 
	    s" addr" evaluate ]] i + [[ r@ type-! @ compile,
	r> type-size @ ]] literal +loop
	[[
    then ;

: genv-binary ( xt "name" "replacement" "type" "word" -- )
    type?exit : ]] vsp @ dup @ >r cell+ @ [[ ( r:vect1 vect2 ) ]]
    r@ vect-bytes @ over vect-bytes @ <> vectlen-ex and throw
    [[ [defined] use-refcount [if] ]]
	r@ vect-refs @ if
	    [[ -1 ]] literal r@ vect-refs +!
	    dup vect-refs @ if
		[[ -1 ]] literal over vect-refs +!
		r@ vect-bytes @ vect-alloc [[ ( r:vect1 vect2 vect ) ]]
	    else
		dup then
	else
	    r@ then [[
    [else]
	]] r@ [[
    [then] ]]
    [[ ( r:vect1 vect2 vect ) ]]
    r@ dup 2over r> vect-bytes @ [[ genv-binary-inner ]]
    [[ ( vect2 vect vect1 ) ]]
    [[ [defined] use-refcount [if] ]]
	over = if
	    over vect-free then
	nip
    [[ [else] ]]
	drop swap vect-free
    [[ [then] ]]
    vsp @ cell+ dup vsp ! ! ; [[ ;

: genv-unary-inner ( "replacement" "type" "word" -- )
    ( run-time: addr1 addr u -- )
    >in @ postpone [defined] if \ replacement present
	>in ! parse-name evaluate parse-name 2drop parse-name 2drop
    else
	drop ' execute >r
	s" {: addr1 addr u :} u" evaluate
	]] vect-data [[ 0 vect-data ]] literal ?do
	    [[ s" addr1" evaluate ]] i + [[ r@ type-@ @ compile,
	    parse-name evaluate
	    s" addr" evaluate ]] i + [[ r@ type-! @ compile,
	r> type-size @ ]] literal +loop
	[[
    then ;

: genv-unary-result ( -- ) ( run-time: r:vect1 -- r:vect1 vect )
    [defined] use-refcount [if]
	]] r@ vect-refs @ if
	    [[ -1 ]]L r@ vect-refs +!
	    r@ vect-bytes @ vect-alloc dup vsp @ !
	else
	    r@
	then [[
    [else]
	]] r@ [[
    [then] ;

: genv-unary ( xt "name" "replacement" "type" "word" -- )
    type?exit : ]] vsp @ @ >r [[ genv-unary-result ]]
    r@ swap r@ vect-bytes @
    [[ genv-unary-inner ]] ; [[ ;

: genvs-inner ( "replacement" "type" "word" -- )
    ( run-time: x|r addr1 addr u -- )
    >in @ postpone [defined] if \ replacement present
	>in ! parse-name evaluate parse-name 2drop parse-name 2drop
    else
	drop ' execute >r
	s" {: addr1 addr u :} u" evaluate
	]] vect-data [[ 0 vect-data ]] literal ?do
	    [[ s" addr1" evaluate ]] i + [[ r@ type-@ @ compile,
	    r@ type-over @ compile,
	    parse-name evaluate
	    s" addr" evaluate ]] i + [[ r@ type-! @ compile,
	r@ type-size @ ]] literal +loop
	[[ r> type-drop @ compile,
    then ;

: genvs ( xt "name" "replacement" "type" "word" -- )
    type?exit : ]] vsp @ @ >r [[ genv-unary-result ]]
    r@ swap r> vect-bytes @
    [[ genvs-inner ]] ; [[ ;

: gensv-inner ( "replacement" "type" "word" -- )
    ( run-time: x|r addr1 addr u -- )
    >in @ postpone [defined] if \ replacement present
	>in ! parse-name evaluate parse-name 2drop parse-name 2drop
    else
	drop ' execute >r
	s" {: addr2 addr u :} u" evaluate
	]] vect-data [[ 0 vect-data ]] literal ?do
	    [[ r@ type-dup @ compile,
	    s" addr2" evaluate ]] i + [[ r@ type-@ @ compile,
	    parse-name evaluate
	    s" addr" evaluate ]] i + [[ r@ type-! @ compile,
	r@ type-size @ ]] literal +loop
	[[ r> type-drop @ compile,
    then ;

: gensv ( xt "name" "replacement" "type" "word" -- )
    type?exit : ]] vsp @ @ >r [[ genv-unary-result ]]
    r@ swap r> vect-bytes @
    [[ gensv-inner ]] ; [[ ;

: genv-ternary-inner ( "replacement" "type" "word" -- )
    ( run-time: addr1 addr2 addr3 addr u -- )
    >in @ postpone [defined] if \ replacement present
	>in ! parse-name evaluate parse-name 2drop parse-name 2drop
    else
	drop ' execute >r
	s" {: addr1 addr2 addr3 addr u :} u" evaluate
	]] vect-data [[ 0 vect-data ]] literal ?do
	    [[ s" addr1" evaluate ]] i + [[ r@ type-@ @ compile, ]]
	    [[ s" addr2" evaluate ]] i + [[ r@ type-@ @ compile, ]]
	    [[ s" addr3" evaluate ]] i + [[ r@ type-@ @ compile, ]]
	    [[ parse-name evaluate
	    s" addr" evaluate ]] i + [[ r@ type-! @ compile,
	r> type-size @ ]] literal +loop
	[[
    then ;

: [genv-ternary-inner] genv-ternary-inner ; immediate

: ?vectlen ( vect u -- vect )
    over vect-bytes @ <> vectlen-ex and throw ;

\ public vector words

: muxv ( v1 v2 v3 -- v )
    vsp @ dup 2 cells + @ dup vect-bytes @ >r
    over cell+ @ r@ ?vectlen rot @ r@ ?vectlen ( vect1 vect2 vect3 )
    r@ vect-alloc ( vect1 vect2 vect3 vect )
    2over 2over r@
    [genv-ternary-inner] bmuxv_ b-type mux
    r> drop >r vect-free vect-free vect-free r> ( r:vect )
    vsp @ [ 2 cells ] literal + dup vsp ! ! ;
[then]

  genv-binary       b+v    bplusv_  b-type +
  genv-binary       w+v    wplusv_  w-type +
  genv-binary       l+v    lplusv_  l-type +
  genv-binary       x+v    xplusv_  x-type +
  genv-binary      sf+v   sfplusv_ sf-type f+
  genv-binary      df+v   dfplusv_ df-type f+
  genv-binary       b-v   bminusv_  b-type -
  genv-binary       w-v   wminusv_  w-type -
  genv-binary       l-v   lminusv_  l-type -
  genv-binary       x-v   xminusv_  x-type -
  genv-binary      sf-v  sfminusv_ sf-type f-
  genv-binary      df-v  dfminusv_ df-type f-
  genv-unary   bnegatev  bnegatev_  b-type negate
  genv-unary   wnegatev  wnegatev_  w-type negate
  genv-unary   lnegatev  lnegatev_  l-type negate
  genv-unary   xnegatev  xnegatev_  x-type negate
  genv-unary  sfnegatev sfnegatev_ sf-type fnegate
  genv-unary  dfnegatev dfnegatev_ df-type fnegate
  genv-unary      babsv     babsv_  b-type abs
  genv-unary      wabsv     wabsv_  w-type abs
  genv-unary      labsv     labsv_  l-type abs
  genv-unary      xabsv     xabsv_  x-type abs
  genv-unary     sfabsv    sfabsv_ sf-type fabs
  genv-unary     dfabsv    dfabsv_ df-type fabs
  genv-binary       b*v   btimesv_  b-type *
  genv-binary       w*v   wtimesv_  w-type *
  genv-binary       l*v   ltimesv_  l-type *
  genv-binary       x*v   xtimesv_  x-type *
  genv-binary      sf*v  sftimesv_ sf-type f*
  genv-binary      df*v  dftimesv_ df-type f*
  genv-binary       b/v   bslashv_  b-type /
  genv-binary       w/v   wslashv_  w-type /
  genv-binary       l/v   lslashv_  l-type /
  genv-binary       x/v   xslashv_  x-type /
  genv-binary      ub/v  ubslashv_ ub-type u/
  genv-binary      uw/v  uwslashv_ uw-type u/
  genv-binary      ul/v  ulslashv_ ul-type u/
  genv-binary      ux/v  uxslashv_ ux-type u/
  genv-binary      sf/v  sfslashv_ sf-type f/
  genv-binary      df/v  dfslashv_ df-type f/
  genv-binary     bmodv     bmodv_  b-type mod
  genv-binary     wmodv     wmodv_  w-type mod
  genv-binary     lmodv     lmodv_  l-type mod
  genv-binary     xmodv     xmodv_  x-type mod
  genv-binary    ubmodv    ubmodv_ ub-type umod
  genv-binary    uwmodv    uwmodv_ uw-type umod
  genv-binary    ulmodv    ulmodv_ ul-type umod
  genv-binary    uxmodv    uxmodv_ ux-type umod
  genv-binary      andv     bandv_  b-type and
  genv-binary       orv      borv_  b-type or
  genv-binary      xorv     bxorv_  b-type xor
  genv-unary    invertv  binvertv_  b-type invert
  genv-binary  blshiftv  blshiftv_  b-type lshift
  genv-binary  wlshiftv  wlshiftv_  w-type lshift
  genv-binary  llshiftv  llshiftv_  l-type lshift
  genv-binary  xlshiftv  xlshiftv_  x-type lshift
  genv-binary  brshiftv  brshiftv_  b-type arshift
  genv-binary  wrshiftv  wrshiftv_  w-type arshift
  genv-binary  lrshiftv  lrshiftv_  l-type arshift
  genv-binary  xrshiftv  xrshiftv_  x-type arshift
  genv-binary ubrshiftv ubrshiftv_ ub-type rshift
  genv-binary uwrshiftv uwrshiftv_ uw-type rshift
  genv-binary ulrshiftv ulrshiftv_ ul-type rshift
  genv-binary uxrshiftv uxrshiftv_ ux-type rshift
  genv-binary       b<v      bltv_  b-type <
  genv-binary       w<v      wltv_  w-type <
  genv-binary       l<v      lltv_  l-type <
  genv-binary       x<v      xltv_  x-type <
  genv-binary      ub<v     ubltv_ ub-type u<
  genv-binary      uw<v     uwltv_ uw-type u<
  genv-binary      ul<v     ulltv_ ul-type u<
  genv-binary      ux<v     uxltv_ ux-type u<
  genv-binary      sf<v     sfltv_ sf-type f<
  genv-binary      df<v     dfltv_ df-type f<
  genv-binary       b=v      beqv_  b-type =
  genv-binary       w=v      weqv_  w-type =
  genv-binary       l=v      leqv_  l-type =
  genv-binary       x=v      xeqv_  x-type =
  genv-binary      sf=v     sfeqv_ sf-type f=
  genv-binary      df=v     dfeqv_ df-type f=
  genv-binary       b>v      bgtv_  b-type >
  genv-binary       w>v      wgtv_  w-type >
  genv-binary       l>v      lgtv_  l-type >
  genv-binary       x>v      xgtv_  x-type >
  genv-binary      ub>v     ubgtv_ ub-type u>
  genv-binary      uw>v     uwgtv_ uw-type u>
  genv-binary      ul>v     ulgtv_ ul-type u>
  genv-binary      ux>v     uxgtv_ ux-type u>
  genv-binary      sf>v     sfgtv_ sf-type f>
  genv-binary      df>v     dfgtv_ df-type f>
  genv-binary      b<=v      blev_  b-type <=
  genv-binary      w<=v      wlev_  w-type <=
  genv-binary      l<=v      llev_  l-type <=
  genv-binary      x<=v      xlev_  x-type <=
  genv-binary     ub<=v     ublev_ ub-type u<=
  genv-binary     uw<=v     uwlev_ uw-type u<=
  genv-binary     ul<=v     ullev_ ul-type u<=
  genv-binary     ux<=v     uxlev_ ux-type u<=
  genv-binary     sf<=v     sflev_ sf-type f<=
  genv-binary     df<=v     dflev_ df-type f<=
  genv-binary      b>=v      bgev_  b-type >=
  genv-binary      w>=v      wgev_  w-type >=
  genv-binary      l>=v      lgev_  l-type >=
  genv-binary      x>=v      xgev_  x-type >=
  genv-binary     ub>=v     ubgev_ ub-type u>=
  genv-binary     uw>=v     uwgev_ uw-type u>=
  genv-binary     ul>=v     ulgev_ ul-type u>=
  genv-binary     ux>=v     uxgev_ ux-type u>=
  genv-binary     sf>=v     sfgev_ sf-type f>=
  genv-binary     df>=v     dfgev_ df-type f>=
  genv-binary      b<>v      bnev_  b-type <>
  genv-binary      w<>v      wnev_  w-type <>
  genv-binary      l<>v      lnev_  l-type <>
  genv-binary      x<>v      xnev_  x-type <>
  genv-binary     sf<>v     sfnev_ sf-type f<>
  genv-binary     df<>v     dfnev_ df-type f<>
  genv-binary     bmaxv     bmaxv_  b-type max
  genv-binary     wmaxv     wmaxv_  w-type max
  genv-binary     lmaxv     lmaxv_  l-type max
  genv-binary     xmaxv     xmaxv_  x-type max
  genv-binary    ubmaxv    ubmaxv_ ub-type umax
  genv-binary    uwmaxv    uwmaxv_ uw-type umax
  genv-binary    ulmaxv    ulmaxv_ ul-type umax
  genv-binary    uxmaxv    uxmaxv_ ux-type umax
  genv-binary    sfmaxv    sfmaxv_ sf-type fmax
  genv-binary    dfmaxv    dfmaxv_ df-type fmax
  genv-binary     bminv     bminv_  b-type min
  genv-binary     wminv     wminv_  w-type min
  genv-binary     lminv     lminv_  l-type min
  genv-binary     xminv     xminv_  x-type min
  genv-binary    ubminv    ubminv_ ub-type umin
  genv-binary    uwminv    uwminv_ uw-type umin
  genv-binary    ulminv    ulminv_ ul-type umin
  genv-binary    uxminv    uxminv_ ux-type umin
  genv-binary    sfminv    sfminv_ sf-type fmin
  genv-binary    dfminv    dfminv_ df-type fmin

  genvs       b+vs    bplusvs_  b-type +
  genvs       w+vs    wplusvs_  w-type +
  genvs       l+vs    lplusvs_  l-type +
  genvs       x+vs    xplusvs_  x-type +
  genvs      sf+vs   sfplusvs_ sf-type f+
  genvs      df+vs   dfplusvs_ df-type f+
  genvs       b-vs   bminusvs_  b-type -
  genvs       w-vs   wminusvs_  w-type -
  genvs       l-vs   lminusvs_  l-type -
  genvs       x-vs   xminusvs_  x-type -
  genvs      sf-vs  sfminusvs_ sf-type f-
  genvs      df-vs  dfminusvs_ df-type f-
  genvs       b*vs   btimesvs_  b-type *
  genvs       w*vs   wtimesvs_  w-type *
  genvs       l*vs   ltimesvs_  l-type *
  genvs       x*vs   xtimesvs_  x-type *
  genvs      sf*vs  sftimesvs_ sf-type f*
  genvs      df*vs  dftimesvs_ df-type f*
  genvs       b/vs   bslashvs_  b-type /
  genvs       w/vs   wslashvs_  w-type /
  genvs       l/vs   lslashvs_  l-type /
  genvs       x/vs   xslashvs_  x-type /
  genvs      ub/vs  ubslashvs_ ub-type u/
  genvs      uw/vs  uwslashvs_ uw-type u/
  genvs      ul/vs  ulslashvs_ ul-type u/
  genvs      ux/vs  uxslashvs_ ux-type u/
  genvs      sf/vs  sfslashvs_ sf-type f/
  genvs      df/vs  dfslashvs_ df-type f/
  genvs     bmodvs     bmodvs_  b-type mod
  genvs     wmodvs     wmodvs_  w-type mod
  genvs     lmodvs     lmodvs_  l-type mod
  genvs     xmodvs     xmodvs_  x-type mod
  genvs    ubmodvs    ubmodvs_ ub-type umod
  genvs    uwmodvs    uwmodvs_ uw-type umod
  genvs    ulmodvs    ulmodvs_ ul-type umod
  genvs    uxmodvs    uxmodvs_ ux-type umod
  genvs      andvs     bandvs_  b-type and
  genvs       orvs      borvs_  b-type or
  genvs      xorvs     bxorvs_  b-type xor
  genvs  blshiftvs  blshiftvs_  b-type lshift
  genvs  wlshiftvs  wlshiftvs_  w-type lshift
  genvs  llshiftvs  llshiftvs_  l-type lshift
  genvs  xlshiftvs  xlshiftvs_  x-type lshift
  genvs  brshiftvs  brshiftvs_  b-type arshift
  genvs  wrshiftvs  wrshiftvs_  w-type arshift
  genvs  lrshiftvs  lrshiftvs_  l-type arshift
  genvs  xrshiftvs  xrshiftvs_  x-type arshift
  genvs ubrshiftvs ubrshiftvs_ ub-type rshift
  genvs uwrshiftvs uwrshiftvs_ uw-type rshift
  genvs ulrshiftvs ulrshiftvs_ ul-type rshift
  genvs uxrshiftvs uxrshiftvs_ ux-type rshift
  genvs       b<vs      bltvs_  b-type <
  genvs       w<vs      wltvs_  w-type <
  genvs       l<vs      lltvs_  l-type <
  genvs       x<vs      xltvs_  x-type <
  genvs      ub<vs     ubltvs_ ub-type u<
  genvs      uw<vs     uwltvs_ uw-type u<
  genvs      ul<vs     ulltvs_ ul-type u<
  genvs      ux<vs     uxltvs_ ux-type u<
  genvs      sf<vs     sfltvs_ sf-type f<
  genvs      df<vs     dfltvs_ df-type f<
  genvs       b=vs      beqvs_  b-type =
  genvs       w=vs      weqvs_  w-type =
  genvs       l=vs      leqvs_  l-type =
  genvs       x=vs      xeqvs_  x-type =
  genvs      sf=vs     sfeqvs_ sf-type f=
  genvs      df=vs     dfeqvs_ df-type f=
  genvs       b>vs      bgtvs_  b-type >
  genvs       w>vs      wgtvs_  w-type >
  genvs       l>vs      lgtvs_  l-type >
  genvs       x>vs      xgtvs_  x-type >
  genvs      ub>vs     ubgtvs_ ub-type u>
  genvs      uw>vs     uwgtvs_ uw-type u>
  genvs      ul>vs     ulgtvs_ ul-type u>
  genvs      ux>vs     uxgtvs_ ux-type u>
  genvs      sf>vs     sfgtvs_ sf-type f>
  genvs      df>vs     dfgtvs_ df-type f>
  genvs      b<=vs      blevs_  b-type <=
  genvs      w<=vs      wlevs_  w-type <=
  genvs      l<=vs      llevs_  l-type <=
  genvs      x<=vs      xlevs_  x-type <=
  genvs     ub<=vs     ublevs_ ub-type u<=
  genvs     uw<=vs     uwlevs_ uw-type u<=
  genvs     ul<=vs     ullevs_ ul-type u<=
  genvs     ux<=vs     uxlevs_ ux-type u<=
  genvs     sf<=vs     sflevs_ sf-type f<=
  genvs     df<=vs     dflevs_ df-type f<=
  genvs      b>=vs      bgevs_  b-type >=
  genvs      w>=vs      wgevs_  w-type >=
  genvs      l>=vs      lgevs_  l-type >=
  genvs      x>=vs      xgevs_  x-type >=
  genvs     ub>=vs     ubgevs_ ub-type u>=
  genvs     uw>=vs     uwgevs_ uw-type u>=
  genvs     ul>=vs     ulgevs_ ul-type u>=
  genvs     ux>=vs     uxgevs_ ux-type u>=
  genvs     sf>=vs     sfgevs_ sf-type f>=
  genvs     df>=vs     dfgevs_ df-type f>=
  genvs      b<>vs      bnevs_  b-type <>
  genvs      w<>vs      wnevs_  w-type <>
  genvs      l<>vs      lnevs_  l-type <>
  genvs      x<>vs      xnevs_  x-type <>
  genvs     sf<>vs     sfnevs_ sf-type f<>
  genvs     df<>vs     dfnevs_ df-type f<>
  genvs     bmaxvs     bmaxvs_  b-type max
  genvs     wmaxvs     wmaxvs_  w-type max
  genvs     lmaxvs     lmaxvs_  l-type max
  genvs     xmaxvs     xmaxvs_  x-type max
  genvs    ubmaxvs    ubmaxvs_ ub-type umax
  genvs    uwmaxvs    uwmaxvs_ uw-type umax
  genvs    ulmaxvs    ulmaxvs_ ul-type umax
  genvs    uxmaxvs    uxmaxvs_ ux-type umax
  genvs    sfmaxvs    sfmaxvs_ sf-type fmax
  genvs    dfmaxvs    dfmaxvs_ df-type fmax
  genvs     bminvs     bminvs_  b-type min
  genvs     wminvs     wminvs_  w-type min
  genvs     lminvs     lminvs_  l-type min
  genvs     xminvs     xminvs_  x-type min
  genvs    ubminvs    ubminvs_ ub-type umin
  genvs    uwminvs    uwminvs_ uw-type umin
  genvs    ulminvs    ulminvs_ ul-type umin
  genvs    uxminvs    uxminvs_ ux-type umin
  genvs    sfminvs    sfminvs_ sf-type fmin
  genvs    dfminvs    dfminvs_ df-type fmin

  gensv       b-sv   bminussv_  b-type -
  gensv       w-sv   wminussv_  w-type -
  gensv       l-sv   lminussv_  l-type -
  gensv       x-sv   xminussv_  x-type -
  gensv      sf-sv  sfminussv_ sf-type f-
  gensv      df-sv  dfminussv_ df-type f-
  gensv       b/sv   bslashsv_  b-type /
  gensv       w/sv   wslashsv_  w-type /
  gensv       l/sv   lslashsv_  l-type /
  gensv       x/sv   xslashsv_  x-type /
  gensv      ub/sv  ubslashsv_ ub-type u/
  gensv      uw/sv  uwslashsv_ uw-type u/
  gensv      ul/sv  ulslashsv_ ul-type u/
  gensv      ux/sv  uxslashsv_ ux-type u/
  gensv      sf/sv  sfslashsv_ sf-type f/
  gensv      df/sv  dfslashsv_ df-type f/
  gensv     bmodsv     bmodsv_  b-type mod
  gensv     wmodsv     wmodsv_  w-type mod
  gensv     lmodsv     lmodsv_  l-type mod
  gensv     xmodsv     xmodsv_  x-type mod
  gensv    ubmodsv    ubmodsv_ ub-type umod
  gensv    uwmodsv    uwmodsv_ uw-type umod
  gensv    ulmodsv    ulmodsv_ ul-type umod
  gensv    uxmodsv    uxmodsv_ ux-type umod
  gensv  blshiftsv  blshiftsv_  b-type lshift
  gensv  wlshiftsv  wlshiftsv_  w-type lshift
  gensv  llshiftsv  llshiftsv_  l-type lshift
  gensv  xlshiftsv  xlshiftsv_  x-type lshift
  gensv  brshiftsv  brshiftsv_  b-type arshift
  gensv  wrshiftsv  wrshiftsv_  w-type arshift
  gensv  lrshiftsv  lrshiftsv_  l-type arshift
  gensv  xrshiftsv  xrshiftsv_  x-type arshift
  gensv ubrshiftsv ubrshiftsv_ ub-type rshift
  gensv uwrshiftsv uwrshiftsv_ uw-type rshift
  gensv ulrshiftsv ulrshiftsv_ ul-type rshift
  gensv uxrshiftsv uxrshiftsv_ ux-type rshift
  gensv       b<sv      bltsv_  b-type <
  gensv       w<sv      wltsv_  w-type <
  gensv       l<sv      lltsv_  l-type <
  gensv       x<sv      xltsv_  x-type <
  gensv      ub<sv     ubltsv_ ub-type u<
  gensv      uw<sv     uwltsv_ uw-type u<
  gensv      ul<sv     ulltsv_ ul-type u<
  gensv      ux<sv     uxltsv_ ux-type u<
  gensv      sf<sv     sfltsv_ sf-type f<
  gensv      df<sv     dfltsv_ df-type f<
  gensv       b>sv      bgtsv_  b-type >
  gensv       w>sv      wgtsv_  w-type >
  gensv       l>sv      lgtsv_  l-type >
  gensv       x>sv      xgtsv_  x-type >
  gensv      ub>sv     ubgtsv_ ub-type u>
  gensv      uw>sv     uwgtsv_ uw-type u>
  gensv      ul>sv     ulgtsv_ ul-type u>
  gensv      ux>sv     uxgtsv_ ux-type u>
  gensv      sf>sv     sfgtsv_ sf-type f>
  gensv      df>sv     dfgtsv_ df-type f>
  gensv      b<=sv      blesv_  b-type <=
  gensv      w<=sv      wlesv_  w-type <=
  gensv      l<=sv      llesv_  l-type <=
  gensv      x<=sv      xlesv_  x-type <=
  gensv     ub<=sv     ublesv_ ub-type u<=
  gensv     uw<=sv     uwlesv_ uw-type u<=
  gensv     ul<=sv     ullesv_ ul-type u<=
  gensv     ux<=sv     uxlesv_ ux-type u<=
  gensv     sf<=sv     sflesv_ sf-type f<=
  gensv     df<=sv     dflesv_ df-type f<=
  gensv      b>=sv      bgesv_  b-type >=
  gensv      w>=sv      wgesv_  w-type >=
  gensv      l>=sv      lgesv_  l-type >=
  gensv      x>=sv      xgesv_  x-type >=
  gensv     ub>=sv     ubgesv_ ub-type u>=
  gensv     uw>=sv     uwgesv_ uw-type u>=
  gensv     ul>=sv     ulgesv_ ul-type u>=
  gensv     ux>=sv     uxgesv_ ux-type u>=
  gensv     sf>=sv     sfgesv_ sf-type f>=
  gensv     df>=sv     dfgesv_ df-type f>=

: b@v ( c-addr u -- v )
    dup vect-alloc >r
    r@ vect-data swap ( from to count )
    2dup 1- [ vector-granularity negate ] literal and + vector-granularity erase
    move
    r> >v ;

: b!v ( v c-addr u -- )
    finish-trace
    v> >r
    r@ vect-bytes @ over <> vbuflen-ex and throw
    r@ vect-data rot rot move
    r> vect-free ;

: v@ ( v-addr -- v )
    [defined] use-refcount [if]
	@ dup >v
	1 swap vect-refs +!
    [else]
	@ dup vect-bytes @ dup >r vect-alloc ( v1 v R:u )
	tuck vect-data swap vect-data swap r> vector-granularity naligned move >v
    [then] ;

: v@' ( v-addr -- v )
    dup @ >v
    0 swap ! ;

: v! ( v v-addr -- )
    dup @ vect-free
    v> swap ! ;

: vpick ( vu ... v0 u -- vu )
    cells vsp @ + v@ ;

: vdup ( v -- v v )
    0 vpick ;

: vover ( v1 v2 -- v1 v2 v1 )
    1 vpick ;

: vswap ( v1 v2 -- v2 v1 )
    vsp @ dup 2@ swap rot 2! ;

: vrot ( v1 v2 v3 -- v2 v3 v1 )
    vsp @ dup >r 2@ r@ [ 2 cells ] literal + @ r@ ! r> cell+ 2! ;

: vroll ( vu ... v0 u -- vu-1 .. v1 vu )
    cells >r vsp @ dup r@ + @ swap ( vectu addr r:ucells )
    dup dup cell+ r> move ! ;
