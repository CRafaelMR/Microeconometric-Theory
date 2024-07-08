clear all
set more off
global CARP "E:\documentos que si importan\Microeconometria\trabajo3"
cd "$CARP"
net install rddensity, from("https://sites.google.com/site/rdpackages/rddensity/stata") replace
net install lpdensity, from("https://sites.google.com/site/nppackages/lpdensity/stata")replace
net install rdrobust, from("https://sites.google.com/site/rdpackages/rdrobust/stata") replace
*A
*1.-usamos base de datos de Dell(2015)
use DrugTrafficking, clear
*generamos la version lineal de la relacion de una victoria del PAN y el margen de vitoria
gen WinDiffLineal=PANwin*VoteDifference
gen LoseDiffLineal=(1-PANwin)*VoteDifference
reg HomicideRate PANwin WinDiffLineal LoseDiffLineal 
*2.-
gen WinDiffquad=(PANwin)*VoteDifference^2
gen LoseDiffquad=(1-PANwin)*VoteDifference^2
reg HomicideRate PANwin WinDiffLineal LoseDiffLineal WinDiffquad LoseDiffquad 
*3.-
rdplot HomicideRate VoteDifference, nbins(10 10) p(2) kernel(triangular)

*4.-Teorico
*5.- 
rddensity VoteDifference, c(0) plot


*B
clear all

*1.-
set obs 100
gen x=rnormal()
gen w= 0
replace w =1 if x>=0
gen y=2-0.5*x+0.1*x^2+1.7*x^3+5*w


*2.-grafico
twoway scatter y x if w==0, mlc(blue)|| scatter y x if w==1, mlc(red)
*3.-
gen coefficients = .
gen deviation=.
gen observations=.
gen cutoff = .
gen xw=x*w
gen wx=x*(1-w)
*regresion discontinua con ecuacion lineal a ambos lados
local i = 1
foreach num of numlist 0.1(0.1)2 {
reg y xw wx w if x>`num'|x<-`num'
replace coefficients = _b[w] in `i'
replace deviation = _se[w] in `i'
replace observations=_n in `i'
replace cutoff = -`num' in `i'
local i = `i'+1
}
scatter coefficients cutoff|| scatter deviation  cutoff||scatter observations cutoff
*si en vez aplicamos una ecuacion de tres dimensiones como muestra la ecuacion original
gen xxw=x*xw
gen wxx=wx*x
gen wxxx=wxx*x
gen xxxw=xxw*x

local i = 1
foreach num of numlist 0.1(0.1)2 {
reg y xw xxw xxxw wx wxx wxxx w if x>`num'|x<-`num'
replace coefficients = _b[w] in `i'
replace deviation = _se[w] in `i'
replace observations=_n in `i'
replace cutoff = -`num' in `i'
local i = `i'+1
}
scatter coefficients cutoff|| scatter deviation  cutoff||scatter observations cutoff
*4.-
rdbwselect y x, c(0) p(1) all
