\ c code generation helper words

genv-binary-c    bplusv_  vb t varg "+ " gen t varg
genv-binary-c    wplusv_  vw t varg "+ " gen t varg  
genv-binary-c    lplusv_  vl t varg "+ " gen t varg  
genv-binary-c    xplusv_  vx t varg "+ " gen t varg  
genv-binary-c   sfplusv_ vsf t varg "+ " gen t varg
genv-binary-c   dfplusv_ vdf t varg "+ " gen t varg
genv-binary-c   bminusv_  vb t varg "- " gen t varg  
genv-binary-c   wminusv_  vw t varg "- " gen t varg  
genv-binary-c   lminusv_  vl t varg "- " gen t varg  
genv-binary-c   xminusv_  vx t varg "- " gen t varg  
genv-binary-c  sfminusv_ vsf t varg "- " gen t varg
genv-binary-c  dfminusv_ vdf t varg "- " gen t varg
genv-unary-c   bnegatev_  vb "-" gen t varg drop  
genv-unary-c   wnegatev_  vw "-" gen t varg drop  
genv-unary-c   lnegatev_  vl "-" gen t varg drop  
genv-unary-c   xnegatev_  vx "-" gen t varg drop  
genv-unary-c  sfnegatev_ vsf "-" gen t varg drop
genv-unary-c  dfnegatev_ vdf "-" gen t varg drop
genv-unary-c      babsv_  vb "myabs(" gen t varg ")" gen drop  
genv-unary-c      wabsv_  vw "myabs(" gen t varg ")" gen drop  
genv-unary-c      labsv_  vl "myabs(" gen t varg ")" gen drop  
genv-unary-c      xabsv_  vx "myabs(" gen t varg ")" gen drop  
\ genv-unary-c     sfabsv_ vsf "myabs(" gen t varg ")" gen drop
\ genv-unary-c     dfabsv_ vdf "myabs(" gen t varg ")" gen drop
genv-binary-c   btimesv_  vb t varg "* " gen t varg  
genv-binary-c   wtimesv_  vw t varg "* " gen t varg  
genv-binary-c   ltimesv_  vl t varg "* " gen t varg  
genv-binary-c   xtimesv_  vx t varg "* " gen t varg  
genv-binary-c  sftimesv_ vsf t varg "* " gen t varg
genv-binary-c  dftimesv_ vdf t varg "* " gen t varg
genv-binary-c   bslashv_  vb t varg "/ " gen t varg  
genv-binary-c   wslashv_  vw t varg "/ " gen t varg  
genv-binary-c   lslashv_  vl t varg "/ " gen t varg  
genv-binary-c   xslashv_  vx t varg "/ " gen t varg  
genv-binary-c  ubslashv_ vub t varg "/ " gen t varg  
genv-binary-c  uwslashv_ vuw t varg "/ " gen t varg  
genv-binary-c  ulslashv_ vul t varg "/ " gen t varg  
genv-binary-c  uxslashv_ vux t varg "/ " gen t varg  
genv-binary-c  sfslashv_ vsf t varg "/ " gen t varg
genv-binary-c  dfslashv_ vdf t varg "/ " gen t varg
genv-binary-c     bmodv_  vb t varg "% " gen t varg  
genv-binary-c     wmodv_  vw t varg "% " gen t varg  
genv-binary-c     lmodv_  vl t varg "% " gen t varg  
genv-binary-c     xmodv_  vx t varg "% " gen t varg  
genv-binary-c    ubmodv_ vub t varg "% " gen t varg  
genv-binary-c    uwmodv_ vuw t varg "% " gen t varg  
genv-binary-c    ulmodv_ vul t varg "% " gen t varg  
genv-binary-c    uxmodv_ vux t varg "% " gen t varg  
genv-binary-c     bandv_  vb t varg "& " gen t varg  
genv-binary-c      borv_  vb t varg "| " gen t varg  
genv-binary-c     bxorv_  vb t varg "^ " gen t varg
genv-unary-c   binvertv_  vb "~" gen t varg drop
\ genv-ternary-c    bmuxv_  vb (*v1 & *v3) | (*v2 & ~*v3)
genv-binary-c  blshiftv_  vb t varg "<<" gen t varg   
genv-binary-c  wlshiftv_  vw t varg "<<" gen t varg   
genv-binary-c  llshiftv_  vl t varg "<<" gen t varg   
genv-binary-c  xlshiftv_  vx t varg "<<" gen t varg   
genv-binary-c  brshiftv_  vb t varg ">>" gen t varg   
genv-binary-c  wrshiftv_  vw t varg ">>" gen t varg   
genv-binary-c  lrshiftv_  vl t varg ">>" gen t varg   
genv-binary-c  xrshiftv_  vx t varg ">>" gen t varg   
genv-binary-c ubrshiftv_ vub t varg ">>" gen t varg   
genv-binary-c uwrshiftv_ vuw t varg ">>" gen t varg   
genv-binary-c ulrshiftv_ vul t varg ">>" gen t varg   
genv-binary-c uxrshiftv_ vux t varg ">>" gen t varg
genv-binary-c      bltv_  vb t varg "< " gen t varg  
genv-binary-c      wltv_  vw t varg "< " gen t varg  
genv-binary-c      lltv_  vl t varg "< " gen t varg  
genv-binary-c      xltv_  vx t varg "< " gen t varg  
genv-binary-c     ubltv_ vub t varg "< " gen t varg  
genv-binary-c     uwltv_ vuw t varg "< " gen t varg  
genv-binary-c     ulltv_ vul t varg "< " gen t varg  
genv-binary-c     uxltv_ vux t varg "< " gen t varg  
genv-binary-c     sfltv_ vsf t varg "< " gen t varg
genv-binary-c     dfltv_ vdf t varg "< " gen t varg
genv-binary-c      beqv_  vb t varg "==" gen t varg  
genv-binary-c      weqv_  vw t varg "==" gen t varg  
genv-binary-c      leqv_  vl t varg "==" gen t varg  
genv-binary-c      xeqv_  vx t varg "==" gen t varg  
genv-binary-c     sfeqv_ vsf t varg "==" gen t varg
genv-binary-c     dfeqv_ vdf t varg "==" gen t varg
genv-binary-c      bgtv_  vb t varg "> " gen t varg  
genv-binary-c      wgtv_  vw t varg "> " gen t varg  
genv-binary-c      lgtv_  vl t varg "> " gen t varg  
genv-binary-c      xgtv_  vx t varg "> " gen t varg  
genv-binary-c     ubgtv_ vub t varg "> " gen t varg  
genv-binary-c     uwgtv_ vuw t varg "> " gen t varg  
genv-binary-c     ulgtv_ vul t varg "> " gen t varg  
genv-binary-c     uxgtv_ vux t varg "> " gen t varg  
genv-binary-c     sfgtv_ vsf t varg "> " gen t varg
genv-binary-c     dfgtv_ vdf t varg "> " gen t varg
genv-binary-c      blev_  vb t varg "<=" gen t varg   
genv-binary-c      wlev_  vw t varg "<=" gen t varg   
genv-binary-c      llev_  vl t varg "<=" gen t varg   
genv-binary-c      xlev_  vx t varg "<=" gen t varg   
genv-binary-c     ublev_ vub t varg "<=" gen t varg   
genv-binary-c     uwlev_ vuw t varg "<=" gen t varg   
genv-binary-c     ullev_ vul t varg "<=" gen t varg   
genv-binary-c     uxlev_ vux t varg "<=" gen t varg   
genv-binary-c     sflev_ vsf t varg "<=" gen t varg
genv-binary-c     dflev_ vdf t varg "<=" gen t varg
genv-binary-c      bgev_  vb t varg ">=" gen t varg   
genv-binary-c      wgev_  vw t varg ">=" gen t varg   
genv-binary-c      lgev_  vl t varg ">=" gen t varg   
genv-binary-c      xgev_  vx t varg ">=" gen t varg   
genv-binary-c     ubgev_ vub t varg ">=" gen t varg   
genv-binary-c     uwgev_ vuw t varg ">=" gen t varg   
genv-binary-c     ulgev_ vul t varg ">=" gen t varg   
genv-binary-c     uxgev_ vux t varg ">=" gen t varg   
genv-binary-c     sfgev_ vsf t varg ">=" gen t varg
genv-binary-c     dfgev_ vdf t varg ">=" gen t varg
genv-binary-c      bnev_  vb t varg "!=" gen t varg   
genv-binary-c      wnev_  vw t varg "!=" gen t varg   
genv-binary-c      lnev_  vl t varg "!=" gen t varg   
genv-binary-c      xnev_  vx t varg "!=" gen t varg   
genv-binary-c     sfnev_ vsf t varg "!=" gen t varg
genv-binary-c     dfnev_ vdf t varg "!=" gen t varg
genv-binary-c     bmaxv_  vb "maxvv(" gen t arg "," gen t arg ")" gen
genv-binary-c     wmaxv_  vw "maxvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c     lmaxv_  vl "maxvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c     xmaxv_  vx "maxvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c    ubmaxv_ vub "maxvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c    uwmaxv_ vuw "maxvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c    ulmaxv_ vul "maxvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c    uxmaxv_ vux "maxvv(" gen t arg "," gen t arg ")" gen  
\ genv-binary-c    sfmaxv_ vsf "maxvv(" gen t arg "," gen t arg ")" gen
\ genv-binary-c    dfmaxv_ vdf "maxvv(" gen t arg "," gen t arg ")" gen
genv-binary-c     bminv_  vb "minvv(" gen t arg "," gen t arg ")" gen
genv-binary-c     wminv_  vw "minvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c     lminv_  vl "minvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c     xminv_  vx "minvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c    ubminv_ vub "minvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c    uwminv_ vuw "minvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c    ulminv_ vul "minvv(" gen t arg "," gen t arg ")" gen  
genv-binary-c    uxminv_ vux "minvv(" gen t arg "," gen t arg ")" gen  
\ genv-binary-c    sfminv_ vsf "minvv(" gen t arg "," gen t arg ")" gen
\ genv-binary-c    dfminv_ vdf "minvv(" gen t arg "," gen t arg ")" gen

