#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TBICONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ROGR002 �Autor  �Microsiga           � Data �  17/03/2023   ���
�������������������������������������������������������������������������͹��
���Desc.     � ADIMAX INDUSTRIA E COMERCIO DE ALIMENTOS LTDA              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*/{Protheus.doc} ROGR002
description Analitico de Comissoes por representante
@type function
@version  
@author Jo�o
@since 3/21/2023
@return variant, return_description
/*/
User Function ROGR002()

	Local oReport
	Private cPerg := "ROGR002"

//Pergunte(oReport:uParam, .F.)

//If TRepInUse()

	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef()
	oReport:PrintDialog()
//Endif


Return

//---------------------------------------------------------
// Defini�ao da estrutura do relatorio
//---------------------------------------------------------
Static Function ReportDef()

	Local oReport
	Local oComissao
	Local oResumo
	Local cTitle   := " ADIMAX INDUSTRIA E COMERCIO DE ALIMENTOS LTDA  -  RELATORIO DE VENDAS NO PERIODO "
    

	oReport:= TReport():New("ROGR002",cTitle,cPerg,{|oReport| PrintReport(oReport,oComissao,oResumo)},"Este relat�rio apresenta: Adimax Industria e comercio de Alimentos LTDA  -  Relatorio de Vendas no Periodo")
	//oReport:SetPortrait() 		// Orienta��o retrato
	oReport:SetLandscape()			// Orienta��o paisagem
	//oReport:HideHeader()  		// Nao imprime cabe�alho padr�o do Protheus
	//oReport:HideFooter()			// Nao imprime rodap� padr�o do Protheus
	oReport:HideParamPage()			// Inibe impress�o da pagina de parametros
	oReport:SetUseGC(.F.) 			// Habilita o bot�o <Gestao Corporativa> do relat�rio
	//oReport:DisableOrientation()  // Desabilita a sele��o da orienta��o (retrato/paisagem)
	//oReport:cFontBody := "Arial"
	//oReport:nFontBody := 8

	// Pergunte(oReport:GetParam(),.F.)

	oComissao := TRSection():New(oReport,"Comissao",{"SE3"},{"Comissao"})

	TRCell():New(oComissao,"E3_EMISSAO"		, "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_NUM"  		, "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_CODCLI"		, "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_BASE"		, "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E4_COND"        , "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_FORMA"	    , "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"F2_COND"	    , "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_COMIS"		, "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)
	TRCell():New(oComissao,"E3_PORC"	    , "", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,/*bConteudo*/)


Return(oReport)

//---------------------------------------------------------
// Faz impress�o do relat�rio
//---------------------------------------------------------
Static Function PrintReport(oReport,oComissao,oResumo)

	Local cQry 	 := ""
    Local cMedia := 0

	DbSelectArea("SE3")
	SE3->(DbSetOrder(1))

//���������������������������������������������������������������������Ŀ
//�    Monta Query com os dados que serao impressos no relatorio        �
//�����������������������������������������������������������������������

	cQry := " SELECT         "
	cQry += " 	E4_COND,  "
	cQry += " 	E4_FORMA,  "
	cQry += " 	E3_EMISSAO,  "
	cQry += " 	E3_NUM, "
	cQry += " 	E3_CODCLI,   "
	cQry += " 	E3_BASE  ,   "
	cQry += " 	E3_COMIS ,   "
	cQry += " 	F2_COND  ,   "
	cQry += "   E3_PORC  ,   "
	cQry += " 	E3.R_E_C_N_O_ RECNOSE3     "
	cQry += " FROM " + RETSQLNAME("SE3") + " E3"
	cQry += " LEFT JOIN " + RETSQLNAME("SF2") + " SF2 "
	cQry += " 		ON  F2_FILIAL   = E3_FILIAL "
	cQry += " 		AND F2_DOC      = E3_NUM "
	cQry += " 		AND F2_SERIE    = E3_SERIE "
	cQry += " 		AND SF2.D_E_L_E_T_<> '*'"
	cQry += " LEFT JOIN " + RETSQLNAME("SC5") + " SC5 "
    cQry += " 		ON  C5_FILIAL   = E3_FILIAL "
    cQry += " 		AND C5_NUM      = E3_PEDIDO "
	cQry += " 		AND SC5.D_E_L_E_T_<> '*'"
	cQry += " LEFT JOIN " + RETSQLNAME("SE4") + " SE4 "
    cQry += " 		ON  E4_FILIAL   = C5_FILIAL "
    cQry += " 		AND E4_CODIGO   = C5_CONDPAG "
	cQry += " 		AND SE4.D_E_L_E_T_<> '*'"
	cQry += " LEFT JOIN " + RETSQLNAME("SCV") + " SCV "
    cQry += " 		ON   CV_FILIAL   = E3_FILIAL "
    cQry += " 		AND  CV_PEDIDO   = E3_PEDIDO "
	cQry += " 		AND  SCV.D_E_L_E_T_<> '*'"
	cQry += " WHERE E3.D_E_L_E_T_<> '*'"
	cQry += " 	AND E3_FILIAL = '" + 	xFilial("SE3") + "'"
   
	cQry := ChangeQuery(cQry)

	If Select("QU06")>0

		QU06->(DbCloseArea())
		
	Endif


	TcQuery cQry New Alias "QU06" // Cria uma nova area com o resultado do query


//Imprime dados do relatorio
	While QU06->(!EOF())

        cMedia := ((QU06->E3_COMIS / QU06->E3_BASE) * 100)

		SE3->(DbGoTo(QU06->RECNOSE3))

		oComissao:Cell("E3_EMISSAO"		):SetValue(QU06->E3_EMISSAO)
		oComissao:Cell("E3_NUM"	        ):SetValue(QU06->E3_NUM    )
		oComissao:Cell("E3_CODCLI"	    ):SetValue(QU06->E3_CODCLI )
		oComissao:Cell("E3_BASE"	    ):SetValue(QU06->E3_BASE   )
		oComissao:Cell("E3_COMIS"	    ):SetValue(QU06->E3_COMIS  )
	    oComissao:Cell("E4_COND"	    ):SetValue(QU06->E4_COND   )
        oComissao:Cell("F2_COND"	    ):SetValue(QU06->F2_COND   )

		QU06->E3_PORC := cMedia

		oComissao:Cell("E3_PORC"	    ):SetValue(QU06->E3_PORC )

        
   
    
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
	QU06->(DbCloseArea())
Return


