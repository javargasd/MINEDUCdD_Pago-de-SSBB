/******************************************
Sintaxis de evaluacion de pago de SSBB
Indicador: 4.1
Etapa 02_Definición de cumplimiento
Fecha:13032023
Elaborado por: Javier Vargas Díaz
*******************************************/

*0. Determinamos las rutas
**************************
clear all
global ruta "E:\CdD\Servicios Basicos\Tramo 2\Evaluacion"
global input "$ruta/input"
global temp  "$ruta/temp"
global output "$ruta/output"

*3. Generamos el cumplimiento
*****************************
use "$output/pagoluz"
merge m:m codigo_local codooii sec_ejec ue using "$output/pagoagua", keepusing(aguene23 agufeb23 agumar23 pagoagua)
br if codigo_local=="857790" | codigo_local=="011961" | codigo_local=="510879"
sort codigo_local
*duplicates drop codigo_local, force
save "$output/consolidado", replace

clear all
use "$temp/denomlocal"
merge m:m codooii codigo_local using "$output/consolidado", gen(m1)
br if codigo_local=="857790" | codigo_local=="011961" | codigo_local=="510879"
ta m1, m
br if m1!=3
duplicates tag codigo_local sec_ejec, gen(a)
br if a==1
sort codigo_local

bysort codigo_local: egen espejoaene23=total(aguene23)
bysort codigo_local: egen espejoafeb23=total(agufeb23)
bysort codigo_local: egen espejoamar23=total(agumar23)
bysort codigo_local: egen espejoapagoagua=total(pagoagua)

replace aguene23=espejoaene23 if a==1 & aguene23==.
replace agufeb23=espejoafeb23 if a==1 & agufeb23==.
replace agumar23=espejoamar23 if a==1 & agumar23==.
replace pagoagua=espejoapagoagua if a==1 & pagoagua==.
merge m:m codooii using "$input\padron_iged", gen(ss)
drop if codigo_local==""

merge m:m ue using "$input/dre_ue", gen(m22)
drop if m22!=3

br if a1==1
/*gen criterio=1 if a1==1 & tipo_entidad=="DRE EJECUTORA" | tipo_entidad=="GRE EJECUTORA" 
br if dre_ugel=="UGEL 14 OYON"

br if a==1
duplicates drop codigo_local, force
drop a
duplicates tag codigo_local, gen(a)
drop if a==1 & (tipo_entidad!="DRE EJECUTORA")*/

keep ue codigo_local divluz pagoluz divagua pagoagua

gen denominador=1
order codigo_local ue divagua pagoagua divluz pagoluz 
sort divluz

gen difluz=1 if divluz<=pagoluz & divluz!=0

gen difagua=1 if divagua<=pagoagua & divagua!=0

drop if ue==""

gen numluz=pagoluz/divluz
*replace numluz=round(pagoluz/divluz,1) if ue=="303-1508: GOB. REG. DE UCAYALI - EDUCACION CORONEL PORTILLO"
replace numluz=0 if numluz<1
replace numluz=1 if numluz>=1 & divluz!=0

gen numagua=pagoagua/divagua
replace numagua=0 if numagua<1
replace numagua=1 if numagua>=1 & divagua!=0

gen numerador=1 if numluz==1 & numagua==1
replace numerador=1 if numluz==1 & numagua==.
replace numerador=1 if numagua==1 & numluz==.

replace numerador=0 if numluz==0 & numagua==0
replace numerador=0 if numagua==0 & numluz==.
replace numerador=0 if numagua==. & numluz==0
replace numerador=0 if numagua==1 & numluz==0
replace numerador=0 if numagua==0 & numluz==1
duplicates tag codigo_local, gen(a)

collapse (sum) numerador denominador, by(ue) //403488

merge 1:1 ue using "$input/dre_ue"
drop _merge

save "$output/resultadoue", replace

collapse (sum) numerador denominador, by(region)
merge 1:m region using "$input/dre_ue"
keep if tipo_entidad!="UGEL EJECUTORA"

save "$output/resultadodre", replace

clear all
use "$output/resultadoue"
keep if tipo_entidad=="UGEL EJECUTORA"
append using "$output/resultadodre"
drop _merge

merge 1:1 ue using "$output/denom_final_t1", gen(m33)

*4. Evaluacion de cumplimiento
******************************
*replace codooii=220009 if codooii==220005
*drop dre_ugel region tipo_entidad
merge 1:1 codooii using "$input/metas_2023", gen(mewwe)
drop region denominador
rename (den Región) (denominador region)
order region codooii ue tipodeentidad metafinal numerador denominador 

gen double Valorlogrado_aux = .
	gen double decimas_valorlogrado = numerador/denominador - (floor(100*numerador/denominador)/100)
	replace Valorlogrado_aux = round(100*numerador/denominador,1)/100 if decimas_valorlogrado >= .005
	replace Valorlogrado_aux = numerador/denominador if decimas_valorlogrado < .005
gen Valorlogrado= numerador/denominador	
corr Valorlogrado_aux Valorlogrado
	
	replace Valorlogrado = Valorlogrado_aux
	drop Valorlogrado_aux decimas_valorlogrado
	gen Cumplimiento=.
	replace Cumplimiento = 1 if Valorlogrado >= metafinal & Valorlogrado!=.
	replace Cumplimiento = 0 if Valorlogrado < metafinal