genv-vs-c    bplusvs_  vb n t varg "+ " gen t sarg
genv-vs-c    wplusvs_  vw n t varg "+ " gen t sarg  
genv-vs-c    lplusvs_  vl n t varg "+ " gen t sarg  
genv-vs-c    xplusvs_  vx n t varg "+ " gen t sarg  
genv-vs-c   sfplusvs_ vsf r t varg "+ " gen t sarg
genv-vs-c   dfplusvs_ vdf r t varg "+ " gen t sarg
genv-vs-c   bminusvs_  vb n t varg "- " gen t sarg  
genv-vs-c   wminusvs_  vw n t varg "- " gen t sarg  
genv-vs-c   lminusvs_  vl n t varg "- " gen t sarg  
genv-vs-c   xminusvs_  vx n t varg "- " gen t sarg  
genv-vs-c  sfminusvs_ vsf r t varg "- " gen t sarg
genv-vs-c  dfminusvs_ vdf r t varg "- " gen t sarg
genv-vs-c   btimesvs_  vb n t varg "* " gen t sarg  
genv-vs-c   wtimesvs_  vw n t varg "* " gen t sarg  
genv-vs-c   ltimesvs_  vl n t varg "* " gen t sarg  
genv-vs-c   xtimesvs_  vx n t varg "* " gen t sarg  
genv-vs-c  sftimesvs_ vsf r t varg "* " gen t sarg
genv-vs-c  dftimesvs_ vdf r t varg "* " gen t sarg
genv-vs-c   bslashvs_  vb n t varg "/ " gen t sarg  
genv-vs-c   wslashvs_  vw n t varg "/ " gen t sarg  
genv-vs-c   lslashvs_  vl n t varg "/ " gen t sarg  
genv-vs-c   xslashvs_  vx n t varg "/ " gen t sarg  
genv-vs-c  ubslashvs_ vub u t varg "/ " gen t sarg  
genv-vs-c  uwslashvs_ vuw u t varg "/ " gen t sarg  
genv-vs-c  ulslashvs_ vul u t varg "/ " gen t sarg  
genv-vs-c  uxslashvs_ vux u t varg "/ " gen t sarg  
genv-vs-c  sfslashvs_ vsf r t varg "/ " gen t sarg
genv-vs-c  dfslashvs_ vdf r t varg "/ " gen t sarg
genv-vs-c     bmodvs_  vb n t varg "% " gen t sarg  
genv-vs-c     wmodvs_  vw n t varg "% " gen t sarg  
genv-vs-c     lmodvs_  vl n t varg "% " gen t sarg  
genv-vs-c     xmodvs_  vx n t varg "% " gen t sarg  
genv-vs-c    ubmodvs_ vub u t varg "% " gen t sarg  
genv-vs-c    uwmodvs_ vuw u t varg "% " gen t sarg  
genv-vs-c    ulmodvs_ vul u t varg "% " gen t sarg  
genv-vs-c    uxmodvs_ vux u t varg "% " gen t sarg  
genv-vs-c     bandvs_  vb n t varg "& " gen t sarg  
genv-vs-c      borvs_  vb n t varg "| " gen t sarg  
genv-vs-c     bxorvs_  vb n t varg "^ " gen t sarg
genv-vs-c  blshiftvs_  vb n t varg "<<" gen t sarg   
genv-vs-c  wlshiftvs_  vw n t varg "<<" gen t sarg   
genv-vs-c  llshiftvs_  vl n t varg "<<" gen t sarg   
genv-vs-c  xlshiftvs_  vx n t varg "<<" gen t sarg   
genv-vs-c  brshiftvs_  vb n t varg ">>" gen t sarg   
genv-vs-c  wrshiftvs_  vw n t varg ">>" gen t sarg   
genv-vs-c  lrshiftvs_  vl n t varg ">>" gen t sarg   
genv-vs-c  xrshiftvs_  vx n t varg ">>" gen t sarg   
genv-vs-c ubrshiftvs_ vub u t varg ">>" gen t sarg   
genv-vs-c uwrshiftvs_ vuw u t varg ">>" gen t sarg   
genv-vs-c ulrshiftvs_ vul u t varg ">>" gen t sarg   
genv-vs-c uxrshiftvs_ vux u t varg ">>" gen t sarg
genv-vs-c      bltvs_  vb n t varg "< " gen t sarg  
genv-vs-c      wltvs_  vw n t varg "< " gen t sarg  
genv-vs-c      lltvs_  vl n t varg "< " gen t sarg  
genv-vs-c      xltvs_  vx n t varg "< " gen t sarg  
genv-vs-c     ubltvs_ vub u t varg "< " gen t sarg  
genv-vs-c     uwltvs_ vuw u t varg "< " gen t sarg  
genv-vs-c     ulltvs_ vul u t varg "< " gen t sarg  
genv-vs-c     uxltvs_ vux u t varg "< " gen t sarg  
genv-vs-c     sfltvs_ vsf r t varg "< " gen t sarg
genv-vs-c     dfltvs_ vdf r t varg "< " gen t sarg
genv-vs-c      beqvs_  vb n t varg "==" gen t sarg  
genv-vs-c      weqvs_  vw n t varg "==" gen t sarg  
genv-vs-c      leqvs_  vl n t varg "==" gen t sarg  
genv-vs-c      xeqvs_  vx n t varg "==" gen t sarg  
genv-vs-c     sfeqvs_ vsf r t varg "==" gen t sarg
genv-vs-c     dfeqvs_ vdf r t varg "==" gen t sarg
genv-vs-c      bgtvs_  vb n t varg "> " gen t sarg  
genv-vs-c      wgtvs_  vw n t varg "> " gen t sarg  
genv-vs-c      lgtvs_  vl n t varg "> " gen t sarg  
genv-vs-c      xgtvs_  vx n t varg "> " gen t sarg  
genv-vs-c     ubgtvs_ vub u t varg "> " gen t sarg  
genv-vs-c     uwgtvs_ vuw u t varg "> " gen t sarg  
genv-vs-c     ulgtvs_ vul u t varg "> " gen t sarg  
genv-vs-c     uxgtvs_ vux u t varg "> " gen t sarg  
genv-vs-c     sfgtvs_ vsf r t varg "> " gen t sarg
genv-vs-c     dfgtvs_ vdf r t varg "> " gen t sarg
genv-vs-c      blevs_  vb n t varg "<=" gen t sarg   
genv-vs-c      wlevs_  vw n t varg "<=" gen t sarg   
genv-vs-c      llevs_  vl n t varg "<=" gen t sarg   
genv-vs-c      xlevs_  vx n t varg "<=" gen t sarg   
genv-vs-c     ublevs_ vub u t varg "<=" gen t sarg   
genv-vs-c     uwlevs_ vuw u t varg "<=" gen t sarg   
genv-vs-c     ullevs_ vul u t varg "<=" gen t sarg   
genv-vs-c     uxlevs_ vux u t varg "<=" gen t sarg   
genv-vs-c     sflevs_ vsf r t varg "<=" gen t sarg
genv-vs-c     dflevs_ vdf r t varg "<=" gen t sarg
genv-vs-c      bgevs_  vb n t varg ">=" gen t sarg   
genv-vs-c      wgevs_  vw n t varg ">=" gen t sarg   
genv-vs-c      lgevs_  vl n t varg ">=" gen t sarg   
genv-vs-c      xgevs_  vx n t varg ">=" gen t sarg   
genv-vs-c     ubgevs_ vub u t varg ">=" gen t sarg   
genv-vs-c     uwgevs_ vuw u t varg ">=" gen t sarg   
genv-vs-c     ulgevs_ vul u t varg ">=" gen t sarg   
genv-vs-c     uxgevs_ vux u t varg ">=" gen t sarg   
genv-vs-c     sfgevs_ vsf r t varg ">=" gen t sarg
genv-vs-c     dfgevs_ vdf r t varg ">=" gen t sarg
genv-vs-c      bnevs_  vb n t varg "!=" gen t sarg   
genv-vs-c      wnevs_  vw n t varg "!=" gen t sarg   
genv-vs-c      lnevs_  vl n t varg "!=" gen t sarg   
genv-vs-c      xnevs_  vx n t varg "!=" gen t sarg   
genv-vs-c     sfnevs_ vsf r t varg "!=" gen t sarg
genv-vs-c     dfnevs_ vdf r t varg "!=" gen t sarg
genv-vs-c     bmaxvs_  vb n "maxvv(" gen t varg "," gen t sarg ")" gen
genv-vs-c     wmaxvs_  vw n "maxvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c     lmaxvs_  vl n "maxvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c     xmaxvs_  vx n "maxvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c    ubmaxvs_ vub u "maxvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c    uwmaxvs_ vuw u "maxvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c    ulmaxvs_ vul u "maxvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c    uxmaxvs_ vux u "maxvv(" gen t varg "," gen t sarg ")" gen  
\ genv-vs-c    sfmaxvs_ vsf r "maxvv(" gen t varg "," gen t sarg ")" gen
\ genv-vs-c    dfmaxvs_ vdf r "maxvv(" gen t varg "," gen t sarg ")" gen
genv-vs-c     bminvs_  vb n "minvv(" gen t varg "," gen t sarg ")" gen
genv-vs-c     wminvs_  vw n "minvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c     lminvs_  vl n "minvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c     xminvs_  vx n "minvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c    ubminvs_ vub u "minvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c    uwminvs_ vuw u "minvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c    ulminvs_ vul u "minvv(" gen t varg "," gen t sarg ")" gen  
genv-vs-c    uxminvs_ vux u "minvv(" gen t varg "," gen t sarg ")" gen  
\ genv-vs-c    sfminvs_ vsf r "minvv(" gen t varg "," gen t sarg ")" gen
\ genv-vs-c    dfminvs_ vdf r "minvv(" gen t varg "," gen t sarg ")" gen

