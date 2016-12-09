*----------------------------------------------*
*IST sector division
*----------------------------------------------*
$CALL GDXXRW.EXE ist.xlsx par=isprop rng=A1:C29

Parameter Isprop(*,*) proportion of sub-IST sectors;
$GDXIN ist.gdx
$LOAD Isprop
$GDXIN

DISPLAY Isprop;

set      sub_ist /OBC,EF/

alias (sub_ist,sub_istc)
parameter
         list0          labor in ist generation
         kist0          capital in ist generation
         intist0        intermediate input to ist generation
         taxist0
         outputist0     output of ist generation
         Toutputist0                                             ;


list0(sub_ist) =       isprop("labor",sub_ist)*fact0("labor","IST")  ;
kist0(sub_ist) =       isprop("capital",sub_ist)*fact0("capital","IST")  ;
intist0(i,sub_ist) =   isprop(i,sub_ist)*int0(i,"IST")  ;
taxist0(sub_ist)=      isprop("tax",sub_ist)*sam("tax","IST");
outputist0(sub_ist)=   list0(sub_ist)+kist0(sub_ist)+sum(i,intist0(i,sub_ist))+taxist0(sub_ist);
taxist0(sub_ist)$outputist0(sub_ist)=taxist0(sub_ist)/outputist0(sub_ist);
Toutputist0         =   sum(sub_ist,outputist0(sub_ist));
emission0("so2","e","process",sub_ist)=isprop("SO2_emission_process",sub_ist)*emission0("so2","e","process","IST");
emission0("so2","e","coal",sub_ist)=isprop("SO2_emission_coal",sub_ist)*emission0("so2","e","coal","IST");
emission0("so2","e","roil",sub_ist)=isprop("SO2_emission_oil",sub_ist)*emission0("so2","e","roil","IST");

emission0("so2","g","process",sub_ist)=isprop("SO2_production_process",sub_ist)*emission0("so2","g","process","IST");
emission0("so2","g","coal",sub_ist)=isprop("SO2_production_coal",sub_ist)*emission0("so2","g","coal","IST");
emission0("so2","g","roil",sub_ist)=isprop("SO2_production_oil",sub_ist)*emission0("so2","g","roil","IST");

emission0("so2","a","process",sub_ist)=isprop("SO2_abated_process",sub_ist)*emission0("so2","a","process","IST");
emission0("so2","a","coal",sub_ist)=isprop("SO2_abated_coal",sub_ist)*emission0("so2","a","coal","IST");
emission0("so2","a","roil",sub_ist)=isprop("SO2_abated_oil",sub_ist)*emission0("so2","a","roil","IST");

emission0("co2","e","gas",sub_ist)=isprop("cO2_emission_naturegas",sub_ist)*emission0("co2","e","gas","IST");
emission0("co2","e","coal",sub_ist)=isprop("cO2_emission_coal",sub_ist)*emission0("co2","e","coal","IST");
emission0("co2","e","roil",sub_ist)=isprop("cO2_emission_oil",sub_ist)*emission0("co2","e","roil","IST");

display list0,kist0,intist0,outputist0,taxist0,tx0;
