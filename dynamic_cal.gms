*----------------------------------------------*
*this file is used to calibrate the baseline
*----------------------------------------------*

parameters

pdom         domesitic price of commodities
pamt         armington price of energy commodities(gross of carbon taxes)
pdk          domestic capital prices
pdl          domestic labor prices
pfdem        prices of final demand activities
pff          prices of fixed factors

unem         unemployment rate

pcarbon      shadow price of carbon(2005 Chinese Yuan per ton)
psulfur      shadow price of sulfur

gdp          GDP at factor cots(2005 Chinese 100million Yuan)
gdp_comp     component of gdp (2005 Chinese 100million Yuan)
welfare      consumers income (2005 Chinese 100million Yuan)

fact_supp    factor supplies(2005 Chinese 100million Yuan)
ffact_supp   fixed factor supplies(2005 Chinese 100million Yuan)
fact_dem     factor demands(2005 Chinese 100million Yuan)

demand       demand for armington aggregate commodities(2005 Chinese 100million Yuan)
output       sectoral output quantities(2005 Chinese 100million Yuan)
input        sectoral input quantities(2005 Chinese 100million Yuan)
cons         consumption quantities(2005 Chinese 100million Yuan)
consf        consumption of factors(2005 Chinese 100million Yuan)

output_elec  sectoral output quantities of sub electricity sectors

elecshare    share of different elecutil type(%)
euse         aggregate energy use (million tce)
cfree_elec   non-carbon electric output
carb_elec    carbon-based electric output
carb_emit    carbon emissions (million tonnes)
sulf_emit    sulfur emissions
cqutta       carbon emission quota (million tonnes)
squtta       carbon emission quota (million tonnes)


parameter
invk         sectoral physical capital investment(2005 Chinese 100million Yuan)

invfk        physical capital investment by factors(2005 Chinese 100million Yuan)

kstock       physical capital stock(2005 Chinese 100million Yuan)
invest_k     aggregate gorss physical capital investment(2005 Chinese 100million Yuan)
jk           aggregate net physical capital investment(2005 Chinese 100million Yuan)



scalars

zetak     adjustment threshold of capital stock /0.044/

betak     speed of adjustment of capital stock  /32.2/


gammak    growth rate of pysical capital in initial period /0.10/


deltak    annual rate of physical capital depreciation /0.03/


rk0       benchmark net marginal product of capital

rork0     benchmark net return to physical capital

kstock0   benchmark capital stock


;



*test sensitivity of emissions to fixed factor supply elasticitiy

*eta("coal")=1.0;
*eta("oilgas")=0.5;

invest_k("2012")=grossinvk.l;


rk0$((gammak+deltak) le zetak)= (gammak+deltak)*fact("capital")/invest_k("2012")-deltak;
rk0$((gammak+deltak) > zetak) =(betak/2*(gammak+deltak-zetak)**2+gammak+deltak)*fact("capital")/invest_k("2012")-deltak;
rork0= rk0+deltak;
kstock0 =fact("capital")/rork0;


*emissions restriction policies,with or without inducement of innovation
parameters
tax_s
cquota
UNEM
Pwage
Pcom;

cquota(t) =0;

*simu=0,calibration; simu_s=1,GDP endogenous,simu_s=0,GDP exdogenous˰
simu_s =0;

tax_s =1;

*==parameter for learning curve
parameter elecout_t(t,sub_elec)
          bata(sub_elec)   learning coefficient
          ;
bata(sub_elec) = 0;
bata("wind")  = -0.1265928;
bata("solar")  = -0.198229;
* to update
bata("biomass")  = -0.2315684;

*== switch for learning curve *=on
*bata(sub_elec) = 0;


