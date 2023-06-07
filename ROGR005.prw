#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "REPORT.CH"

/*/{Protheus.doc} ROGR004
Funcao de comissao e Adiantamento Sintetico
@type User function
@version  
@author Leandro Rodrigues
@since 02/03/2023
@return variant, return_description
/*/

User Function ROGR005()

	Local oReport 		:= nil
	Local bOk           := { || .T. }
	Local aFilter       := {}
	Local aFilRet       := {}

	Private cFilPer     := ""
	Private cPeriodo    := ""
	Private cCodRepDe   := ""
	Private cCodRepAte  := ""

	AAdd( aFilter, { 1, "Filial" 	            , Space(TamSx3("ZA1_FILIAL")[1]),PesqPict("ZA1","ZA1_FILIAL"),"","","",6,.T.})
	AAdd( aFilter, { 1, "Periodo" 	            , Space(TamSx3("ZA1_MESREF")[1]),PesqPict("ZA1","ZA1_MESREF"),"","","",6,.T.})
	AAdd( aFilter, { 1, "Representante de " 	, Space(TamSx3("ZA1_CODREP")[1]),PesqPict("ZA1","ZA1_CODREP"),"","","",6,.T.})
	AAdd( aFilter, { 1, "Representante Ate" 	, Space(TamSx3("ZA1_CODREP")[1]),PesqPict("ZA1","ZA1_CODREP"),"","","",6,.T.})

	If !ParamBox( aFilter, "Filtro", @aFilRet, bOk, , , , , , , .F., .F. )

		Return

	else

		cFilPer     := aFilRet[1]
		cPeriodo    := aFilRet[2]
		cCodRepDe   := aFilRet[3]
		cCodRepAte  := aFilRet[4]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Interface de impressao                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport := ReportDef()
		oReport:PrintDialog()

	endif

Return

