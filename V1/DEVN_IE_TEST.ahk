#SingleInstance force
#include %A_ScriptDir%\DEVN_IE.ahk
;----------------------------------------------------------------
; Este ejemplo abre un navegador nuevo
; navega a una web y espera que hayan podido aparecer dos paginas distintas, el login o la de datos
; si es el login acaba, si es la aplicativa, hace una navegación.
; en este ejemplo se pueden ver como se controla en una pagina con multiples frames.
; Si ya se esta idenficado se salta la pagina de identificación.
; En caso contrario se procede a esperar a la identificación.
;-------------------------------------------------------------------------------------------------
; Abro el navegador
wb := DEVN_IE()
; Navego a la url requerida
DEVN_Navegar(wb,"https://pro02.ia.lacaixa.es/apw5/ssissi/verif_entrada.do")
; espero a que exista alguna de estas dos paginas, (o sea que haya un componente que cumpla las condiciones)
pagNum:=DEVN_esperaPag(wb,[["innerText","H1","Buscador de funcionalidades",,["contingut","principal"]],["innerText","H2","Identifica", true]])
; Si es 0 es que no lo ha encontrado y el operador ha dicho que no.
if(pagNum=0){
	ExitApp
}
; estoy en la identificación
if(pagNum = 2)
{
	DEVN_WBNodo(wb,"name","INPUT","empresa").value:="U.U"
	msgbox estoy en la pagina de identificacion, He puesto la empres de mentira (U.U) `n`r Pulsa Bien cuando te hayas identificado correctamente.
}
;ahora un poco de navegación (no se esperan que aparezcan paginas distintas
msgbox estoy en la de funcionalidades PASO A ROLES.
DEVN_CLICK(wb,"InnerText","A","Roles",true,["menu"])
msgbox estoy en la de role PASO A ROLES PARA EMPLEADOS.
DEVN_CLICK(wb,"id","","pesnivel21",true,["menu"])
msgbox Listo, fin de navegacion.

;-----------------------------------------------------------------------------------------------
; ATENCION ATENCION
; Lo complicado es el control de los frames, ya que yo lo uso por nombres.
; Queda pendiente el uso por id y por numero
;------------------------------------------------------------------------------------------------------

