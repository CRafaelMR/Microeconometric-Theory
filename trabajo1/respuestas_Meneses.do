clear all
set more off
capture log close
global CARP "E:\Microeconometria\trabajo1"
use "$CARP\PROGRESA.dta", replace
foreach ado in psmatch2 coefplot scheme-burd estout{
    cap which `ado'
    if _rc!=0 ssc install `ado'
}

net from http://www.stata-journal.com/software/sj2-4
net install st0026

xtset iid t
*A.-
*revisamos la cantidad de niños o valores unicos de el numero de identificación(iid) usando el comando
codebook iid
*que nos muestra que son 28210 niños, la mitad de las observaciones totales. Esto es porque los datos son un panel de 28210x2 observaciones.

*luego, oocupamos el comando 
sum tcomm, d
*el cual nos da que el promedio de "tratamiento" es de 0,6056363. Este tratamiento por propiedad de variables binarias es el porcentaje de niños que han sido tratados.
*como este numero incluye todos los niños en ambos periodos, ocupamos el comando
sum tcomm if t==1 
*para confirmar que este promedio se mantiene incluso cuando controlamos por periodo. Esto es para asegurarnos que todos los niños que empezaron como control no fueron tratados y vice versa. 

*podemos usar el comando 
corr tcomm pobre
*para ver la correlación entre ambas variables. Este nos muestra una correlación positiva pero no unitaria por lo que hay niños pobres sin tratamiento y niños no-pobres siendo tratados. Para ver cuanto es esto, podemos aprevechar que ambas variables son boolianas para crear
gen focus=pobre-tcomm
codebook focus if t==1
*que nos muestra que de los 28210 niños, 5616 son no-pobres tratados y  7112 son pobres no-tratados, con el resto siendo o pobres tratados o no-pobres no-tratados


*la diferencia entre los niños que  fueron tratados y no dentro de una comunidad tratada se ve generando
tab pobre if t==1
tab pobre if t==1 & tcomm==1
tab pobre if t==1 & tcomm==0

*con lo que se ve que, de los 18581 niños pobres en el periodo 1, 10131 estaban en un territorio tratados y se inscribieron al programa, 5312 se inscribieron a pesar de no estar en una zona tratada, 2279 no se inscribieron a pesar de estar en una zona tratada y 851 tienen informacion perdida al respecto. Con esto, podemos decir que no todos los niños pobres en zonas de tratamiento fueron efectivamente tratados.
sum score if pobre==1
sum score if pobre==0
graph twoway scatter score pobre if pobre==1, msymbol(Oh) jitter(5) msize(vlarge)||scatter score pobre if pobre==0, msymbol(X) jitter(5) msize(vlarge) xlabel(0 "No-Pobres" 1 "Pobres") title("puntaje de riqueza respecto clasificacion de pobreza") ytitle("Puntaje") xtitle("Clasificación") legend(off)
graph export "$CARP\pobreza.png", replace

*B.-
*diferencia de medias es equivalente a una regresion simple sin controles si y solo si no existen porblemas de heterocedasticidad o autocorrelación.
reg enrolled tcomm if t==2



*C.-
*1
replace enrolled=L.enrolled if t==2
replace age=L.age+2 if t==2
pscore tcomm age hhincome female, pscore(px)

*2
graph twoway scatter px tcomm if tcomm==1, msymbol(Oh) jitter(5) msize(vlarge)||scatter px tcomm if tcomm==0, msymbol(X) jitter(5) msize(vlarge) xlabel(0 "Pueblos Control" 1 "Pueblos tratamiento") title("puntaje de pretensión respecto tratamiento") ytitle("Puntaje") xtitle("Clasificación de tratamiento") legend(off)
graph export "$CARP\pretencion.png", replace

*3

psmatch2 tcomm , out(enrolled) p(px)
scalar define attnn=r(att)
drop _pscore
drop _treated
drop _support
drop _weight
drop _enrolled
*advertencia: este siguiente comando se me ha demorado cerca de 20 minutos en compilar.
psmatch2 tcomm , kernel out(enrolled) p(px)
scalar define attk=r(att)
display attnn-attk
