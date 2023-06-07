#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} ROGR006
Funcao Analitica de Comissoes por representante
@type User function
@version  
@author Leandro Rodrigues
@since 02/03/2023
@return variant, return_description
/*/

User Function ROGR006()

	Local oReport 		:= nil

	Local bOk           := { || .T. }
	Local aFilter       := {}
	Local aFilRet       := {}

	Private cFilialPer  := ""
	Private dDataIni    := ""
	Private dDataFim    := ""
	Private cCodRep     := ""
	Private cCFOPVend   := ""
	Private cCFOPTroca  := ""
	Private cCFOPBon    := ""

	AAdd( aFilter, { 1, "Filial" 	                  , Space(TamSx3("F2_FILIAL" )[1]),PesqPict("SF2","F2_FILIAL "   ),"","","",6,.T.})
	AAdd( aFilter, { 1, "Data Inicial" 	              , cTod(Space(TamSx3("E3_EMISSAO")[1])),PesqPict("SE3","E3_EMISSAO"),"","","",6,.T.})
	AAdd( aFilter, { 1, "Data Final " 	              , cTod(Space(TamSx3("E3_EMISSAO")[1])),PesqPict("SE3","E3_EMISSAO"),"","","",6,.T.})
	AAdd( aFilter, { 1, "Representante"               , Space(TamSx3("E3_VEND"   )[1]),PesqPict("SE3","E3_VEND"      ),"","","",6,.F.})
	AAdd( aFilter, { 1, "Tipo de CFOP de Vendas"      , Space(TamSx3("D2_CF"     )[1]),PesqPict("SD2","D2_CF"        ),"","","",6,.F.})
	AAdd( aFilter, { 1, "Tipo de CFOP de Troca"       , Space(TamSx3("D2_CF"     )[1]),PesqPict("SD2","D2_CF"        ),"","","",6,.F.})
	AAdd( aFilter, { 1, "Tipo de CFOP de Bonificacao" , Space(TamSx3("D2_CF"     )[1]),PesqPict("SD2","D2_CF"        ),"","","",6,.F.})

	If !ParamBox( aFilter, "Filtro", @aFilRet, bOk, , , , , , , .F., .F. )

		Return

	else

		cFilialPer        := aFilRet[1]
		dDataIni          := aFilRet[2]
		dDataFim          := aFilRet[3]
		cCodRep           := aFilRet[4]
		cCFOPVend         := aFilRet[5]
		cCFOPTroca        := aFilRet[6]
		cCFOPBon          := aFilRet[7]



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿5		//³Interface de impressao                                                  �6
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿5		//³Interface de impressao                                                  �7
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport := ReportDef()
		oReport:PrintDialog()

	endif

Return

//---------------------------------------------------------
// Defini�ao da estrutura do relatorio
//---------------------------------------------------------

Static Function ReportDef()

	Local oRepresentante
	Local oReport
	Local oComissao

	Local cTitle   := "ADIMAX INDUSTRIA E COMERCIO DE ALIMENTOS LTDA  -  RELATORIO DE VENDAS NO PERIODO"


	oReport:= TReport():New("ROGR006",cTitle,"ROGR006",{|oReport| PrintReport(oReport,oComissao, oRepresentante)},"Este relat�rio apresenta: Adimax Industria e comercio de Alimentos LTDA  -  Relatorio de Vendas no Periodo")

	oReport:SetPortrait()			// Orientacao retrato
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC(.F.) 			// Habilita o botao <Gestao Corporativa> do relatorio

	oComissao := TRSection():New(oReport, "Comissoes", {"SF2","SD2","SA1","SCV","SE3"/*,"SE4","SA3","SA1"*/},NIL , .F., .T.)

	oRepresentante := TRSection():New(oReport, "Comissoes", {"SF2","SD2","SA1","SCV","SE3"/*,"SE4","SA3","SA1"*/},NIL , .F., .T.)


	TRCell():New(oComissao,"F2_EMISSAO"         , "", /*Titulo*/              , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"F2_DOC"             , "", /*Titulo*/              , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"F2_CLIENTE"         , "", /*Titulo*/              , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_BASE"            , "", "Valor"                 , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"CV_FORMAPG"         , "", /*Titulo*/              , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E4_FORMA"           , "", "Prazo de pagto."       , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"D2_PEDIDO"          , "", "Documento"             , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"A1_NOME"            , "", /*Titulo*/              , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"F2_PLIQUI"          , "","Peso Liquido"           , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_COMIS"           , "", "Comissao"              , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_PORC"            , "", "Media %"               , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)

	TRCell():New(oRepresentante,"E3_VEND"       , "", "Representante"         , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oRepresentante,"A3_NOME"       , "", /*Titulo*/              , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)


	oBreak  := TRBreak():New(oComissao,oRepresentante:Cell("E3_VEND"), "",.F.)

	TRFunction():New(oComissao:Cell("E3_BASE"  )  ,,"SUM",oBreak,"Base Comis","@E 99,999,999.99",,.F.,.T.       )
	TRFunction():New(oComissao:Cell("E3_COMIS" )  ,,"SUM",oBreak,"Valor Comis","@E 99,999,999.99",,.F.,.T.      )
	TRFunction():New(oComissao:Cell("E3_PORC"  )  ,,"AVERAGE",oBreak,"Porcentagem","@E 99,999,999.99",,.F.,.T.  )
	// TRFunction():New(oComissao:Cell("E3_COMIS")  ,"","SUM",oBreak,,"@E 99,999,999.99",,.F.,.T.  )

	oComissao:SetTotalInLine(.F.)
	oComissao:SetTotalText(" ")
	oComissao:SetPageBreak(.F.)

	oRepresentante:SetTotalInLine(.F.)

