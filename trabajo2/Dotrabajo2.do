clear all
set more off
global CARP "E:\documentos que si importan\Microeconometria\trabajo2"
cd "$CARP"
*instalamos comandos que podrian ser utiles en el documento
foreach ado in psmatch2 coefplot scheme-burd estout boottest{
    cap which `ado'
    if _rc!=0 ssc install `ado', all
}
ssc install boottest, replace

*instalamos la primera opcion de ado para controles sintéticos, Synth de el ssc oficial.
ssc install synth, all replace
*la segunda opcion es el comando Synth_runner de github. para instalarlo primero desisntalamos la versión anterior, para luego reinstalarla
cap ado uninstall synth_runner
net install synth_runner, from("https://raw.github.com/bquistorff/synth_runner/master/") replace
*convocamos la base de datos de Abadie(2010) descargados a traves de synth_runner
sysuse synth_smoking, clear
tsset state year
set scheme burd4 

*1a*
*ocupamos primero el comando Synth promovido por las instrucciones*
synth cigsale beer(1984(1)1988) lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975),trunit(3) trperiod(1989) gen_vars fig
*este comando nos genera el grafico de efectos
*luego, ocupamos el equivalente Synth_runner. Sus resultados son equivalentes.*
synth_runner cigsale beer(1984(1)1988) lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975), trunit(3) trperiod(1989) gen_vars
*1b*

effect_graphs , trlinediff(-1) effect_gname(efecto_synthrunner) tc_gname(controlsynt_synthrunner) tc_options(pleg(plos(0) bplace(ne)) saving(controlsynt_synthrunner , asis replace)) effect_options(ylabels(-30(10)30) saving(efecto_synthrunner , asis replace))

*2a*
*podemos generar un contrafactual sintetico a cada uno de los estados que no son California:
foreach state of num 1 2 4/39{
synth cigsale beer(1984(1)1988) lnincome retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975), trunit(`state') trperiod(1989)

}
*2b*
synth_runner cigsale beer(1984(1)1988) lnincome(1972(1)1997) retprice age15to24 cigsale(1988) cigsale(1980) cigsale(1975),trunit(3) trperiod(1989)
single_treatment_graphs, trlinediff(-1) raw_gname(cigsale1_raw) do_color(gray) effects_gname(cigsale1_effects) effects_ylabels(-30(10)30) effects_ymax(35) effects_ymin(-35)


*3a*
gen tratados=0
replace tratados=1 if state==3 & year>=1988
eststo: reg cigsale tratados i.state i.year
*3b*
eststo: reg cigsale tratados i.state i.year, cluster(state)
*hacemos un bootstrap clusterizado por estado que nos arrojará un grafico de densidad. Este nos permitirá generar un intervalo de confianza. Este es menos confiable que el cluster siguiente.
boottest tratados, cluster(state year) bootcluster(state)
*hacemos un bootstrap clusterizado por estado y año que nos arrojará un grafico de densidad. Este nos permitirá generar un intervalo de confianza del efecto promedio.
boottest tratados, cluster(state year) bootcluster(state year)
esttab est1 est2 ,se(%3.2f) b(3) star(* 0.1 ** 0.05 *** 0.01) keep(tratados)  title("Efecto de la Proposición 99") mtitles("MCO" "MCO clusterizado") 

*4a
*generamos el efecto del tratamiento. La variable effect es generada automaticamente por synth_runner asi que para clacular el ATE solo debemos sacar el promedio del efecto en aquellas observaciones que sean posteriores a 1988 y en california.
*como synth_runner genera todos los controles sinteticos simultaneamente, effect tiene una observacion para cada observacion original.
gen TE=.
replace TE=effect*tratado if tratado==1
mean TE
