/******************************************
Sintaxis de evaluacion de pago de SSBB
Indicador: 4.1
Etapa 01_Definición de pago_Agua
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
global codigos "$ruta/codigos"

*1. Generamos la información para el calculo de pago de agua
********************************************
*1.1 Pago de agua
*****************

*a. Con suministro
******************
clear all
use "$input/UE_RECIBO_SSBB30042023", clear
*2886645-7
rename *, low
keep if ano_eje==2023
destring sec_ejec, replace
keep if tipo=="1"
rename suministro suministro_agua
merge m:m sec_ejec codigo_local codigo_modular suministro_agua using "$temp/agua.dta"

preserve
keep if _merge!=3 & tipo=="1" //Registros de agua que no cruzan con el padrón que deben ser revisado de porque no aparecen 
duplicates tag codigo_local codooii suministro_agua, gen(aah)
keep if aah>0
save "$input/nocruzan_aguasumi", replace
restore 
drop if _merge!=3


*Enero
preserve
keep if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="1"
*rename suministro suministro_agua
                generate fecha_e = dofc(fecha_emision)
                format fecha_e %td
                
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

gen enero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & tipo=="1" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_e>=td(08jan2023)

*Saldo a favor:
replace enero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & tipo=="1" & indicador_devengado=="DEVENGADO APROBADO" & ind_pago=="2" & valor_total==0

save "$temp\arenero23", replace
restore

*Febrero
preserve
keep if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="1"
*rename suministro suministro_agua
                generate fecha_e = dofc(fecha_emision)
                format fecha_e %td
                
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

gen febrero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & tipo=="1" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_e>=td(08feb2023)

*Saldo a favor:
replace febrero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & tipo=="1" & indicador_devengado=="DEVENGADO APROBADO" & ind_pago=="2" & valor_total==0

save "$temp\arfebrero23", replace
restore

*Marzo
preserve
keep if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="1"
*rename suministro suministro_agua
                generate fecha_e = dofc(fecha_emision)
                format fecha_e %td
                
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

gen marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & tipo=="1" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 
*& fecha_e>=td(08mar2023)

*Saldo a favor:
replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & tipo=="1" & indicador_devengado=="DEVENGADO APROBADO" & ind_pago=="2" & valor_total==0

*Agregando Indicador de TIPO_PAGO - CONSIDERA A LOS RECIBOS QUE ESTAN PENDIENTES DE DEVENGAR PERO QUE TIENEN PAGO

replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & tipo=="1" & indicador_devengado=="PENDIENTE" & ind_pago=="5" & descripcion_tipo_pago=="CON PAGO" & valor_total!=0		
			

*AGREGANDO LOS CASOS DE EXCEPCION
 generate fecha_v = dofc(fecha_vencimiento)
                format fecha_v %td
 
 gen mes_vencimiento=month(fecha_v)

 gen mes_emision=month(fecha_e)
	
replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & mes_vencimiento==3 & mes_emision==3 & tipo=="1" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0

replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & mes_emision==3 & tipo=="1" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0

save "$temp\armarzo23", replace
restore

*b.Sin suministro
*****************
clear all
use "$input\UE_RECIBO_SSBB_SIN_SUMIN30042023", clear
rename *, low
keep if ano_eje==2023
destring sec_ejec, replace
rename suministro suministro_agua
merge m:m sec_ejec codigo_local suministro_agua using "$temp/agua.dta"

preserve 
keep if _merge!=3 & tipo=="1" //Registros de agua que no cruzan con el padrón que deben ser revisado de porque no aparecen 
save "$input/nocruzan_aguasinsumi", replace
restore 
drop if _merge!=3

*Enero
preserve
keep if (ano_eje==2023)  & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & indicador_devengado=="DEVENGADO APROBADO"  & tipo=="1"
*rename suministro suministro_agua
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

keep if fecha_r>=td(01jan2023)

gen enero23=1 if (ano_eje==2023)  & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_r>=td(01jan2023)

save "$temp\asenero23", replace
restore

*Febrero
preserve
keep if (ano_eje==2023)  & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & indicador_devengado=="DEVENGADO APROBADO"  & tipo=="1"
*rename suministro suministro_agua
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

keep if fecha_r>=td(01feb2023)

gen febrero23=1 if (ano_eje==2023)  & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_r>=td(01feb2023)

save "$temp\asfebrero23", replace
restore

*Marzo
preserve
keep if (ano_eje==2023)  & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & indicador_devengado=="DEVENGADO APROBADO"  & tipo=="1"
*rename suministro suministro_agua
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

keep if fecha_r>=td(01mar2023)

gen marzo23=1 if (ano_eje==2023)  & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_r>=td(01mar2023)

save "$temp\asmarzo23", replace
restore

*c. Consolidando
****************

*c.1 Enero
**********
clear all
use "$temp\arenero23"
append using "$temp\asenero23"

merge m:m sec_ejec codigo_local codigo_modular suministro_agua using "$temp\agua", gen(m2)
replace enero23=0 if enero23==.
keep region sec_ejec codooii codigo_local codigo_modular suministro_agua tipo_agua ue iged tipo_entidad enero23           
save "$output\aguaenero", replace

*c.2 Febrero
************
clear all
use "$temp\arfebrero23"
append using "$temp\asfebrero23"

merge m:m sec_ejec codigo_local codigo_modular suministro_agua using "$input\agua", gen(m2)
replace febrero23=0 if febrero23==.
keep region sec_ejec codooii codigo_local codigo_modular suministro_agua tipo_agua ue iged tipo_entidad febrero23           
save "$output\aguafebrero", replace

*c.3 Marzo
**********
clear all
use "$temp\armarzo23"
append using "$temp\asmarzo23"

merge m:m sec_ejec codigo_local codigo_modular suministro_agua using "$input\agua", gen(m2)
replace marzo23=0 if marzo23==.
keep region sec_ejec codooii codigo_local codigo_modular suministro_agua tipo_agua ue iged tipo_entidad marzo23           
save "$output\aguamarzo", replace


merge m:m codigo_local codigo_modular suministro using "$output\aguaenero", keepusing(enero23) gen(m1)
drop m1

merge m:m codigo_local codigo_modular suministro using "$output\aguafebrero", keepusing(febrero23) gen(m1)
drop m1

rename (enero23 febrero23 marzo23 ue) (aguene23 agufeb23 agumar23 ue)

order region sec_ejec codooii ue iged codigo_local codigo_modular suministro_agua tipo_agua aguene23 agufeb23 agumar23

gen sumaagua=aguene23+agufeb23+agumar23

gen pagoagua=1 if sumaagua==3
replace pagoagua=0 if sumaagua<3
replace pagoagua=. if sumaagua==.

/*gen pagoagua=1 if aguene23==1 & agufeb23==1 & agumar23==1 
replace pagoagua=0 if aguene23==0 & agufeb23==1 & agumar23==1 
replace pagoagua=0 if aguene23==1 & agufeb23==0
replace pagoagua=0 if aguene23==0 & agufeb23==0
replace pagoagua=. if aguene23==. & agufeb23==.
replace pagoagua=0 if pagoagua==.*/

sort pagoagua

duplicates drop codigo_local codigo_modular suministro_agua, force

collapse (sum) aguene23 agufeb23 agumar23 pagoagua, by(codigo_local codigo_modular codooii sec_ejec ue suministro_agua)

save "$output/agua_sumipago", replace

sort pagoagua
collapse (sum) aguene23 agufeb23 agumar23 pagoagua, by(codigo_local codooii sec_ejec ue)
save "$output/pagoagua", replace

