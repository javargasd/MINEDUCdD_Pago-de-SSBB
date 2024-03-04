/******************************************
Sintaxis de evaluacion de pago de SSBB
Indicador: 4.1
Etapa 03_Validación de resultados
Fecha:31052023
Elaborado por: Javier Vargas Díaz / Katherine De La Cruz Gonzales
*****************************************************************/

*0. Determinamos las rutas
**************************
clear all
global ruta "E:\Servicios Basicos\Tramo 2\Evaluacion\"
global input "$ruta/input"
global temp  "$ruta/temp"
global output "$ruta/output"

*1. Generamos la base de pago por suministro
********************************************
clear
use "$output\agua_sumipago"
rename (suministro_agua aguene23 agufeb23 agumar23 pagoagua) (suministro ene23_ufd feb23_ufd mar23_ufd pago_ufd)
gen tipo="AGUA"

save "$output\agusumipago", replace

clear
use "$output\luz_sumipago"
rename (suministro_luz luzene23 luzfeb23 luzmar23 pagoluz) (suministro ene23_ufd feb23_ufd mar23_ufd pago_ufd)
gen tipo="LUZ"

save "$output\luzsumipago", replace

append using "$output\agusumipago"

sort ue codigo_local codigo_modular suministro

merge m:1 codooii using "$input\padron_iged", keepusing(iged region tipo_entidad)
keep if _merge==3
drop _merge
save "$output\consolidado_suministro", replace

*2. Generamos la base de pagos de SIGA
**************************************
clear
use "$input/UE_RECIBO_SSBB30042023"
rename *, low
keep if ano_eje==2023
keep sec_ejec nombre_ejecutora descripcion_tipo descripcion_pago_suministro codigo_local codigo_modular codigo_ugel indicador_devengado mes_recibo mes_calend indicador_devengado tipo fecha_emision fecha_reg_cab valor_total ind_pago descripcion_tipo_pago fecha_vencimiento suministro descripcion_tipo_pago

save "$output/recibos30042023", replace

clear
use "$input\UE_RECIBO_SSBB_SIN_SUMIN30042023"
rename *, low
keep if ano_eje==2023
keep sec_ejec nombre_ejecutora descripcion_tipo descripcion_pago_suministro codigo_local codigo_modular codigo_ugel indicador_devengado mes_recibo mes_calend indicador_devengado tipo fecha_reg_cab valor_total ind_pago fecha_vencimiento suministro descripcion_tipo_pago

save "$output/sinrecibos30042023", replace

append using "$output/sinrecibos30042023"

save "$output\pago_siga", replace

*3 Importamos la información remitida por UPP
*********************************************
clear 
import excel using "$input\Base_Luz-Agua Tramo 02 -2023_modufd.xlsx", sheet("LUZ") firstrow
rename *, low
drop tipo
rename (descripcion_tipo lene_2023_preupp lfeb_2023_preupp lmar_2023_preupp quiénrevisa lene_2023_finupp lfeb_2023_finupp lmar_2023_finupp) (tipo ene_2023_preupp feb_2023_preupp mar_2023_preupp quiénrevisa ene_2023_finupp feb_2023_finupp mar_2023_finupp)
save "$input\LUZrevobsupp", replace

clear 
import excel using "$input\Base_Luz-Agua Tramo 02 -2023_modufd.xlsx", sheet("AGUA") firstrow
rename *, low
drop tipo
rename (descripcion_tipo aene_2023_preupp afeb_2023_preupp amar_2023_preupp quiénrevisa aene_20233_finupp afeb_20234_finupp amar_20235_finupp) (tipo ene_2023_preupp feb_2023_preupp mar_2023_preupp quiénrevisa ene_2023_finupp feb_2023_finupp mar_2023_finupp)
save "$input\AGUArevobsupp", replace

append using "$input\LUZrevobsupp"

save "$output\revobsupp_consolidado", replace