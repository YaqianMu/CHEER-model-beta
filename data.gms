$CALL GDXXRW.EXE data/data.xlsx par=sam rng=A1


*=== Now import data from GDX
Parameter SAM(*,*);
$GDXIN data.gdx
$LOAD SAM
$GDXIN
