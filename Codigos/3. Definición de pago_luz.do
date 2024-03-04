/******************************************
Sintaxis de evaluacion de pago de SSBB
Indicador: 4.1
Etapa 02_Definición de pago_Luz
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

*2. Generamos la información para el calculo de pago de luz
*****************************************************

*2.1 Pago de luz
****************

*a. Con suministro
******************
clear all
use "$input/UE_RECIBO_SSBB30042023", clear
rename *, low
keep if ano_eje==2023
destring sec_ejec, replace
keep if tipo=="2"
rename suministro suministro_luz
merge m:m sec_ejec codigo_local  codigo_modular suministro_luz using "$temp/luz.dta"
br if _merge!=3
preserve 
keep if _merge!=3 & tipo=="2" //Registros de luz que no cruzan con el padrón que deben ser revisado de porque no aparecen 
save "$input/nocruzan_luzsumi", replace
restore 
drop if _merge!=3

*Enero
preserve
keep if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="2"
*rename suministro suministro_luz
                generate fecha_e = dofc(fecha_emision)
                format fecha_e %td
                
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

gen enero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & tipo=="2" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_e>=td(08jan2023)

*Saldo a favor:
replace enero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & tipo=="2" & indicador_devengado=="DEVENGADO APROBADO" & ind_pago=="2" & valor_total==0

*Prepago:
replace enero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="2" & indicador_prepago=="1" & valor_total!=0

save "$temp\lrenero23", replace
restore

*Febrero

preserve
keep if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="2"
*rename suministro suministro_luz
                generate fecha_e = dofc(fecha_emision)
                format fecha_e %td
                
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

gen febrero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & tipo=="2" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_e>=td(08feb2023)

*Saldo a favor:
replace febrero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & tipo=="2" & indicador_devengado=="DEVENGADO APROBADO" & ind_pago=="2" & valor_total==0

*Prepago:
replace febrero23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="2" & indicador_prepago=="1" & valor_total!=0

save "$temp\lrfebrero23", replace
restore

*Marzo
preserve
keep if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="2"
*rename suministro suministro_luz
                generate fecha_e = dofc(fecha_emision)
                format fecha_e %td
                
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

gen marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & tipo=="2" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 
*& fecha_e>=td(08mar2023)

*Saldo a favor:
replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & tipo=="2" & indicador_devengado=="DEVENGADO APROBADO" & ind_pago=="2" & valor_total==0

*Prepago:
replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & indicador_devengado=="DEVENGADO APROBADO" & tipo=="2" & indicador_prepago=="1" & valor_total!=0

*Agregando Indicador de TIPO_PAGO - CONSIDERA A LOS RECIBOS QUE ESTAN PENDIENTES DE DEVENGAR PERO QUE TIENEN PAGO

replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & tipo=="2" & indicador_devengado=="PENDIENTE" & ind_pago=="5" &descripcion_tipo_pago=="CON PAGO" & valor_total!=0		
			

*AGREGANDO LOS CASOS DE EXCEPCION
 generate fecha_v = dofc(fecha_vencimiento)
                format fecha_v %td
 
 gen mes_vencimiento=month(fecha_v)

 gen mes_emision=month(fecha_e)
	
replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & mes_vencimiento==3 & mes_emision==3 & tipo=="2" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0

replace marzo23=1 if (ano_eje==2023) & ano_recibo==2023 & mes_recibo=="03" & mes_emision==3 & tipo=="2" & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0

save "$temp\lrmarzo23", replace
restore

*b. Sin suministro
******************
clear all
use "$input\UE_RECIBO_SSBB_SIN_SUMIN30042023", clear
rename *, low
keep if ano_eje==2023
destring sec_ejec, replace
rename suministro suministro_luz
merge m:m sec_ejec codigo_local suministro using "$temp/luz.dta"

preserve 
keep if _merge!=3 & tipo=="2" //Registros de agua que no cruzan con el padrón que deben ser revisado de porque no aparecen 
save "$input/nocruzan_luzsinsumi", replace
restore 
drop if _merge!=3

*Enero
preserve
keep if (ano_eje==2023)  & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & indicador_devengado=="DEVENGADO APROBADO"  & tipo=="2"
*rename suministro suministro_luz
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

keep if fecha_r>=td(01jan2023)

gen enero23=1 if (ano_eje==2023)  & mes_recibo=="01" & (mes_calend=="01" | mes_calend=="02") & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_r>=td(01jan2023)

save "$temp\lsenero23", replace
restore

*Febrero
preserve
keep if (ano_eje==2023)  & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & indicador_devengado=="DEVENGADO APROBADO"  & tipo=="2"
*rename suministro suministro_luz
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

keep if fecha_r>=td(01feb2023)

gen febrero23=1 if (ano_eje==2023)  & mes_recibo=="02" & (mes_calend=="02" | mes_calend=="03") & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_r>=td(01feb2023)

save "$temp\lsfebrero23", replace
restore

*Marzo
preserve
keep if (ano_eje==2023)  & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & indicador_devengado=="DEVENGADO APROBADO"  & tipo=="2"
*rename suministro suministro_luz
                generate fecha_r = dofc(fecha_reg_cab)
                format fecha_r %td

keep if fecha_r>=td(01mar2023)

gen marzo23=1 if (ano_eje==2023)  & mes_recibo=="03" & (mes_calend=="03" | mes_calend=="04") & indicador_devengado=="DEVENGADO APROBADO" & valor_total!=0 & fecha_r>=td(01mar2023)

save "$temp\lsmarzo23", replace
restore

*c. Consolidando
****************

*c.1 Enero
**********
clear all
use "$temp\lrenero23"
append using "$temp\lsenero23"

merge m:m sec_ejec codigo_local codigo_modular suministro using "$temp\luz", gen(m2)
replace enero23=0 if enero23==.
keep region sec_ejec codooii codigo_local codigo_modular suministro tipo_luz ue iged tipo_entidad enero23           
save "$output\luzenero", replace

*c.2 Febrero
************
clear all
use "$temp\lrfebrero23"
append using "$temp\lsfebrero23"

merge m:m sec_ejec codigo_local codigo_modular suministro using "$input\luz", gen(m2)
replace febrero23=0 if febrero23==.
keep region sec_ejec codooii codigo_local codigo_modular suministro tipo_luz ue iged tipo_entidad febrero23           
save "$output\luzfebrero", replace

*c.2 Marzo
**********
clear all
use "$temp\lrmarzo23"
append using "$temp\lsmarzo23"

merge m:m sec_ejec codigo_local codigo_modular suministro using "$input\luz", gen(m2)
replace marzo23=0 if marzo23==.
keep region sec_ejec codooii codigo_local codigo_modular suministro tipo_luz ue iged tipo_entidad marzo23           
save "$output\luzmarzo", replace

merge m:m codigo_local codigo_modular suministro using "$output\luzenero", keepusing(enero23) gen(m1)
drop m1

merge m:m codigo_local codigo_modular suministro using "$output\luzfebrero", keepusing(febrero23) gen(m1)
drop m1

rename (enero23 febrero23 marzo23 ue) (luzene23 luzfeb23 luzmar23 ue)

order region sec_ejec codooii ue iged codigo_local codigo_modular suministro tipo_luz luzene23 luzfeb23 luzmar23

gen sumaluz=luzene23+luzfeb23+luzmar23

gen pagoluz=1 if sumaluz==3
replace pagoluz=0 if sumaluz<3
replace pagoluz=. if sumaluz==.

/*gen pagoluz=1 if luzene23==1 & luzfeb23==1  
replace pagoluz=0 if luzene23==0 & luzfeb23==1
replace pagoluz=0 if luzene23==1 & luzfeb23==0
replace pagoluz=0 if luzene23==0 & luzfeb23==0*/

/*gen pagoluz=1 if sum==1
*luzene23==1 & luzfeb23==1
replace pagoluz=0 if luzene23==0 //& luzfeb23==0
replace pagoluz=. if luzene23==.
//replace pagoluz=. if luzfeb23==.

replace pagoluz=0 if pagoluz==.*/

duplicates drop codigo_local codigo_modular suministro_luz, force

sort pagoluz

collapse (sum) luzene23 luzfeb23 luzmar23 pagoluz, by(codigo_local codigo_modular codooii sec_ejec ue suministro_luz)
save "$output\luz_sumipago", replace

collapse (sum) luzene23 luzfeb23 luzmar23 pagoluz, by(codigo_local codooii sec_ejec ue)
save "$output/pagoluz", replace