*----------------------------------------------*
*electricity sector division
*20151215 ���������޸ĺ󣬴���΢Сƫ���ffactor�йأ��Ժ�����
*20161201,����2012�����ݣ�ʹ���µĲ��ַ�����ԭ������electricity�ļ���
*----------------------------------------------*
$CALL GDXXRW.EXE elec.xlsx par=Eprop rng=A1:J34

Parameter Eprop(*,*) input data of sub-electricity sectors;
*Parameter elec_t(*,*)  electricity generation trend in 100 million kwh;
*Parameter mkup_t(*,*)  markup trend;
$GDXIN elec.gdx
$LOAD Eprop
*$LOAD elec_t
*$LOAD mkup_t
$GDXIN

parameter enesta   substitution elasticity between different sub_elec    from EPPA 6
          emkup           electricity markup
          emkup0          base year electricity markup
          p_ff            proportion of fix-factor
          check1
          check2;


*=== transfer unit to billion yuan
Eprop(i,sub_elec)=Eprop(i,sub_elec)/100000;
Eprop(f,sub_elec)=Eprop(f,sub_elec)/100000;
Eprop('tax',sub_elec)=Eprop('tax',sub_elec)/100000;

DISPLAY Eprop;

parameter
         ffshr           fraction of electric sector capital as fixed factor
         lelec0          labor in electricity generation
         kelec0          capital in electricity generation
         ffelec0         fixed factor in electricity generation
*         ffelec_b        fixed factor in base year
         intelec0        intermediate input to electricity generation
         taxelec0
         subelec0
         outputelec0     output of electricity generation
         Toutputelec0                                    ;

         enesta=1.5;

*== markup factor
         emkup(sub_elec)       =      1;
*         emkup("wind")    =      1.3;
*         emkup("solar")   =      2.5;
*         emkup("Biomass")     =      1.8;
*== switch for markup

         emkup(sub_elec)       =      1;
         emkup0(sub_elec)      =      emkup(sub_elec);




lelec0(sub_elec) =       Eprop("labor",sub_elec)/emkup(sub_elec);
kelec0(sub_elec) =       Eprop("capital",sub_elec)/emkup(sub_elec);
intelec0(i,sub_elec) =   Eprop(i,sub_elec)/emkup(sub_elec);
taxelec0(sub_elec)=      Eprop("tax",sub_elec);

*==to be updata
parameter theta_elec(sub_elec)     imputed fixed factor share of capital      from Sue Wing 2006


table ff_data(*,*) cost structure from Sue Wing
                 hydro      nuclear    Wind       Solar      Biomass
labor            24         13         17         7          19
capital          56         60         64         73         59
ff               19         27         20         20         22
;
theta_elec(sub_elec) =0;
theta_elec(sub_elec)$ff_data("ff",sub_elec) = ff_data("ff",sub_elec)/(ff_data("ff",sub_elec)+ff_data("capital",sub_elec));

ffelec0(sub_elec)   =    0;

ffelec0(sub_elec)   = theta_elec(sub_elec)*kelec0(sub_elec);
kelec0(sub_elec)   =(1-theta_elec(sub_elec))*kelec0(sub_elec);


*ffelec_b(sub_elec)   =   ffelec0(sub_elec);

display taxelec0,ffelec0;

table egen_data(*,*)  data for power generation by  technology in GWh from Stats
       T_D        Coal        Oil        Gas        Nuclear        Hydro        Wind        Solar        Biomass
Gwh    4917100    3710400     5400       109200     98300         855600        103000        3600        31600
;


*== Feed in tariff data
parameter FIT(sub_elec)  Feed in tariff Price Yuan per kwh   Source Qi 2014 Energy Policy     ;
parameter FIT_v(sub_elec)  Total subsidy in billion yuan ;

FIT("Coal")= 0.4;
FIT("wind")= 0.55;
FIT("solar")= 0.95;
FIT("biomass")= 0.75;

FIT_v(sub_elec)=0;
FIT_v(sub_elec)$wsb(sub_elec)=(FIT(sub_elec)-FIT("coal"))*egen_data("Gwh",sub_elec)*10**6/10**9;

subelec0(sub_elec) = FIT_v(sub_elec);
taxelec0(sub_elec) = taxelec0(sub_elec)+subelec0(sub_elec)  ;

display  FIT_v,subelec0,taxelec0;

*==update outputelec0
outputelec0(sub_elec)=   emkup(sub_elec)*(lelec0(sub_elec)+kelec0(sub_elec)+ffelec0(sub_elec)+sum(i,intelec0(i,sub_elec)))+(taxelec0(sub_elec)-subelec0(sub_elec));

Toutputelec0         =   sum(sub_elec,outputelec0(sub_elec));

taxelec0(sub_elec)$outputelec0(sub_elec)=taxelec0(sub_elec)/outputelec0(sub_elec);
subelec0(sub_elec)$outputelec0(sub_elec)=subelec0(sub_elec)/outputelec0(sub_elec);

p_ff(sub_elec)    =      emkup(sub_elec)*ffelec0(sub_elec)/((1-taxelec0(sub_elec))*outputelec0(sub_elec));

check1=output0("elec")-sum(sub_elec,outputelec0(sub_elec));

*== key debug points=======
*emarkup

fact('capital')=fact('capital')-sum(sub_elec,ffelec0(sub_elec)*emkup(sub_elec));

display lelec0,kelec0,intelec0,outputelec0,taxelec0,subelec0,tx0,emission0,p_ff,Toutputelec0,check1;

*== transfer elecoutput from value to physical

parameter   costelec0(sub_elec) unit generation cost by technomogy in billion yuan per TWH;

costelec0(sub_elec) =outputelec0(sub_elec)/egen_data("Gwh",sub_elec)*1000;

outputelec0(sub_elec)=egen_data("Gwh",sub_elec)/1000;

*== set emission for electricity sector
parameter emissionelec0(pollutant,pitem,*,*)  electricity emission by source ;

emissionelec0('co2','e',fe,sub_elec)=ccoef_p(fe)*intelec0(fe,sub_elec)*(1-r_feed(fe,"elec"));




*EPPA 6 elecpower ˮ���ͺ˵�����ȻҪ�ص���
esub(sub_elec,"ff")=0.2;
esub("nuclear","ff")=0.6*p_ff("nuclear")/(1-p_ff("nuclear"));
esub("hydro","ff")=0.5*p_ff("hydro")/(1-p_ff("hydro"));
esub("wind","ff")=0.25;
*esub(sub_elec,"ff")=0.4;


display costelec0,outputelec0,esub,emissionelec0;
