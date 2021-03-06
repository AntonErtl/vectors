\ Copyright 2007 Stephen Pelc

: begin-structure       \ -- addr 0 ; -- size
\ *G Begin definition of a new structure. Use in the form
\ ** *\fo{BEGIN-STRUCTURE <name>}. At run time *\fo{<name>}
\ ** returns the size of the structure.
  create
    here 0  0 ,                         \ mark stack, lay dummy
  does> @  ;                            \ -- rec-len

: end-structure         \ addr n --
\ *G Terminate definition of a structure.
  swap !  ;                             \ set len

: +FIELD                 \ n <"name"> -- ; Exec: addr -- 'addr
\ *G Create a new field within a structure definition of size n bytes.
  create
    over , +
  does>
    @ +
;

: cfield:       \ n1 <"name"> -- n2 ; Exec: addr -- 'addr
\ *G Create a new field within a structure definition of size 1 CHARS.
  1 chars +FIELD
;

: field:        \ n1 <"name"> -- n2 ; Exec: addr -- 'addr
\ *G Create a new field within a structure definition of size 1 CELLS.
\ ** The field is ALIGNED.
  aligned  1 cells +FIELD
;

: ffield:       \ n1 <"name"> -- n2 ; Exec: addr -- 'addr
\ *G Create a new field within a structure definition of size 1 FLOATS.
\ ** The field is FALIGNED.
  faligned  1 floats +FIELD
;

: sffield:      \ n1 <"name"> -- n2 ; Exec: addr -- 'addr
\ *G Create a new field within a structure definition of size 1 SFLOATS.
\ ** The field is SFALIGNED.
  sfaligned  1 sfloats +FIELD
;

: dffield:      \ n1 <"name"> -- n2 ; Exec: addr -- 'addr
\ *G Create a new field within a structure definition of size 1 DFLOATS.
\ ** The field is DFALIGNED.
  dfaligned  1 dfloats +FIELD
;
