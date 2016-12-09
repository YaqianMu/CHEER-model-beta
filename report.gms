* --
* -- PANDA - PRC Aggregate National Development Assessment Model
* --
* --           All rights reserved
* --
* --           David Roland-Holst, Samuel G. Evans
* --           Cecilia Han Springer, and MU Yaqian
* --
* --           Berkeley Energy and Resources, BEAR LLC
* --           1442A Walnut Street, Suite 108
* --           Berkeley, CA 94705 USA
* --
* --           Email: dwrh@berkeley.edu
* --           Tel: 510-220-4567
* --           Fax: 510-524-4591
* --
* --           October, 2016

* --

* -- postscn.gms
* --
* -- This file produces scnulation results in Excel compatible CSV files
* -- Two files are produced for each interval, a reportfile containing desired scnulation variables,
* --      and a samfile containing complete Social Accounting Matrices
* --


*=====================================generation of accounting scalar====================

*=====================================transfer to csv file================================

* ----- Output the results


put reportfile ;


* ----- Sectoral results

loop(i,
  put sce.tl, rate(z),'2012', 'output', i.tl, '','','output', (qdout.l(i)),China3E.modelstat / ;
  loop(lm,
  put sce.tl, rate(z),'2012', 'employment', i.tl, '',lm.tl,'employment', (qlin.l(i,lm)),China3E.modelstat / ;
  put sce.tl, rate(z),'2012', 'Sectoral wage', i.tl, '',lm.tl,'Sectoral wage', (pl.l(i,lm)),China3E.modelstat / ;
      );
) ;

loop(sub_elec,
  put sce.tl, rate(z),'2012', 'elec_output', '', sub_elec.tl,'','elec_output' , (qelec.l(sub_elec)),China3E.modelstat / ;
  loop(lm,
  put sce.tl, rate(z),'2012', 'employment','', sub_elec.tl ,lm.tl,'employment', (qlin_ele.l(sub_elec,lm)),China3E.modelstat / ;
      );
) ;

* ----- emission results

loop(i,
  put sce.tl, rate(z),'2012', 'ECO2', i.tl, '','','ECO2', (report2(z,i)),China3E.modelstat / ;
) ;

put sce.tl, rate(z),'2012', 'ECO2', 'fd', '','','ECO2', (report2(z,"fd")),China3E.modelstat / ;
put sce.tl, rate(z),'2012', 'ECO2', '','total' ,'','ECO2', (report2(z,"total")),China3E.modelstat / ;

loop(i,
  put sce.tl, rate(z),'2012', 'ESO2', i.tl, '','','ESO2', (report1(z,'so2',i)),China3E.modelstat / ;
) ;

put sce.tl, rate(z),'2012', 'ESO2', 'fd', '','','ESO2', (report1(z,'so2',"fd")),China3E.modelstat / ;
put sce.tl, rate(z),'2012', 'ESO2','' ,'total' ,'','ESO2', (report1(z,'so2',"total")),China3E.modelstat / ;

loop(i,
  put sce.tl, rate(z),'2012', 'ENOX', i.tl, '','','ENOX', (report1(z,'NOX',i)),China3E.modelstat / ;
) ;

put sce.tl, rate(z),'2012', 'ENOX', 'fd','' ,'','ENOX', (report1(z,'NOX',"fd")),China3E.modelstat / ;
put sce.tl, rate(z),'2012', 'ENOX', '','total' ,'','ENOX', (report1(z,'NOX',"total")),China3E.modelstat / ;

loop(sub_elec,
  put sce.tl, rate(z),'2012', 'elec_CO2','', sub_elec.tl ,'','elec_CO2' , (report3(z,sub_elec)),China3E.modelstat / ;
) ;


* ----- employment results
loop(lm,
  put sce.tl, rate(z),'2012', 'unemployment','' , '',lm.tl,'ur', (UR.l(lm)),China3E.modelstat / ;
  put sce.tl, rate(z),'2012', 'total employment', '', '',lm.tl,'total employment', (report6(z,lm,"total")),China3E.modelstat / ;
  put sce.tl, rate(z),'2012', 'aggregated wage', lm.tl, '',lm.tl,'aggregated wage', (pls.l(lm)),China3E.modelstat / ;

);


* ----- macro results
  put sce.tl, rate(z),'2012', 'GDP', '', '','','GDP', rgdp.l,China3E.modelstat / ;

*------- policy shock
  put sce.tl, rate(z),'2012', 'clim_a', '', '','','clim_a', clim_a,China3E.modelstat / ;
  put sce.tl, rate(z),'2012', 'clim0', '', '','','clim0', clim_a,China3E.modelstat / ;

loop(cm,
  put sce.tl, rate(z),'2012', 'clim_s', '', cm.tl,'','clim_s', clim_s(cm),China3E.modelstat / ;
);
