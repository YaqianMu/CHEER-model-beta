
*----------------------------------------------*
*setup benchmark Emission
*20151215        ����EPPA���������ݣ���Դƽ������Ͷ������������2010���ŷ����ݣ�ȷ���ŷ�ϵ��
*20161201        ����EPPA���������ݣ���Դƽ������Ͷ������������2012���ŷ����ݣ�ȷ���ŷ�ϵ��
*----------------------------------------------*

*== CO2 emission data

*$CALL GDXXRW.EXE emission.xlsx par=edata rng=A1:I11    par=climit   rng=A14:C31

*Parameter edata(*,*) input data of emission;
*Parameter climit(*,*) input data of emission;
*$GDXIN emission.gdx
*$LOAD edata
*$LOAD climit
*$GDXIN

*parameters for energy and emission accounts
parameter emission0(pollutant,pitem,*,*)  sectoral emission by source
          Temission0                     sectoral emission
          Temission1                     Total emission
          Temission2;


parameter
epslon        coefficient of carbon contents (100M tons per EJ)
eet1          energy consumption in ���ֱ�׼ú      ��Чú��
eet2          energy consumption in ���ֱ�׼ú      �ȵ���
eej           energy consumption in EJ
eeg           energy goods consumption in billion yuan  except energy as feedstock input
eeg_s         energy goods consumption in billion yuan  except energy as feedstock input by sector
co2f          co2 emission by fuel in 100 million tons(�ڶ�)

r_feed(fe,i)   adjusted Feedstocks use ratio of fuels by pertrochemistry sector
b_CO2(fe)      IEA CO2 emissions 2012 (Billion tonnes)
cj            adjust factor for epslon to match IEA baseline

ecoef         energy coefficient (���ֱ�׼ú per billion yuan)   energy from quantity of value to physical
ccoef_P       carbon coefficient of production(billion T per Billion yuan)
ccoef_h       carbon coefficient of consumption(billion T per Billion yuan)
;

table edata (*,*)
            coal                 roil                    gas
epslon      0.24686              0.199                   0.137
eet1        200327.100000000     55774.870000000         16441.210000000
eet2        200327.100000000     55774.870000000         16441.210000000
eej         58.71106516          16.3462758              4.818524062
;

epslon(fe)       =       edata("epslon",fe);
eet1(fe)          =      edata("eet1",fe);
*eet1(sub_elec)    =      edata("eet1",sub_elec);
eet2(fe)          =      edata("eet2",fe);
*eet2(sub_elec)    =       edata("eet2",sub_elec);
eej(fe)          =       eet1(fe)*10000*1000*7000*1000*4.1868/10**18;

*==grasped from IEA, CO2 emissions from fuel combustion Highlights, 2015

b_CO2("coal")=71.539/10 ;
b_CO2("roil")=10.789/10 ;
b_CO2("gas")=2.581/10  ;

cj(fe)         =       b_CO2(fe)*10*12/44/epslon(fe)/eej(fe);

co2f(fe)       =       epslon(fe)*cj(fe)*eej(fe)*44/12;

*==calculated from 2012 energy balance table
r_feed("coal","coal") = 0.504025875;
r_feed("coal","chem") = 0.267979697;
r_feed("roil","chem") = 0.595631707;

*== Switch for feedstocks
*r_feed(fe,i) =0;

eeg_s(fe,i)        =       int0(fe,i)*(1-r_feed(fe,i));
eeg_s(fe,"cons")   =       cons0(fe);
eeg(fe)          =       sum(i,eeg_s(fe,i)) + eeg_s(fe,"cons");

ecoef(fe)        =       eet1(fe)/eeg(fe);
ccoef_P(fe)      =       co2f(fe)/eeg(fe);
ccoef_h(fe)      =       ccoef_P(fe);

display epslon, cj, eet1, eet2, eej,eeg_s,eeg, co2f, ecoef,ccoef_p,ccoef_h;


*== air pollutant emission data  SO2 and NOX based on Global Emissions EDGAR v4.3.1 from   Non-CO2 Emission by sector 2010.xlsx in emission fold


parameter scoef_e(*,*)        SO2 emission million ton per billion yuan
          slim                        so2 emission limits million ton;

parameter ncoef_e(*,*)        NOX emission million ton per billion yuan
          nlim                        NOX emission limits million ton;



scoef_e('process',i)     =sam('SO2_emission_process',i)/output0(i);
scoef_e('process','fd')     =sam('SO2_emission_process','household')/sum(i,cons0(i));

ncoef_e('process',i)     =sam('NOX_emission_process',i)/output0(i);
ncoef_e('process','fd')     =sam('NOX_emission_process','household')/sum(i,cons0(i));

emission0('co2','e',fe,i)=ccoef_p(fe)*int0(fe,i)*(1-r_feed(fe,i));

emission0('co2','e',fe,'fd')=ccoef_h(fe)*cons0(fe);

emission0('so2','e','process',i)=scoef_e('process',i)*output0(i) ;
emission0('so2','e','process','fd')=scoef_e('process','fd')*sum(i,cons0(i)) ;

emission0('NOX','e','process',i)=ncoef_e('process',i)*output0(i) ;
emission0('NOX','e','process','fd')=ncoef_e('process','fd')*sum(i,cons0(i)) ;


display scoef_e,ncoef_e,emission0;

* emission account
Temission0('co2',i)=sum(fe,emission0("co2","e",fe,i));
Temission0('co2','fd')=sum(fe,emission0('co2','e',fe,'fd'));

Temission0('so2',i)=emission0('so2','e','process',i);
Temission0('so2','fd')=emission0('so2','e','process','fd');

Temission0('NOX',i)=emission0('NOX','e','process',i);
Temission0('NOX','fd')=emission0('NOX','e','process','fd');

display     Temission0;

Temission1('co2')=sum(i,Temission0('co2',i))+Temission0('co2','fd');
Temission1('so2')=sum(i,Temission0('so2',i))+Temission0('So2','fd');
Temission1('NOX')=sum(i,Temission0('NOX',i))+Temission0('NOX','fd');
Temission2('co2')=sum((i,fe),emission0("co2","e",fe,i))+sum(fe,emission0("co2","e",fe,"fd"));


*== parameter for emission cap
parameter
clim          carbon emission allowance
clim_t        trend of carbon emission allowance
clim0         benchmark of carbon emission allowance
clim_s(i)     sectoral carbon emission allowance
clim_h        household carbon emission allowance
clim_a        selected sectors carbon emission allowance
;

table climit(t,*)     input of emission cap
            a                    b
2010        1                    1
2015        0.870031338        0.870031338
2020        0.76262393        0.76262393
2025        0.655022701        0.612717632
2030        0.5626033        0.492277887
;

slim                     =0;
clim                     =0;
clim_s(i)                =0;
clim_h                   =0;
clim_a                   =0;
clim_t(t) = climit(t,"b");
clim0=1;

display     climit,clim_t,clim0,Temission1,Temission2;