merge 1:1 codooii using "$input/aleatorizacion_2023"
drop if _merge==2
keeporder region codooii unidadejecutora tipodeentidad aleat_2023 metafinal numerador denominador  Valorlogrado Cumplimiento

replace Cumplimiento=2 if Cumplimiento==.
label define Cumplimiento 1 "Cumplió" 0 "No cumplió" 2 "Excluida"
label values Cumplimiento Cumplimiento

*******************************
/*drop if _merge==2
replace grupo="DRE no aplica" if grupo==""
ta grupo Cumplimiento if grupo!="DRE no aplica"

drop m33 mewwe _merge

order region  sec_ejec codooii ue tipo_entidad grupo


drop _merge

/*drop _merge m33 mewwe ue

order region codooii sec_ejec unidadejecutora nombredeiged indicador tipodeentidad metafinal suministro

graph hbar denominador numerador if (tipodeentidad=="DRE EJECUTORA" | tipodeentidad=="GRE EJECUTORA"), over(region, sort(2))

sort Valorlogrado
twoway (kdensity metafinal if (tipodeentidad=="UGEL EJECUTORA")) (kdensity Valorlogrado if (tipodeentidad=="UGEL EJECUTORA") )
, over(region, sort(1))


bysort codigo_local: egen espejoafeb23=total(agufeb23)
bysort codigo_local: egen espejoapagoagua=total(pagoagua)

replace aguene23=espejoaene23 if a==1 & aguene23==.
replace agufeb23=espejoafeb23 if a==1 & agufeb23==.
replace pagoagua=espejoapagoagua if a==1 & pagoagua==.
merge m:m sec_ejec using "$input\sec_ejec", gen(ss)
drop if sec_ejec==.

****
merge m:m ue using "$input/dre_ue", gen(m22)
drop if m22!=3
*****
br if a==1
gen criterio=1 if a==1 & tipo_entidad=="DRE EJECUTORA" | tipo_entidad=="GRE EJECUTORA" 
br if dre_ugel=="UGEL 14 OYON"

br if a==1
duplicates drop codigo_local, force
drop a
duplicates tag codigo_local, gen(a)
drop if a==1 & (tipo_entidad!="DRE EJECUTORA")

keep ue codigo_local divluz pagoluz divagua pagoagua

*gen denominador=1
order codigo_local ue divagua pagoagua divluz pagoluz 
sort divluz

gen difluz=1 if divluz<=pagoluz & divluz!=0

gen difagua=1 if divagua<=pagoagua & divagua!=0

drop if ue==""

gen numluz=pagoluz/divluz
replace numluz=round(pagoluz/divluz,1) if ue=="303-1508: GOB. REG. DE UCAYALI - EDUCACION CORONEL PORTILLO"
replace numluz=0 if numluz<1
replace numluz=1 if numluz>=1 & divluz!=0

gen numagua=pagoagua/divagua
replace numagua=0 if numagua<1
replace numagua=1 if numagua>=1 & divagua!=0

gen numerador=1 if numluz==1 & numagua==1
replace numerador=1 if numluz==1 & numagua==.
replace numerador=1 if numagua==1 & numluz==.

replace numerador=0 if numluz==0 & numagua==0
replace numerador=0 if numagua==0 & numluz==.
replace numerador=0 if numagua==. & numluz==0
replace numerador=0 if numagua==1 & numluz==0
replace numerador=0 if numagua==0 & numluz==1
duplicates tag codigo_local, gen(a)

collapse (sum) numerador, by(ue) //403488

merge 1:1 ue using "$input/dre_ue"
drop _merge

save "$output/resultadoue", replace

collapse (sum) numerador, by(region)
merge 1:m region using "$input/dre_ue"
keep if tipo_entidad!="UGEL EJECUTORA"

save "$output/resultadodre", replace

clear all
use "$output/resultadoue"
keep if tipo_entidad=="UGEL EJECUTORA"
append using "$output/resultadodre"
drop _merge

merge 1:1 ue using "$output/denom_final", gen(m33)

/*4. Evaluacion de cumplimiento
******************************
replace codooii=220009 if codooii==220005
drop dre_ugel region tipo_entidad
merge 1:1 codooii using "$input/metas_2023", gen(mewwe)
drop dre_ugel tipodeentidad _merge
rename den denominador
order region codooii ue tipo_entidad meta numerador denominador 

gen double Valorlogrado_aux = .
	gen double decimas_valorlogrado = numerador/denominador - (floor(100*numerador/denominador)/100)
	replace Valorlogrado_aux = round(100*numerador/denominador,1)/100 if decimas_valorlogrado >= .005
	replace Valorlogrado_aux = numerador/denominador if decimas_valorlogrado < .005
gen Valorlogrado= numerador/denominador	
corr Valorlogrado_aux Valorlogrado
	
	replace Valorlogrado = Valorlogrado_aux
	drop Valorlogrado_aux decimas_valorlogrado
	gen Cumplimiento=.
	replace Cumplimiento = 1 if Valorlogrado >= meta & Valorlogrado!=.
	replace Cumplimiento = 0 if Valorlogrado < meta

merge 1:1 codooii using "$input/tratamiento_control"

drop if _merge==2
replace grupo="DRE no aplica" if grupo==""
ta grupo Cumplimiento if grupo!="DRE no aplica"

drop m33 mewwe _merge

order region  sec_ejec codooii ue tipo_entidad grupo

replace codooii=220009 if codooii==220005
label define Cumplimiento 1 "Cumplió" 0 "No cumplió"
label values Cumplimiento Cumplimiento