genv-sv-c   bminussv_  vb n t sarg "- " gen t varg  
genv-sv-c   wminussv_  vw n t sarg "- " gen t varg  
genv-sv-c   lminussv_  vl n t sarg "- " gen t varg  
genv-sv-c   xminussv_  vx n t sarg "- " gen t varg  
genv-sv-c  sfminussv_ vsf r t sarg "- " gen t varg
genv-sv-c  dfminussv_ vdf r t sarg "- " gen t varg
genv-sv-c   bslashsv_  vb n t sarg "/ " gen t varg  
genv-sv-c   wslashsv_  vw n t sarg "/ " gen t varg  
genv-sv-c   lslashsv_  vl n t sarg "/ " gen t varg  
genv-sv-c   xslashsv_  vx n t sarg "/ " gen t varg  
genv-sv-c  ubslashsv_ vub u t sarg "/ " gen t varg  
genv-sv-c  uwslashsv_ vuw u t sarg "/ " gen t varg  
genv-sv-c  ulslashsv_ vul u t sarg "/ " gen t varg  
genv-sv-c  uxslashsv_ vux u t sarg "/ " gen t varg  
genv-sv-c  sfslashsv_ vsf r t sarg "/ " gen t varg
genv-sv-c  dfslashsv_ vdf r t sarg "/ " gen t varg
genv-sv-c     bmodsv_  vb n t sarg "% " gen t varg  
genv-sv-c     wmodsv_  vw n t sarg "% " gen t varg  
genv-sv-c     lmodsv_  vl n t sarg "% " gen t varg  
genv-sv-c     xmodsv_  vx n t sarg "% " gen t varg  
genv-sv-c    ubmodsv_ vub u t sarg "% " gen t varg  
genv-sv-c    uwmodsv_ vuw u t sarg "% " gen t varg  
genv-sv-c    ulmodsv_ vul u t sarg "% " gen t varg  
genv-sv-c    uxmodsv_ vux u t sarg "% " gen t varg  
genv-sv-c  blshiftsv_  vb n t sarg "<<" gen t varg   
genv-sv-c  wlshiftsv_  vw n t sarg "<<" gen t varg   
genv-sv-c  llshiftsv_  vl n t sarg "<<" gen t varg   
genv-sv-c  xlshiftsv_  vx n t sarg "<<" gen t varg   
genv-sv-c  brshiftsv_  vb n t sarg ">>" gen t varg   
genv-sv-c  wrshiftsv_  vw n t sarg ">>" gen t varg   
genv-sv-c  lrshiftsv_  vl n t sarg ">>" gen t varg   
genv-sv-c  xrshiftsv_  vx n t sarg ">>" gen t varg   
genv-sv-c ubrshiftsv_ vub u t sarg ">>" gen t varg   
genv-sv-c uwrshiftsv_ vuw u t sarg ">>" gen t varg   
genv-sv-c ulrshiftsv_ vul u t sarg ">>" gen t varg   
genv-sv-c uxrshiftsv_ vux u t sarg ">>" gen t varg
genv-sv-c      bltsv_  vb n t sarg "< " gen t varg  
genv-sv-c      wltsv_  vw n t sarg "< " gen t varg  
genv-sv-c      lltsv_  vl n t sarg "< " gen t varg  
genv-sv-c      xltsv_  vx n t sarg "< " gen t varg  
genv-sv-c     ubltsv_ vub u t sarg "< " gen t varg  
genv-sv-c     uwltsv_ vuw u t sarg "< " gen t varg  
genv-sv-c     ulltsv_ vul u t sarg "< " gen t varg  
genv-sv-c     uxltsv_ vux u t sarg "< " gen t varg  
genv-sv-c     sfltsv_ vsf r t sarg "< " gen t varg
genv-sv-c     dfltsv_ vdf r t sarg "< " gen t varg
genv-sv-c      bgtsv_  vb n t sarg "> " gen t varg  
genv-sv-c      wgtsv_  vw n t sarg "> " gen t varg  
genv-sv-c      lgtsv_  vl n t sarg "> " gen t varg  
genv-sv-c      xgtsv_  vx n t sarg "> " gen t varg  
genv-sv-c     ubgtsv_ vub u t sarg "> " gen t varg  
genv-sv-c     uwgtsv_ vuw u t sarg "> " gen t varg  
genv-sv-c     ulgtsv_ vul u t sarg "> " gen t varg  
genv-sv-c     uxgtsv_ vux u t sarg "> " gen t varg  
genv-sv-c     sfgtsv_ vsf r t sarg "> " gen t varg
genv-sv-c     dfgtsv_ vdf r t sarg "> " gen t varg
genv-sv-c      blesv_  vb n t sarg "<=" gen t varg   
genv-sv-c      wlesv_  vw n t sarg "<=" gen t varg   
genv-sv-c      llesv_  vl n t sarg "<=" gen t varg   
genv-sv-c      xlesv_  vx n t sarg "<=" gen t varg   
genv-sv-c     ublesv_ vub u t sarg "<=" gen t varg   
genv-sv-c     uwlesv_ vuw u t sarg "<=" gen t varg   
genv-sv-c     ullesv_ vul u t sarg "<=" gen t varg   
genv-sv-c     uxlesv_ vux u t sarg "<=" gen t varg   
genv-sv-c     sflesv_ vsf r t sarg "<=" gen t varg
genv-sv-c     dflesv_ vdf r t sarg "<=" gen t varg
genv-sv-c      bgesv_  vb n t sarg ">=" gen t varg   
genv-sv-c      wgesv_  vw n t sarg ">=" gen t varg   
genv-sv-c      lgesv_  vl n t sarg ">=" gen t varg   
genv-sv-c      xgesv_  vx n t sarg ">=" gen t varg   
genv-sv-c     ubgesv_ vub u t sarg ">=" gen t varg   
genv-sv-c     uwgesv_ vuw u t sarg ">=" gen t varg   
genv-sv-c     ulgesv_ vul u t sarg ">=" gen t varg   
genv-sv-c     uxgesv_ vux u t sarg ">=" gen t varg   
genv-sv-c     sfgesv_ vsf r t sarg ">=" gen t varg
genv-sv-c     dfgesv_ vdf r t sarg ">=" gen t varg
