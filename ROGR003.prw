#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TBICONN.CH"
#Include "Totvs.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณROGR003 บAutor  ณMicrosiga           บ Data ณ  21/03/2023   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ SINTETICO DE COMISSOES            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*/{Protheus.doc} ROGR002
description Sintetico de Comissoes
@type function
@version  
@author Joใo
@since 3/21/2023
@return 
/*/
User Function ROGR003()

	Local oReport
	Private cPerg := "ROGR003"

//Pergunte(oReport:uParam, .F.)

//If TRepInUse()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณInterface de impressao                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oReport := ReportDef()
	oReport:PrintDialog()
//Endif


Return

//---------------------------------------------------------
// Defini็ao da estrutura do relatorio
//---------------------------------------------------------
Static Function ReportDef()

	Local oReport
	Local oComissao
	Local oResumo  := " RESUMO DE VENDAS"
	Local cTitle   := "  "


	oReport:= TReport():New("ROGR003",cTitle,cPerg,{|oReport| PrintReport(oReport,oComissao,oResumo)},"   ")
	//oReport:SetPortrait() 		// Orienta็ใo retrato
	oReport:SetLandscape()			// Orienta็ใo paisagem
	//oReport:HideHeader()  		// Nao imprime cabe็alho padrใo do Protheus
	//oReport:HideFooter()			// Nao imprime rodap้ padrใo do Protheus
	oReport:HideParamPage()			// Inibe impressใo da pagina de parametros
	oReport:SetUseGC(.F.) 			// Habilita o botใo <Gestao Corporativa> do relat๓rio
	//oReport:DisableOrientation()  // Desabilita a sele็ใo da orienta็ใo (retrato/paisagem)
	//oReport:cFontBody := "Arial"
	//oReport:nFontBody := 8

	// Pergunte(oReport:GetParam(),.F.)

	oComissao := TRSection():New(oReport,"Comissao",{"SA3"},{"Comissao"})

	TRCell():New(oComissao,"A3_COD"  		, "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)  //Codigo do vendedor
	TRCell():New(oComissao,"A3_NOME"		, "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)  //Nome do vendedor
	TRCell():New(oComissao,"C5_CLIENTE"		, "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)  //Codigo do cliente
	TRCell():New(oComissao,"C5_NUM"		    , "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)  //Numero do pedido
	TRCell():New(oComissao,"C5_PBRUTO"      , "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)  //Peso Bruto
	TRCell():New(oComissao,"E3_COMIS"	    , "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)  //Valor da comissao
    TRCell():New(oComissao,"F2_VALBRUT"	    , "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)  //Valor da comissao

Return(oReport)

//---------------------------------------------------------
// Faz impressใo do relat๓rio
//---------------------------------------------------------
Static Function PrintReport(oReport,oComissao,oResumo)

	Local cQry 	  := ""



	DbSelectArea("SA3")
	SE3->(DbSetOrder(1))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ    Monta Query com os dados que serao impressos no relatorio        ณ   //SF2
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	cQry := " SELECT         "
	cQry += " 	A3_NOME,  "
	cQry += " 	A3_COD, "
	cQry += " 	C5_NUM, "
	cQry += "   CLIENTES.QTD_CLIENTES, "
	cQry += "   PEDIDOS.QTD_PEDIDOS, "
	cQry += "   VALORBRUTO.VALORBRUTO, "
	cQry += " SUM(E3_COMIS) AS COMISSAO,  "
	cQry += " 	C5_CLIENTE,   "
	cQry += " SUM(C5_PBRUTO) AS PESOBRUTO   "
	cQry += " FROM " + RETSQLNAME("SA3") + " A3 "
	cQry += " INNER JOIN " + RETSQLNAME("SC5") + " SC5 "
	cQry += " 		ON  C5_FILIAL     = A3_FILIAL "
	cQry += " 		AND C5_VEND1      = A3_COD  "
	cQry += " 		AND SC5.D_E_L_E_T_<> '*'"
	cQry += " INNER JOIN " + RETSQLNAME("SE3") + " SE3 "
	cQry += " 		ON  E3_FILIAL     = A3_FILIAL "
	cQry += " 		AND E3_VEND       = A3_COD  "
	cQry += " 		AND SE3.D_E_L_E_T_<> '*'"

	cQry += " INNER JOIN "
	cQry += " ( " 
	cQry += "  SELECT "
	cQry += "    COUNT(C5_CLIENTE) QTD_CLIENTES, "
	cQry += "    C5_VEND1 "
	cQry += "  FROM " + RETSQLNAME("SC5") + " C5 "
	cQry += "  WHERE C5.D_E_L_E_T_ = '  ' "
	cQry += "  GROUP BY C5_VEND1 "
	cQry += " ) "
	cQry += " AS CLIENTES "

	cQry += " ON CLIENTES.C5_VEND1 = A3_COD "

	cQry += " INNER JOIN "
	cQry += " ( "
	cQry += "   SELECT "
	cQry += "     COUNT(C5_NUM) QTD_PEDIDOS, "
	cQry += "     C5_VEND1 "
	cQry += "   FROM " +  RETSQLNAME("SC5") + " C5 "
	cQry += "   WHERE C5.D_E_L_E_T_ = '  ' "
	cQry += "   GROUP BY C5_VEND1 "
	cQry += " ) "
	cQry += " AS PEDIDOS "

	cQry += " ON PEDIDOS.C5_VEND1 = A3_COD "

	cQry += " INNER JOIN "
	cQry += " ( "
	cQry += " SELECT "
	cQry += "    SUM(F2_VALBRUT) VALORBRUTO, "
	cQry += "    F2_VEND1 "
	cQry += " FROM " +  RETSQLNAME("SF2") + " F2 "
	cQry += " WHERE F2.D_E_L_E_T_ = '  ' "
	cQry += " GROUP BY F2_VEND1 "
	cQry += " ) "
	cQry += "    AS VALORBRUTO "

	cQry += " ON VALORBRUTO.F2_VEND1 = A3_COD "

	cQry += " WHERE A3.D_E_L_E_T_<> '*'"
	cQry += " 	AND A3_FILIAL = '" + 	xFilial("SA3") + "'"
	cQry += " GROUP BY A3_NOME, A3_COD, C5_NUM, C5_CLIENTE, CLIENTES.QTD_CLIENTES, PEDIDOS.QTD_PEDIDOS, VALORBRUTO.VALORBRUTO   "



	cQry := ChangeQuery(cQry)

	If Select("QU06")>0
		QU06->(DbCloseArea())
	Endif


	TcQuery cQry New Alias "QU06" // Cria uma nova area com o resultado do query


//Imprime dados do relatorio
	While QU06->(!EOF())

		// SE3->(DbGoTo(QU06->RECNOSE3))

		oComissao:Cell("A3_COD"	        ):SetValue(QU06->A3_COD     )
		oComissao:Cell("A3_NOME"		):SetValue(QU06->A3_NOME    )
		oComissao:Cell("C5_CLIENTE"	    ):SetValue(QU06->C5_CLIENTE )
		oComissao:Cell("C5_PBRUTO"	    ):SetValue(QU06->C5_PBRUTO  )
		oComissao:Cell("E3_COMIS"	    ):SetValue(QU06->E3_COMIS   )
		oComissao:Cell("C5_NUM"	        ):SetValue(QU06->C5_NUM     )
		oComissao:Cell("F2_VALBRUT"	    ):SetValue(QU06->C5_NUM     )




		// oComissao:SetTotalInLine(.F.)

		// oCount  := TRFunction():New(oComissao:Cell("B1_COD") ,,"COUNT",/*oBreak*/,,,,.F.,.F.,.F.)
		// nCont ++

		// oCount:SetEndSection(.T.)

		oComissao:Init()
		oComissao:PrintLine()

		//Se cancelar abandona o laco
		If oReport:Cancel()
			Exit
		EndIf

		QU06->(DbSkip())
	EndDo

//Altero descricao do totalizador
	// oComissao:SetTotalText("Quantidade Itens")

	// oComissao:Finish()

Return


