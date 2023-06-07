#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} ROGR008
Funcao de Gestão de comissoes Protheus
@type User function
@version  
@author Joao Goncalves       
@since 11/04/2023
@return Nao retorna nada
/*/

User Function ROGR008()

	Local oReport 		:= nil
	Local bOk           := { || .T. }
	Local aFilter       := {}
	Local aFilRet       := {}

	Private Filial       := ""                                                                                                   
	Private cMesRef      := ""                                                                                                  
	Private cTipEvent    := ""                                                                                                   
	Private cCodRep      := ""                                                                                                  

	AAdd( aFilter, { 1, "Filial" 	            , Space(TamSx3("E3_FILIAL     ")[1]),PesqPict("SE3","E3_FILIAL "),"","","",6,.T.}) 
	AAdd( aFilter, { 1, "Mes de Referencia"     , Space(TamSx3("E3_EMISSAO    ")[1]),PesqPict("SE3","E3_EMISSAO"),"","","",8,.T.})
	AAdd( aFilter, { 1, "Tipo de Evento " 	    , Space(TamSx3("E3_TIPO       ")[1]),PesqPict("SE3","E3_TIPO  " ),"","","",6,.T.})
	AAdd( aFilter, { 1, "Representante" 	    , Space(TamSx3("E3_VEND       ")[1]),PesqPict("SE3","E3_VEND  " ),"","","",6,.T.})

	If !ParamBox( aFilter, "Filtro", @aFilRet, bOk, , , , , , , .F., .F. )

		Return

	else

		Filial       := aFilRet[1]
		cMesRef      := aFilRet[2]
		cTipEvent    := aFilRet[3]
		cCodRep      := aFilRet[4]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface de impressao                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oReport := ReportDef()

		oReport:PrintDialog()

	endif

Return

//---------------------------------------------------------
// Definiçao da estrutura do relatorio
//--------------------------------------------------------- 

Static Function ReportDef()

	Local oEvento
	Local oReport
	Local oComissao

	Local cTitle   := "GESTAO COMISSOES PROTHEUS"

	oReport:= TReport():New("ROGR008",cTitle,"ROGR008",{|oReport| PrintReport(oReport,oComissao,oEvento)},"Este relatório apresenta: Gestao comissoes Protheus")

	oReport:SetPortrait()			// Orientação retrato
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC(.F.) 			// Habilita o botão <Gestao Corporativa> do relatório

	oComissao:= TRSection():New(oReport, "Comissoes", {"SE3","SA3"},NIL , .F., .T.)

	oEvento:= TRSection():New(oReport, "Eventos", {"SE3","SA3","ZA3"},NIL , .F., .T.)

	TRCell():New(oComissao,"E3_EMISSAO"           , "", "Mes de Referencia"   , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_VEND"              , "", "Cod. Representante"  , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"A3_NOME"              , "", /*Titulo*/            , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_COMIS"             , "", "Valor"               , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)

	TRCell():New(oEvento,"E3_XEVENTO"            , "", "Evento"               , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oEvento,"ZA3_DESCRI"            , "", "Descricao"            , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)

	oBreak  := TRBreak():New(oComissao,oEvento:Cell("E3_XEVENTO"), "",.F.)

	TRFunction():New(oComissao:Cell("E3_COMIS")   ,"","SUM",oBreak,,"@E 99,999,999.99",,.F.,.T.)

	oComissao:SetTotalInLine(.F.)

	oComissao:SetTotalText(" ")

	oComissao:SetPageBreak(.F.)

Return(oReport)

//---------------------------------------------------------------
//   Monta Query com os dados que serao impressos no relatorio
//-------------------------------------------------------------

Static Function PrintReport(oReport,oComissao,oEvento)

	Local cQry 	         := ""
	Local cAlias         := GetNextAlias()
	Local cEvento        := ""

	cQry     := "  SELECT           "
	cQry     += "    E3_XEVENTO,    "
	cQry     += "    ZA3_DESCRI,    "
	cQry     += "    E3_EMISSAO,    "
	cQry     += "    E3_TIPO,       "
	cQry     += "    E3_VEND,       "
	cQry     += "    E3_COMIS,      "
	cQry     += "    A3_COD,        "
	cQry     += "    A3_NOME        "

	cQry     += "   FROM " + RETSQLNAME("SE3") + " SE3 "

	cQry     += "   INNER JOIN  " + RETSQLNAME("SA3") + " SA3 "
	cQry     += "        ON   A3_FILIAL        =  '" + xFILIAL("SA3") + "'" 
	cQry     += "        AND  A3_COD           =    E3_VEND   "
	cQry     += "        AND  SA3.D_E_L_E_T_   =  ' '         "

	cQry     += "   INNER JOIN  " + RETSQLNAME("ZA3") + " ZA3 "
	cQry     += "        ON   ZA3_FILIAL        =  '" + xFILIAL("ZA3") + "'"
	cQry     += "        AND  ZA3_CODIGO        =    E3_XEVENTO  "
	cQry     += "        AND  ZA3.D_E_L_E_T_    =  ' '           "


	cQry     += "        WHERE SE3.D_E_L_E_T_   =  ' ' "

	if Select(cAlias) > 1

		(cAlias)->(DbCloseArea())

	endif

	TcQuery cQry New Alias (cAlias)

	oReport:SetMeter((cAlias)->(LastRec()))

	oComissao:Init()

	oComissao:SetLinesBefore(1)

	oComissao:lPrintHeader := .T.

	while (cAlias)->(!EOF())

		if (cAlias)->E3_XEVENTO != cEvento

			oEvento:Cell("E3_XEVENTO" ):SetValue((cAlias)->E3_XEVENTO   )

			oEvento:Cell("ZA3_DESCRI" ):SetValue((cAlias)->ZA3_DESCRI   )

			cEvento := (cAlias)->E3_XEVENTO

			oEvento:Init()

			// oRepresentante:lPrintHeader := .T.

			oEvento:Printline()

			oEvento:Finish()

		endif

		If oReport:Cancel()
			Exit
		EndIf

		IncProc("Gerando relatório de comissão...")

		oComissao:Cell("E3_EMISSAO"     ):SetValue(STOD((cAlias)->E3_EMISSAO))
		oComissao:Cell("E3_VEND"        ):SetValue((cAlias)->E3_VEND      )
		oComissao:Cell("A3_NOME"        ):SetValue((cAlias)->A3_NOME      )
		oComissao:Cell("E3_COMIS"       ):SetValue((cAlias)->E3_COMIS     )

		// oEvento:Cell("ZA3_DESCRI"     ):SetValue((cAlias)->ZA3_DESCRI   )


		oReport:IncMeter()

		oComissao:Printline()

		(cAlias)->(DbSkip())

	endDo

	oReport:ThinLine()

	oComissao:Finish()

Return