loop(t$(ord(t) le card(t)),

clim = 0;

*gprod0$(simu_s ne 0)=gprod_b(t);

rgdp0$(simu_s eq 0)=rgdp_b(t);


*clim0= clim_t(t);

*==== higher subsidy for renewable

*taxelec0(sub_elec)$(wsb(sub_elec) and ord(t) eq 2)=100*taxelec0(sub_elec);
*taxelec0("wind")$(ord(t) eq 2)=100*taxelec0("wind");
*taxelec0("solar")$(ord(t) eq 2)=100*taxelec0("solar");
*taxelec0("biomass")$(ord(t) eq 2)=100*taxelec0("biomass");

*==code for learning curve

elecout_t(t,sub_elec)=qelec.l(sub_elec);

mkup_t(t,sub_elec) = ((elecout_t(t,sub_elec))/elecout_t("2012",sub_elec))**bata(sub_elec);

emkup(sub_elec)=mkup_t(t,sub_elec);



$include China3E.gen



solve China3E using mcp;

display China3E.modelstat, China3E.solvestat,clim,cquota,t;


*-------------
*sore results
*-------------

*stocks

invest_k(t)                  =   grossinvk.l;
kstock(t)$(ord(t)=1)         =   kstock0;

*------------------
*update endowments
*------------------

*=======capita  update  =========
jk(t)$(invest_k(t)/kstock(t) ge zetak)  = kstock(t)/betak*
                                           (betak*zetak-1+sqrt(1+2*betak*(invest_k(t)/kstock(t)-zetak)));
jk(t)$(invest_k(t)/kstock(t) le zetak)  = invest_k(t);

*card(t) returns the number of elements in set t

kstock(t+1)$(ord(t) eq 1)                  =3*jk(t)+(1-deltak)**3*kstock(t);
kstock(t+1)$(ord(t) gt  1)                  =5*jk(t)+(1-deltak)**5*kstock(t);

fact("capital")                         =rork0*kstock(t+1);

*=======labor  update =========
*need population analysis                   2005-2014年均人口增长率为0.005019 劳动参与率平均为0.58   劳动参与率恒定时，人口增长率与劳动供给增长率相等
tqlabor_s0$(ord(t) eq 1)                    =tqlabor_s0*(1+lgrowth_b(t+1))**3;
tqlabor_s0$(ord(t) gt  1)                    =tqlabor_s0*(1+lgrowth_b(t+1))**5;

*same population share as base year
tlabor_s0(lm)                           =tqlabor_s0*tlprop("2012",lm);
*change population share
*tlabor_s0(lm)                           =tqlabor_s0*tlprop(t+1,lm);

*ur.lo(lm)=0.85*ur.l(lm);


*=======energy effiency  update =========

*aeei(i)$(not elec(i))          =  aeei(i)/(1+0.01)**5;
*aeei("fd")       =  aeei("fd")/(1+0.01)**5;
*aeei("elec") =  aeei("elec")/(1+0.01)**5;

aeei(i)$(ord(t) eq 1)  =  aeei(i)/(1+0.01)**3;
aeei("fd")$(ord(t) eq 1)  =  aeei("fd")/(1+0.01)**3;
aeei("elec")$(ord(t) eq 1)  =  aeei("elec")/(1+0.003)**3;

aeei(i)$(ord(t) gt 1)  =  aeei(i)/(1+0.01)**5;
aeei("fd")$(ord(t) gt 1)  =  aeei("fd")/(1+0.01)**5;
aeei("elec")$(ord(t) gt 1)  =  aeei("elec")/(1+0.003)**5;

*=======exogenous trade balance  =========
*trade imbalance and stock change phased out at 1% per year
xscale$(ord(t) eq 1)                                  =0.99**(3*(ord(t)-1));
xscale$(ord(t) gt 1)                                   =0.99**(5*(ord(t)-1));

*=======calibrate the TFP  =========
gprod_b(t)=gprod.l;

sffelec_b(t,sub_elec)=sffelec.l(sub_elec);

sffelec_bau(t,sub_elec)$(simu_s eq 0)=sffelec.l(sub_elec);

display tqlabor_s0,tlabor_s0,cquota,rgdp.l,gprod.l,emkup,ret0;
);
