$title a dynamic CGE model of China economy-environment-energy policy analysis based on 2012 data

$Ontext
China-3E
Author:Yaqian Mu, Tsinghua University (muyaqian00@163.com)
UpDate:    12-2016
$offtext

$offlisting
$offsymxref


*----------------------------------------------*
*Load benchmark data and define their structure*
*----------------------------------------------*


SETS
i commodities in SAM table(produced goods represented by sector name
       /
       Elec
       Coal
       Oilgas
       Roil
       Gas
       Agri
       mine
       Food
       Paper
       Chem
       CM
       IST
       NFM
       EII
       OM
       Air
       Tran
       Serv
       /
e(i) energy supply sectors
       /Elec
       Coal
       Roil
       Gas/
fe(i) fuel energy supply sectors
/Coal,roil,gas/
x(i) exhaustible resource sectors
/agri,coal,oilgas,Mine,gas/
elec(i) electrici power sector
/elec/
ist(i) ist sector
/ist/
cm(i) sectors selected in carbon market
/roil,elec,Paper, Chem,CM,IST,NFM,Air/
*Mi(i) energy intensive materials/chem,/
*Mn(i) Non energy intensive materials//
agrmine(i) agriculture and non-energy mine
/agri,mine/
mfg(i) manufacturing
       /Food
       Paper
       Chem
       CM
       IST
       NFM
       EII
       OM/
Trans(i)  transport
         /Air
       Tran/
Serv(i)   services
         /serv/

pollutant /CO2,SO2,NOX/
air_p(pollutant) /SO2,NOX/
Pitem /e,g,a/
Psource /coal,roil,gas,process/


f primary factors
/Labor "Labour"
capital "Physical capital"
/
lab(f) labor /labor/
d final demands /Household,GOVERNMENT,INVESTMENT,export,import/
yr time in years /2005*2050/
t(yr) time in 5 years periods
*/2010*2030/
/2010,2015,2020,2025,2030/
*,2035,2040,2045,2050
year years within each time period /1*5/
;


alias (i,j),(f,ff),(e,ee),(fe,fee);

set      sub_elec /T_D, Coal, Gas, Oil, Nuclear, Hydro, Wind, Solar, Biomass/
         TD(sub_elec)  transport and distribution /T_D/
         bse(sub_elec) base load electricity /Coal, Gas, Oil, Nuclear, Hydro, Biomass/
         ffe(sub_elec) fossil fuel electricity /Coal, Gas, Oil/
         cfe(sub_elec) carbon free electricity /Nuclear, Hydro, Wind, Solar, Biomass/
         hnb(sub_elec) hydro and nuclear biomass electricity /Nuclear, Hydro,Biomass/
         wse(sub_elec)  wind and solar /Wind, Solar/
         hne(sub_elec)  hydro and nuclear electricity /Nuclear, Hydro/
         wsb(sub_elec)  wind and solar biomass/Wind, Solar, Biomass/;

alias (sub_elec,sub_elecc);

$CALL GDXXRW.EXE data.xlsx par=sam rng=A1


*=== Now import data from GDX
Parameter SAM(*,*);
$GDXIN data.gdx
$LOAD SAM
$GDXIN

*=== transfer unit to billion yuan
sam(i,j)=sam(i,j)/100000;
sam(f,i)=sam(f,i)/100000;
sam(i,d)=sam(i,d)/100000;
sam('tax',i)=sam('tax',i)/100000;

DISPLAY SAM;

*----------------------------------------------*
*setup benchmark quantities
*----------------------------------------------*

parameters
*parameters to extract the benchmark

int0           intermediate inputs
fact0          factor inputs to industry sectors
tax0           net tax payments to industry sectors
tx0            tax rate on industry output
output0        sectoral gross output
fact           aggregate factor supplies

inv0           sectoral investment in physical capital
invf0          factor investment in physical capital
xinv0          exogenous(negative) sectoral investment in physical capital
xinvf0         exogenous(negative) factor investment in physical capital

cons0          consumption of conmmodities
consf0         direct consumption of factor services
xcons0         exogenous(negative) consumption of commodities
xconsf0        exogenous(negative) consumption of factor services

exp0           benchmark commodity exports
imp0           benchmark commodity imports


xexp0          exogenous(negative) benchmark commodity exports
ximp0          exogenous(negative) benchmark commodity imports

expf0          benchmark factor exports
impf0          benchmark factor imports

xexpf0         exogenous(negative) benchmark factor exports
ximpf0         exogenous(negative) benchmark factor imports

nx0            net commodity exports
nxf0           net factor exports

*fixed factor parameters

theta(x)     imputed fixed factor share of capital      from GTAP-E
/coal       0.68
 oilgas     0.51
 mine       0.07
 agri       0.28
 gas        0.59
/
ffact0        benchmark fixed factor supply
eta           fixed factor supply elasticity




*parameter to scale exogenous endowments
xscale

;

int0(i,j)   = sam(i,j);
fact0(f,j)  = sam(f,j);
ffact0(x)   = theta(x)*sam("capital",x);
fact0("capital",x) =(1-theta(x))*sam("capital",x);

display ffact0,fact0,int0;

inv0(i)     =max(0,sam(i,"investment"));
invf0(f)    =max(0,sam(f,"investment"));

xinv0(i)     =min(0,sam(i,"investment"));
xinvf0(f)    =min(0,sam(f,"investment"));

cons0(i)    =max(0,sam(i,"Household"))+max(0,sam(i,"GOVERNMENT"));
consf0(f)   =max(0,sam(f,"Household"))+max(0,sam(f,"GOVERNMENT"));

xcons0(i)    =min(0,sam(i,"Household"))+min(0,sam(i,"GOVERNMENT"));
xconsf0(f)   =min(0,sam(f,"Household"))+min(0,sam(f,"GOVERNMENT"));

exp0(i)    =max(0,sam(i,"export"));
expf0(f)   =max(0,sam(f,"export"));

xexp0(i)    =min(0,sam(i,"export"));
xexpf0(f)   =min(0,sam(f,"export"));

imp0(i)    =max(0,-sam(i,"import"));
impf0(f)   =max(0,-sam(f,"import"));

ximp0(i)    =min(0,-sam(i,"import"));
ximpf0(f)   =min(0,-sam(f,"import"));

nx0(i)      =exp0(i)-imp0(i)-(xexp0(i)-ximp0(i));
nxf0(f)     =expf0(f)-impf0(f)-(xexpf0(f)-ximpf0(f));

output0(i)  =sum(j,sam(i,j))+inv0(i)+cons0(i)+nx0(i)+(xinv0(i)+xcons0(i));

fact(f)     =sum(j,fact0(f,j))+invf0(f)+consf0(f)+nxf0(f)+(xinvf0(f)+xconsf0(f));

display inv0,xinv0,cons0,xcons0,nx0,output0,xexp0,exp0,fact;


tax0(j)    =sam("tax",j);

display   tax0;

tx0(j)$output0(j)     =tax0(j)/output0(j);

display   tx0;

xscale     =1;
parameter

etemp

;


etemp(e)    =(output0(e)-(nx0(e)+xinv0(e)+xcons0(e)));

*armington good
parameter a0;
a0(i)     =output0(i)-ximp0(i);
display a0,output0,imp0,ximp0,nx0,inv0,cons0,xinv0,xcons0;



