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

*1. Importamos la información
*****************************
import excel "$input\20230531_184030_Formato_Resultados_RF2_CdD2023_UPP.xlsx", sheet("4.1") cellrange("A19:AA269") firstrow
rename *, low
drop w
rename (x y z aa) (numerador_final denominador_final valor_final cumplimiento_final)

gen difnum=(numerador_final - numerador)
gen difden=(denominador_final - denominador)
gen difvalor=(valor_final - valorlogrado)
gen difcump=(cumplimiento_final!=cumplimiento)

save "$temp\reporte_cumplimiento", replace

drop if estadodeevaluación=="No aplica"
drop if igedenvióobservacionesdeman=="No" & cumplimiento=="Excluida"

order región unidadejecutoradeeducación codigodeigedcodooii nombredeiged tipodeiged ndelindicador tipodeasignación estadodeevaluación meta numerador denominador valorlogrado cumplimiento numerador_final denominador_final valor_final cumplimiento_final difnum difden difvalor difcump igedenvióobservacionesdeman

drop if difcump==0
gen borrar=(difnum==difden==difvalor)

gen suma=difnum+difden+difvalor

drop if suma==0 | suma==.
sort difnum difden




