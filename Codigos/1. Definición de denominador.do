/******************************************
Sintaxis de evaluacion de pago de SSBB
Indicador: 4.1
Etapa 01_Definición de denominador
Fecha:12052023
Elaborado por: Javier Vargas Díaz
*******************************************/

*0. Determinamos las rutas
**************************
clear all
global ruta "E:\CdD\Servicios Basicos\Tramo 2\Evaluacion"
global input "$ruta/input"
global temp  "$ruta/temp"
global output "$ruta/output"
global codigos "$ruta/codigos"

/*Padron EIB (Mantequilla)
*************************
import excel using "$input/Registro Nacional IIEE_EIB_2022.xlsx", firstrow sheet("Sheet1") cellrange(A2:R28186) 
rename (Códigomodular Códigodelocaleducativo) (codigo_modular codigo_local)
keep codigo_local codigo_modular Nombredelenguaoriginaria1 Nombredelenguaoriginaria2 Nombredelenguaoriginaria3 Estado FormadeatenciónEIB
order codigo_local
save "$temp/padroneib", replace*/

*1. Preparamos la información de los padrones
********************************************* 
clear all
foreach type in agua luz {
	import excel "$input/padron-ssbb-2023_final_t1.xlsx", firstrow sheet("`type'") clear //padron publicado
    rename *, low
	drop if sec_ejec==.
    rename codigo_ugel codooii
	gen sec_ejecupp=sec_ejec
	drop sec_ejec
    destring codooii, replace
    merge m:1 codooii using "$input/padron_iged.dta", gen(m1)
    drop if m1!=3
    tostring tipo, replace
    rename (tipo descripcion_tipo suministro) (`type' descripcion_`type' suministro_`type')
    drop m1
	gen local=codigo_local
	gen modular=codigo_modular
	gen sumin_`type'=suministro_`type'
	destring local modular sumin_`type', replace
	egen id_1=concat(local modular sumin_`type')
	drop local modular sumin_`type'
	save "$input/`type'", replace
}

*2. Limpiamos el denominador
****************************
use "$input/agua", clear
	duplicates report sec_ejec codigo_local codigo_modular suministro_agua
	duplicates tag sec_ejec codigo_local codigo_modular suministro_agua, gen(a)
	br if a==1
	sort codigo_modular
	
	*Comentario: limpieza de casos con o sin suministro
	gen espejo=1 if tipo_agua=="SIN SUMINISTRO"
	replace espejo=0 if espejo==.
	bysort codigo_modular: egen sum_espejo= total(espejo)
	drop if sum_espejo==1 & a==1 & tipo_agua=="SIN SUMINISTRO"
	gen id=codigo_local+codigo_modular+suministro_agua
	merge m:1 codooii using "$input/padron_iged.dta", gen(m2)
	drop if m2!=3
	drop  espejo sum_espejo a m2
	save "$temp/agua", replace
	
	
use "$input/luz", clear
	duplicates report sec_ejec codigo_local codigo_modular suministro_luz
	duplicates tag sec_ejec codigo_local codigo_modular suministro_luz, gen(a)
	br if a==1
	sort codigo_modular
	
	*Comentario: limpieza de casos con o sin suministro
	gen espejo=1 if tipo_luz=="SIN SUMINISTRO"
	replace espejo=0 if espejo==.
	bysort codigo_modular: egen sum_espejo= total(espejo)
	drop if sum_espejo==1 & a==1 & tipo_luz=="SIN SUMINISTRO"
	gen id=codigo_local+codigo_modular+suministro_luz
	merge m:1 codooii using "$input/padron_iged.dta", gen(m2)
	drop if m2!=3
	drop  espejo sum_espejo a m2
	save "$temp/agua", replace


	
	
	
	
	
	
	
	
	

foreach type in agua luz{
	use "$input/`type'", replace
	duplicates report sec_ejec codigo_local codigo_modular suministro_`type'
	duplicates tag sec_ejec codigo_local codigo_modular suministro_`type', gen(a)
	br if a==1
	sort codigo_modular
	
	*Comentario: limpieza de casos con o sin suministro
	gen espejo=1 if tipo_`type'=="SIN SUMINISTRO"
	replace espejo=0 if espejo==.
	bysort codigo_modular: egen sum_espejo= total(espejo)
	drop if sum_espejo==1 & a==1 & tipo_`type'=="SIN SUMINISTRO"
	gen id=codigo_local+codigo_modular+suministro
	merge m:1 codooii using "$input/padron_iged.dta", gen(m2)
	drop if m2!=3
	drop  espejo sum_espejo a m2
	save "$temp/`type'", replace
}

*3. Definición de denominador
*****************************
clear
use "$temp/luz"

*Comentario: Generamos un codigo id 
egen id_luz=concat(codigo_local codigo_modular suministro_luz)
duplicates tag id_luz, gen(a)
br if a==1
duplicates drop id_luz, force

merge m:m codigo_local codigo_modular codooii using "$temp/agua"
drop id_luz

gen pagoluz=1 if luz=="2"
gen pagoagua=1 if agua=="1"
duplicates tag codigo_local codigo_modular suministro_agua, gen(aguadupli)
duplicates tag codigo_local codigo_modular suministro_luz, gen(luzdupli)
replace aguadupli=aguadupli+1 
replace luzdupli=luzdupli+1 
gen divagua=pagoagua/aguadupli
gen divluz=pagoluz/luzdupli

br if codigo_local=="403488"
/*403488
474819*/

/*merge m:m codigo_local codigo_modular using "$temp/padroneib", gen(eib1)
drop if eib1==2
drop eib1
gen eib1=1 if FormadeatenciónEIB!=""*/

collapse (sum) divagua divluz, by(codooii codigo_local)

merge m:m codooii using "$input/padron_iged.dta"
drop if _merge!=3
drop _merge
merge m:1 ue using "$input/dre_ue.dta"
drop if _merge!=3
drop _merge
duplicates report codigo_local
duplicates tag codigo_local, gen(a1)
br if a1==1
sort codigo_local

merge m:m sec_ejec using "$input/sec_ejec.dta"
drop if a1==.
*duplicates drop codigo_local, force
save "$temp/denomlocal", replace

gen den=1
gen suministro=divagua+divluz
collapse (sum) den suministro, by(ue)

save "$output/denomlocalue", replace

/*merge m:1 ue using "$input/dre_ue.dta"
keep if tipo_entidad=="UGEL EJECUTORA"
save "$output/denomlocalue", replace*/

*3.2. Consolidado denominador
*****************************
clear all
use "$output/denomlocalue" 
merge m:1 ue using "$input/dre_ue.dta"
collapse (sum) den suministro, by(region)
merge m:m region using "$input/dre_ue.dta"
keep if tipo_entidad!="UGEL EJECUTORA"
save "$output/denomlocaldre", replace

clear all
use "$output/denomlocalue" 
merge m:1 ue using "$input/dre_ue.dta"
keep if tipo_entidad=="UGEL EJECUTORA"
append using "$output/denomlocaldre"
drop _merge

duplicates drop codooii, force
order region codooii ue iged tipo_entidad den
save "$output/denom_final_t1", replace
sort region

export excel region codooii ue iged tipo_entidad den using "$temp\denominador_finalt1.xlsx", firstrow(variables) replace

*graph hbar eib if (tipo_entidad=="DRE EJECUTORA" | tipo_entidad=="GRE EJECUTORA"), over(region, sort(1))
