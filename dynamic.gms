*----------------------------------------------*
*Dynamic process
*1207 add learning curve
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

invest_k("2010")=grossinvk.l;


rk0$((gammak+deltak) le zetak)= (gammak+deltak)*fact("capital")/invest_k("2010")-deltak;
rk0$((gammak+deltak) > zetak) =(betak/2*(gammak+deltak-zetak)**2+gammak+deltak)*fact("capital")/invest_k("2010")-deltak;
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

*simu=0,calibration; simu=1,����˰��simu=2,����˰
simu_s =1;
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

gprod0$(simu_s ne 0)=gprod_b(t);

rgdp0$(simu_s eq 0)=rgdp_b(t);


clim0= clim_t(t);

*���ߵĿ�������Դ����
*taxelec0(sub_elec)$(wsb(sub_elec) and ord(t) eq 2)=100*taxelec0(sub_elec);
*taxelec0("wind")$(ord(t) eq 2)=100*taxelec0("wind");
*taxelec0("solar")$(ord(t) eq 2)=100*taxelec0("solar");
*taxelec0("biomass")$(ord(t) eq 2)=100*taxelec0("biomass");

elecout_t(t,sub_elec)=qelec.l(sub_elec);

mkup_t(t,sub_elec) = ((elecout_t(t,sub_elec))/elecout_t("2010",sub_elec))**bata(sub_elec);

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

*$ontext

report5(t)=   pcons.l*grosscons.l+pinv.l*grossinvk.l+sum(i,py.l(i)*((nx0(i)+xinv0(i)+xcons0(i))*xscale));
report8("output",t,sub_elec)=qelec.l(sub_elec);
report8("output",t,"Total")=sum(sub_elec,report8("output",t,sub_elec));
report8("share",t,sub_elec)$(not wse(sub_elec))=qelec.l(sub_elec)/report8("output",t,"Total");
report8("share",t,sub_elec)$(wse(sub_elec))=qelec.l(sub_elec)/report8("output",t,"Total");



*------------------
*update endowments
*------------------

jk(t)$(invest_k(t)/kstock(t) ge zetak)  = kstock(t)/betak*
                                           (betak*zetak-1+sqrt(1+2*betak*(invest_k(t)/kstock(t)-zetak)));
jk(t)$(invest_k(t)/kstock(t) le zetak)  = invest_k(t);


kstock(t+1)$(ord(t) lt card(t))         =5*jk(t)+(1-deltak)**5*kstock(t);
kstock(t+1)$(ord(t)=1)                  =5*jk(t)+(1-deltak)**5*kstock(t);


*display jk,jh,kstock,hstock;

*need population analysis                  2005-2014�����˿�������Ϊ0.005019 �Ͷ�������ƽ��Ϊ0.58   �Ͷ������ʺ㶨ʱ���˿����������Ͷ���������������
tqlabor_s0$(ord(t)=1)                    =tqlabor_s0*(1+lgrowth_b(t+1))**5;
tqlabor_s0$(ord(t) ne 1)                 =tqlabor_s0*(1+lgrowth_b(t+1))**5;

*�Ͷ����ṹ����
tlabor_s0(lm)                           =tqlabor_s0*tlprop("2010",lm);
*�Ͷ����ṹ�ı�
*tlabor_s0(lm)                           =tqlabor_s0*tlprop(t+1,lm);

fact("capital")                         =rork0*kstock(t+1);

*ur.lo(lm)=0.85*ur.l(lm);

*trade imbalance and stock change phased out at 1% per year
xscale$(ord(t)=1)                                  =0.99**(5*(ord(t)-1));
xscale$(ord(t) ne 1)                               =0.99**(5*(ord(t)-1));

aeei(i)$(not elec(i))          =  aeei(i)/(1+0.01)**5;
aeei("fd")       =  aeei("fd")/(1+0.01)**5;
aeei("elec") =  aeei("elec")/(1+0.01)**5;

*aeei(i)$(ord(t)=1)  =  aeei(i)/(1+0.01)**5;
*aeei("fd")$(ord(t)=1)  =  aeei("fd")/(1+0.01)**5;
*aeei("elecutil")$(ord(t)=1)  =  aeei("elecutil")/(1+0.003)**5;

*aeei(i)$(ord(t) ne 1)  =  aeei(i)/(1+0.01)**5;
*aeei("fd")$(ord(t) ne 1)  =  aeei("fd")/(1+0.01)**5;
*aeei("elecutil")$(ord(t) ne 1)  =  aeei("elecutil")/(1+0.003)**5;




display tqlabor_s0,tlabor_s0,cquota,rgdp.l,gprod.l,emkup,ret0;
);

execute_unload "results.gdx"  report5 report8
execute 'gdxxrw.exe results.gdx par=report5 rng=GDP!'
execute 'gdxxrw.exe results.gdx par=report8 rng=ele_out!'