Return(oReport)

//---------------------------------------------------------------
//   Monta Query com os dados que serao impressos no relatorio
//-------------------------------------------------------------

Static Function PrintReport(oReport,oComissao,oRepresentante)

	Local cRepresentante  := ""
	Local cQry 	          := ""
	Local cAlias          := GetNextAlias()
	Local cMedia          := 0

	cQry  := "  SELECT "
	cQry  += "    F2_EMISSAO, "
	cQry  += "    F2_DOC, "
	cqry  += "    CV_FORMAPG, "
	cQry  += "    F2_CLIENTE, "
	cQry  += "    D2_PEDIDO, "
	cqry  += "    E4_FORMA, "
	cQry  += "    A1_NOME, "
	cQry  += "    F2_PLIQUI, "
	cQry  += "    E3_COMIS, "
	cQry  += "    E3_BASE, "
	cQry  += "    E3_PORC, "
	cQry  += "    E3_EMISSAO, "
	cQry  += "    E3_VEND, "
	cQry  += "    A3_NOME "
	cQry  += "  FROM " + RETSQLTAB("SF2")

	cQry += "  INNER JOIN " + RETSQLNAME("SE3") + " SE3 "
	cQry += " 		ON  F2_FILIAL   = E3_FILIAL "
	cQry += " 		AND F2_DOC      = E3_NUM "
	cQry += " 		AND F2_SERIE    = E3_SERIE "
	cQry += " 		AND SE3.D_E_L_E_T_ <> '*'"

	cQry  += "  INNER JOIN " + RETSQLTAB("SD2")                 // TABELAS: SF2, SD2, SF2, SA3, SE4, SCV, SA1
	cQry  += "      ON  D2_FILIAL       =  F2_FILIAL "
	cQry  += "      AND D2_SERIE        =  F2_SERIE "
	cQry  += "      AND D2_DOC          =  F2_DOC "
	cQry  += "      AND SD2.D_E_L_E_T_  =  ' '"

	cQry  += "  INNER JOIN " + RETSQLTAB("SA3")
	cQry  += "      ON  A3_FILIAL  = '" + xFILIAL("SA3") + "'"
	cQry  += "      AND A3_COD          =  F2_VEND1  "
	cQry  += "      AND SA3.D_E_L_E_T_  =  ' ' "

	cQry  += "  INNER JOIN " + RETSQLTAB("SE4")
	cQry  += "      ON  E4_FILIAL = '" + xFILIAL("SE4") + "'"
	cQry  += "      AND E4_COND         =  F2_COND "
	cQry  += "      AND SE4.D_E_L_E_T_  =  ' ' "

	cQry  += "  INNER JOIN " + RETSQLTAB("SCV")
	cQry  += "     ON  CV_FILIAL        =  D2_FILIAL "
	cQry  += "     AND CV_PEDIDO        =  D2_PEDIDO "
	cQry  += "     AND SCV.D_E_L_E_T_   = ' ' "

	cQry  += "  INNER JOIN " + RETSQLTAB("SA1")
	cQry  += "      ON    A1_FILIAL  = '" + xFILIAL("SA1") + "'"
	cQry  += "      AND   A1_COD          =  F2_CLIENTE "
	cQry  += "      AND   A1_LOJA         =  F2_LOJA "
	cQry  += "      AND   SA1.D_E_L_E_T_  = ' ' "
	cQry  += "  WHERE SF2.D_E_L_E_T_      = ' ' "
	cQry  += "	AND F2_FILIAL  = '"  + cFilialPer + "'"
	cQry  += "	AND E3_EMISSAO BETWEEN '" + dToS(dDataIni)   + "' AND'"  + dToS(dDataFim)   + "'"

	If  !Empty(cCodRep)

		cQry  += "	AND E3_VEND    = '"  + cCodRep    + "'"
		//cQry  += "  AND D2_CF IN ('"+ cCFOPVend +"','"+ cCFOPTroca +"','"+cCFOPBon +"')"
	EndIf

	If !Empty(cCFOPVend)
		cQry  += "  AND  D2_CF     = '"  + cCFOPVend   + "'"
	EndIf

	If !Empty(cCFOPTroca)
		cQry  += "  AND D2_CF      = '"  + cCFOPTroca  + "'"
	EndIf

	If !Empty(cCFOPBon)
		cQry  += "  AND D2_CF      = '"  + cCFOPBon    + "'"
	EndIf

	cQry   +=  "  ORDER BY  E3_VEND  "

	if Select(cAlias) > 1

		(cAlias)->(DbCloseArea())

	endif

	TcQuery cQry New Alias (cAlias)  // Cria uma nova area com o resultado do query

	oReport:SetMeter((cAlias)->(LastRec()))

	oComissao:Init()

	oComissao:SetLinesBefore(1)

	oComissao:lPrintHeader := .T.

	//Imprime dados do relatorio
	while (cAlias)->(!EOF())

		cMedia := (((cAlias)->E3_COMIS / (cAlias)->E3_BASE) * 100)

		if (cAlias)->E3_VEND != cRepresentante

			oRepresentante:Cell("E3_VEND" ):SetValue((cAlias)->E3_VEND   )
			oRepresentante:Cell("A3_NOME" ):SetValue((cAlias)->A3_NOME   )

			cRepresentante := (cAlias)->E3_VEND

			oRepresentante:Init()

			// oRepresentante:lPrintHeader := .T.

			oRepresentante:Printline()

			oRepresentante:Finish()

		endif

		oComissao:Cell("F2_EMISSAO" ):SetValue((cAlias)->F2_EMISSAO     )
		oComissao:Cell("F2_DOC"     ):SetValue((cAlias)->F2_DOC         )
		oComissao:Cell("F2_CLIENTE" ):SetValue((cAlias)->F2_CLIENTE     )
		oComissao:Cell("E3_BASE"    ):SetValue((cAlias)->E3_BASE        )
		oComissao:Cell("D2_PEDIDO"  ):SetValue((cAlias)->D2_PEDIDO      )
		oComissao:Cell("CV_FORMAPG" ):SetValue((cAlias)->CV_FORMAPG     )
		oComissao:Cell("E4_FORMA"   ):SetValue((cAlias)->E4_FORMA       )
		oComissao:Cell("A1_NOME"    ):SetValue((cAlias)->A1_NOME        )
		oComissao:Cell("F2_PLIQUI"  ):SetValue((cAlias)->F2_PLIQUI      )
		oComissao:Cell("E3_COMIS"   ):SetValue((cAlias)->E3_COMIS       )

		oComissao:Cell("E3_PORC"	    ):SetValue(cMedia)


		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		oComissao:Printline()

		(cAlias)->(DbSkip())

	endDo

	oReport:ThinLine()

	oComissao:Finish()

Return
