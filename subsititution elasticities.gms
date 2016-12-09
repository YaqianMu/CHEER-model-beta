*12月17日，修改了非化石能源自然要素供给的弹性



parameter  esub_inv     elasticity of substitution among inputs to investment
           esub_c       elasticity of substitution among inputs to consumption
           esub_s       elasticity of substitution among investment types
           esub                                                           ;
parameter sigma
          esub_es
          esubva(i)
          esubd(i)
;
*subsititution elasticities from Ke Wang
esub("coal","kl")=0.80;
esub("gas","kl")=0.82;
esub("roil","kl")=0.74;
esub("elec","kl")=0.81;

esub(i,"ff")=0.6;
esub("gas","ff")=0.5;
esub("coal","ff")=0.7;
esub("elec","ff")=0.4;

esub_inv   =0.25 ;

*from Eppa 4.1
esub_c     =0.25 ;
sigma("ene_fd") = 0.4;

esub_s     =10 ;


*from EPPA
sigma("ele_p") = 0.5;
sigma("ene_p") = 1;

eta("coal") =2.0;
eta("oilgas")=1.0;
eta("agri")=0.5;
eta("mine")=2.0;
eta("gas")=1.0 ;
eta("elec")= 0.5;

eta("biomass")= 0.5 ;
eta("hydro")= 0.1;
eta("wind")= 1.5 ;
eta("solar")= 1.5 ;
eta("nuclear")= 0.5 ;








parameter eslm  高水平劳动力与其他要素的替代弹性;

eslm("l")=1;
eslm("ll")=1.5;
eslm("lh")=1.5;


eslm("l")=0;
*eslm("ll")=0;
*eslm("lh")=0;


