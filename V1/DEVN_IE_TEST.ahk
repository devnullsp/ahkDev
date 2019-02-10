#include %A_ScriptDir%\DEVN_IE.ahk
;------TEST ---------------------------------------------------------
test()
test(){
	wb := DEVN_IE()
	wb.visible:=true
	DEVN_Navegar(wb,"https://www.autohotkey.com/")
	pagNum:=DEVN_esperaPag(wb,[["href","a","/search"]])
	DEVN_Click(wb,DEVN_WBNodo(wb,"href","a","/search"))
	DEVN_WBNodo(wb,"id","","gsc-i-id1").value := "devnullsp"
	DEVN_Click(wb,DEVN_WBNodo(wb,"class","button","gsc-search-button gsc-search-button-v2"))
	msgbox pulse para ejecutar test2
	wb2:=DEVN_IE_BuscarPagURL("autohotkey.com")
	DEVN_Navegar(wb2,"https://www.ibm.com/")

}
