#Warn ALL
;--------------------------------------------------------------------
; varibles globales usadas en las funciones
;--------------------------------------------------------------------
GLOBAL DEVN_Load := false
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
DEVN_IE(medium:=false){
	if(medium)
		return ComObjCreate("{D5E8041D-920F-45e9-B8FB-B1DEB82C6E5E}")
	return ComObjCreate("InternetExplorer.Application")
}            

;--------------------------------------------------------------------
; Eventos del IE tratados por la libreria
; Actualmente sólo el evento de la carga completa de documentos.
;--------------------------------------------------------------------
DEVN_EVENT_DocumentComplete() { 
	DEVN_Load := false	
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
	Local pag := ""
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
			try pag := DEVN_WBNodo(wb, des[i,1], des[i,2], des[i,3], (des.lengh = 4 and des[i,4]) )
			/*
			if(des.lengh = 4 and des[i,4])
				try pag := DEVN_WBNodo(wb, des[i,1], des[i,2], des[i,3], des[i,4])
			else
				try pag := DEVN_WBNodo(wb, des[i,1], des[i,2], des[i,3])
			*/
			if(pag != "")
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
; retorna el propio control o "" en caso de error.
;--------------------------------------------------------------------
DEVN_Click(wb, ctrl){
	ComObjConnect(wb, "DEVN_EVENT_") 
	DEVN_Load := true
	try{
		ctrl.click() ; intento pinchar en el, si falla retorno
	}
	catch{
		DEVN_Load := false
		ComObjConnect(wb, "")
		return ""
	} 
	while DEVN_Load
		Sleep 200
	ComObjConnect(wb, "")
	return ctrl
}

;--------------------------------------------------------------------
; Navega y espera  a que el navegador finalize al carga
; retorna el propio IE o "" en caso de error.
;--------------------------------------------------------------------
DEVN_Navegar(wb, pagina){
	ComObjConnect(wb, "DEVN_EVENT_") 
	DEVN_Load := true
	try{
		wb.Navigate(pagina) ; intento pinchar en el, si falla retorno
	}
	catch{
		DEVN_Load := false
		ComObjConnect(wb, "")
		return ""
	} 
	while DEVN_Load
		Sleep 200
	ComObjConnect(wb, "")
	return wb
}

;--------------------------------------------------------------------
; Obtiene el elemento buscado.
; Devuelve un elemento del document o "" para indicar null.
; Si el atributo buscado es el ID no es necesario poner el tag, ya que buscara usando 
; document.getElementByID() en vez de getElementsByTagName
;--------------------------------------------------------------------
DEVN_WBNodo(wb, atributo, tag, texto, parcial:=false)
{
	local t:=[]
	if(format("{:U}",atributo) = "ID")
		return wb.Document.getElementByID(texto)
	Loop % (t := wb.Document.getElementsByTagName(tag)).length
		if(parcial){
			if(InStr(t[A_Index-1].getAttribute(busq) , texto) > 0)
				Return t[A_Index-1]
		}else if(t[A_Index-1].getAttribute(atributo) = texto)
					Return t[A_Index-1]
	Return ""
}

;--------------------------------------------------------------------
; Busca una lengueta en el IEXPLORE.EXE por defecto
; usando el path
;--------------------------------------------------------------------
DEVN_IE_BuscarPagURL(texto, prg:="IEXPLORE.EXE")
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