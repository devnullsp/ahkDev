#Warn ALL
;--------------------------------------------------------------------
; varibles globales usadas en las funciones
;--------------------------------------------------------------------
GLOBAL DEVN_Reintentos := 20
GLOBAL DEVN_TiempoReintentos := 500

;--------------------------------------------------------------------
; Crea y devuelve un objeto I.E. (wb) puede ser con nivel medio
; no choque con entornos donde está activada la seguridad del windows
; sobre todo en versiones más modernas.
; esto ocurre cuando al inicial el IE abre una nueva pagina por lo
; que el objeto que devuelve no es el correcto.
; para más info: https://www.autohotkey.com/boards/viewtopic.php?t=21044
;--------------------------------------------------------------------
DEVN_IE(medium:=true){
	local pwb := ""
	local hwndwb := ""
	if(medium)
		pwb:= ComObjCreate("{D5E8041D-920F-45e9-B8FB-B1DEB82C6E5E}")
	else pwb:=ComObjCreate("InternetExplorer.Application")
	pwb.visible:=true
	hwndwb := pwb.hwnd
	WinMaximize ahk_id %hwndwb% 
	return pwb
}            

;--------------------------------------------------------------------
; Se usa para esperar que aparezca una página en concreto de entre varias
; aunque se puede usar para esperar que aparezca un elmento determinado,
; que es básicamente lo que hace.
; el parámetro des es una array de arrays conteniendo el mismo formato
; que DEVN_WBNodo donde se define el tag a buscar.
; si el ultimo parametro es false, no se muestra mensaje al operador para
; que pueda continuar. 
; Devuelve el indice del objeto encontrado o 0 en caso de que el operador
; diga que no continua o bien que se haya seleccionado false para esto.
;--------------------------------------------------------------------
DEVN_esperaPag(wb, des, msg:=true)
{
	Local vueltas := 0
	Local nodo := ""
	local i := 0
	Loop
	{
		if(vueltas = DEVN_Reintentos){
			if(!msg) 
				Return 0
			if(DEVN_MsgError(wb, des) )
				Return 0
			vueltas := 0
		}
		
		for i in des
		{
			try nodo := DEVN_WBNodo(wb, des[i,1], des[i,2], des[i,3], des[i,4],des[i,5])
			if(nodo != "")
				return i
		}
		vueltas+=1
		sleep %DEVN_TiempoReintentos%
	}
}

;--------------------------------------------------------------------
; Gestiona el mensaje de error de que no se ha encontrado la pagina
; (el elemento) pedido de la lista.
;--------------------------------------------------------------------
DEVN_MsgError(wb, des){
	Local cadena := ""
	Local i := 0
	Local origen := ""

	for i in des
		cadena .= "-> " des[i,1] " / " des[i,2] " / " des[i,3] " / " des[i,4] "`r`n"
	origen := ""
	MsgBox,4116,PAGINA DEL NAVEGADOR NO ENCONTRADA,REINTENTAR acceder a la página?`r`nCon destinos:`r`n%cadena%
	IfMsgBox No
		return true
	return false
}


;--------------------------------------------------------------------
; hace click en un elemento y espera que el navegador finalize al carga
; retorna wb control o "" en caso de error.
;--------------------------------------------------------------------
DEVN_Click(wb,atributo, tag, texto, parcial:=false, framepath:=""){
	try{
		DEVN_WBNodo(wb,atributo, tag, texto, parcial, framepath).click()
	}
	catch{
		return ""
	} 
	return DEVN_IE_DocumentoCompleto(wb)
}

;--------------------------------------------------------------------
; Navega y espera  a que el navegador finalize al carga
; retorna el propio IE o "" en caso de error.
;--------------------------------------------------------------------
DEVN_Navegar(wb, pagina){
	try{
		wb.Navigate(pagina) ; intento pinchar en el, si falla retorno
	}
	catch{
		return ""
	} 
	return DEVN_IE_DocumentoCompleto(wb)
}

;--------------------------------------------------------------------
; Busca un frame por el nombre
; Esto en HTML5 est� obsoleto pero se sigue usando... as� que....
;--------------------------------------------------------------------
DEVN_FramePorNombre(nodoRaiz,nombreFrame)
{
	Loop % (t := nodoRaiz.frames).length
		if(t[A_Index-1].name = nombreFrame) 
			return t[A_Index-1].document
	return ""
}

;--------------------------------------------------------------------
; Obtiene el elemento buscado.
; Devuelve un elemento del document o "" para indicar null.
; Si el atributo buscado es el ID no es necesario poner el tag, ya que buscara usando 
; document.getElementByID() en vez de getElementsByTagName
; He a�adido un array con el FramePath para poder cambiar el nodoRaiz para localizar.
; TODO: PONER NODO RAIZ
; TODO: HACER QUE EL FRAMEPATH SEA POR ID, NUMERO O NOMBRE.
;--------------------------------------------------------------------
DEVN_WBNodo(wb, atributo, tag, texto, parcial:=false, framepath:="")
{
	Local nodoRaiz := wb.document
	local t:=[]
	loop % framepath.length()
	{
		nodoRaiz := DEVN_FramePorNombre(nodoRaiz,framepath[A_Index])
		if(nodoRaiz = "") ; no se ha encontrado el Frame
			return ""
	}
	if(format("{:U}",atributo) = "ID")
		return nodoRaiz.getElementByID(texto)
	Loop % (t := nodoRaiz.getElementsByTagName(tag)).length
		if(parcial){
			if(InStr(t[A_Index-1].getAttribute(atributo) , texto))
				Return t[A_Index-1]
		}else if(t[A_Index-1].getAttribute(atributo) = texto)
					Return t[A_Index-1]
	Return ""
}

;--------------------------------------------------------------------
; Busca una lengueta en el IEXPLORE.EXE por defecto
; usando el path
;--------------------------------------------------------------------
DEVN_IE_BuscarPagURL(texto, prg:="IEXPLORE")
{
	local pwb:=""
	for pwb in ComObjCreate("Shell.Application").Windows
	{
		if( InStr(pwb.FullName, prg) > 0)
			if(InStr(pwb.LocationURL, texto) > 0)
				return pwb
	}
	return ""
}

;-------------------------------------------------------------------------
; control de fin de carga
;-------------------------------------------------------------------------
DEVN_IE_DocumentoCompleto(wb){
	loop{
		try{
			while(wb.readyState != 4 && wb.document.readyState != "complete" && wb.busy && A_Index < 150){
				Sleep 100
			}
			if(A_Index = 150)
				return ""
			return wb
		}
		sleep 100
	}
}