Static Function ReportDef()

	Local oReport
	Local oComissao
	Local cTitle   :="COMISSÕES E ADIANTAMENTOS SINTÉTICOS"

	oReport:= TReport():New("ROGR005",cTitle,"ROGR005",{|oReport| PrintReport(oReport,oComissao)},"Este relatório apresenta o comissões e adiantamentos sintéticos")

	oReport:SetPortrait()			// Orientação retrato
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC(.F.) 			// Habilita o botão <Gestao Corporativa> do relatório

	oComissao:= TRSection():New(oReport, "Comissões", {"SE3","ZA1","ZA3"},NIL , .F., .T.)

	TRCell():New(oComissao,"ZA1_MESREF"      , "", /*Titulo*/       , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"A3_NOME"         , "", /*Titulo*/       , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"A2_NOME"         , "", /*Titulo*/       , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"A2_BANCO"        , "", /*Titulo*/       , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"A2_AGENCIA"      , "", /*Titulo*/       , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"A2_NUMCON"       , "", /*Titulo*/       , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_COMIS"        , "", /*Titulo*/       ,  /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"TOTALCRE"        , "", "Total Crédito"  , PesqPict("ZA1","ZA1_VALOR"), TamSx3("ZA1_VALOR")[1], /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"TOTALDEB"        , "", "Total Débito "  , PesqPict("ZA1","ZA1_VALOR"), TamSx3("ZA1_VALOR")[1], /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"ZA1_VALOR"       , "", "Contas Pagar"   , PesqPict("ZA1","ZA1_VALOR"), /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"ZA1_PGERA"       , "", "Ger"            , /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)

	oComissao:Cell("E3_COMIS" ):SetHeaderAlign("RIGHT")
	oComissao:Cell("TOTALCRE" ):SetHeaderAlign("RIGHT")
	oComissao:Cell("TOTALDEB" ):SetHeaderAlign("RIGHT")
	oComissao:Cell("ZA1_VALOR"):SetHeaderAlign("RIGHT")


	oBreak  := TRBreak():New(oComissao,oComissao:Cell("ZA1_MESREF"), "",.F.)

	TRFunction():New(oComissao:Cell("E3_COMIS") ,"","SUM",oBreak,,"@E 99,999,999.99",,.F.,.T.)
	TRFunction():New(oComissao:Cell("TOTALCRE") ,"","SUM",oBreak,,"@E 99,999,999.99",,.F.,.T.)
	TRFunction():New(oComissao:Cell("TOTALDEB") ,"","SUM",oBreak,,"@E 99,999,999.99",,.F.,.T.)
	TRFunction():New(oComissao:Cell("ZA1_VALOR"),"","SUM",oBreak,,"@E 99,999,999.99",,.F.,.T.)

	oComissao:SetTotalInLine(.F.)
	oComissao:SetTotalText(" ")
	oComissao:SetPageBreak(.F.)

Return(oReport)

//---------------------------------------------------------
// Faz impressão do relatório
//---------------------------------------------------------
Static Function PrintReport(oReport,oComissao)

	Local cQry 	    := ""
	Local cAlias    := GetNextAlias()

	cQry := " SELECT"
	cQry += " 	    ZA1_FILIAL,"
	cQry += " 	    ZA1_MESREF,"
	cQry += " 	    A3_NOME,"
	cQry += " 	    A2_NOME,"
	cQry += " 	    A2_BANCO,"
	cQry += " 	    A2_AGENCIA,"
	cQry += " 	    A2_NUMCON,"
	cQry += " 	    SUM(E3_COMIS) COMISSAO,"
	cQry += " 	    CREDITO.VALOR CREDITO,"
	cQry += " 	    DEBITO.VALOR DEBITO,"
	cQry += " 	    (SUM(E3_COMIS) + CREDITO.VALOR ) - 	CREDITO.VALOR SALDO,"
	cQry += " 	    ZA1_PGERA"
	cQry += " FROM " + RETSQLTAB("ZA1")
	cQry += " INNER JOIN " + RETSQLTAB("SA3")
	cQry += " ON  A3_FILIAL = '"+  XFILIAL("SA3") + "'"
	cQry += " 	    AND A3_COD = ZA1_CODREP"
	cQry += " 	    AND SA3.D_E_L_E_T_ = ' '"
	cQry += " LEFT JOIN "+ RETSQLTAB("SA2")
	cQry += " ON A2_FILIAL = '"+  XFILIAL("SA2") + "'"
	cQry += " 	    AND A2_COD  = A3_FORNECE"
	cQry += " 	    AND A2_LOJA = A3_LOJA"
	cQry += " 	    AND SA2.D_E_L_E_T_ = ' '"
	cQry += " LEFT JOIN "+ RETSQLTAB("SE3")
	cQry += " ON E3_FILIAL = '"+  XFILIAL("SE3") + "'"
	cQry += " 	    AND E3_VEND = ZA1_CODREP"
	cQry += " 	    AND SUBSTRING(E3_EMISSAO,5,2)+SUBSTRING(E3_EMISSAO,1,4) = ZA1_MESREF"
	cQry += "       AND SE3.E3_XEVENTO =' '"
	cQry += "       AND SE3.D_E_L_E_T_ = ' '"
	cQry += " LEFT JOIN ("
	cQry += " 		SELECT"
	cQry += "           E3_FILIAL,"
	cQry += " 		    E3_VEND,"
	cQry += " 		    E3_EMISSAO,"
	cQry += " 		    SUM(E3_COMIS) VALOR"
	cQry += " 		    FROM "+ RETSQLNAME("SE3")  + " CD"
	cQry += "        INNER JOIN "+ RETSQLTAB("ZA3")
	cQry += "        ON ZA3_FILIAL  = '"+  XFILIAL("ZA3") + "'"
	cQry += "                AND ZA3_CODIGO = CD.E3_XEVENTO"
	cQry += "                AND ZA3.D_E_L_E_T_ = ''"
	cQry += " 		WHERE CD.D_E_L_E_T_ = ''"
	cQry += " 		    AND ZA3_OPER = 'C'"
	cQry += "  GROUP BY E3_FILIAL,E3_VEND,E3_EMISSAO"
	cQry += ") CREDITO"
	cQry += " ON CREDITO.E3_FILIAL = SE3.E3_FILIAL"
	cQry += "       AND CREDITO.E3_VEND = SE3.E3_VEND"
	cQry += "       AND  SUBSTRING(CREDITO.E3_EMISSAO,5,2)+SUBSTRING(CREDITO.E3_EMISSAO,1,4) = ZA1.ZA1_MESREF"
	cQry += " LEFT JOIN ("
	cQry += "       SELECT"
	cQry += "             E3_FILIAL,"
	cQry += "             E3_VEND,"
	cQry += "             E3_EMISSAO,"
	cQry += "             SUM(E3_COMIS) VALOR"
	cQry += "       FROM " + RETSQLNAME("SE3")  + " DB"
	cQry += "       INNER JOIN "+ RETSQLTAB("ZA3")
	cQry += "             ON ZA3_FILIAL  = '"+  XFILIAL("ZA3") + "'"
	cQry += "             AND ZA3_CODIGO = DB.E3_XEVENTO"
	cQry += "             AND ZA3.D_E_L_E_T_ = ''"
	cQry += "       		WHERE DB.D_E_L_E_T_ = ''"
	cQry += "       		AND ZA3_OPER = 'D'"
	cQry += "       GROUP BY E3_FILIAL,E3_VEND,E3_EMISSAO"
	cQry += "	) DEBITO"
	cQry += " ON DEBITO.E3_FILIAL = SE3.E3_FILIAL"
	cQry += "       AND DEBITO.E3_VEND = SE3.E3_VEND"
	cQry += "       AND SUBSTRING(DEBITO.E3_EMISSAO,5,2)+SUBSTRING(DEBITO.E3_EMISSAO,1,4) = ZA1.ZA1_MESREF"
	cQry += "  WHERE ZA1.D_E_L_E_T_ = ' '"
    cQry += "  AND ZA1_FILIAL = '" +  cFilPer  + "'"
    cQry += "  AND ZA1_MESREF = '" +  cPeriodo + "'"
    cQry += "  AND ZA1_CODREP BETWEEN '" + cCodRepDe + "' AND '"+ cCodRepAte + "'"
	
	cQry += "  GROUP BY ZA1_FILIAL,ZA1_MESREF,A3_NOME,A2_NOME,A2_BANCO,A2_AGENCIA,A2_NUMCON,ZA1_PGERA,CREDITO.VALOR,DEBITO.VALOR "

	if Select(cAlias) > 1

		(cAlias)->(DbCloseArea())

	endif

	TcQuery cQry New Alias (cAlias)

	oReport:SetMeter((cAlias)->(LastRec()))

	oComissao:Init()
	oComissao:SetLinesBefore(1)
	oComissao:lPrintHeader := .T.

	while (cAlias)->(!EOF())

		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

		IncProc("Gerando relatório de comissão...")

		oComissao:Cell("ZA1_MESREF" ):SetValue((cAlias)->ZA1_MESREF   )
		oComissao:Cell("A3_NOME"    ):SetValue((cAlias)->A3_NOME      )
		oComissao:Cell("A2_NOME"    ):SetValue((cAlias)->A2_NOME      )
		oComissao:Cell("A2_BANCO"   ):SetValue((cAlias)->A2_BANCO     )
		oComissao:Cell("A2_AGENCIA" ):SetValue((cAlias)->A2_AGENCIA   )
		oComissao:Cell("A2_NUMCON"  ):SetValue((cAlias)->A2_NUMCON    )
		oComissao:Cell("E3_COMIS"   ):SetValue((cAlias)->COMISSAO     )
		oComissao:Cell("TOTALCRE"   ):SetValue((cAlias)->CREDITO      )
		oComissao:Cell("TOTALDEB"   ):SetValue((cAlias)->DEBITO       )
		oComissao:Cell("ZA1_VALOR"  ):SetValue((cAlias)->SALDO        )
		oComissao:Cell("ZA1_PGERA"  ):SetValue((cAlias)->ZA1_PGERA    )

		oComissao:Printline()

		(cAlias)->(DbSkip())

	endDo

	oReport:ThinLine()
	oComissao:Finish()

Return
