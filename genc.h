\c #define myabs(v) ((v + (v < 0)) ^ (v < 0))
\c #define maxvv(v1,v2) (((v1 >= v2) & (v1 ^ v2)) ^ v2)
\c #define minvv(v1,v2) (((v1 >= v2) & (v1 ^ v2)) ^ v1)
