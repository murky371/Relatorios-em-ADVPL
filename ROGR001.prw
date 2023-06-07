//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Include "TBICONN.CH"

#Define V_LEFT    0
#Define V_RIGHT   1
#Define V_CENTER  2

#Define H_CENTER  0
#Define H_TOP 	  1
#Define H_BOTTOM  20

/*/{Protheus.doc} ROGR001
Funcao para relatorio de Recibo de comissao
@type User function
@version  
@author Joao
@since 02/03/2023
@return variant, return_description
/*/

User Function ROGR001(cFilePrint,cDirDoc)

	Default cFilePrint := ""

	FWMsgRun(,{ |oSay| Processa(oSay,cFilePrint,cDirDoc)} ,"Aguarde..."  , "Processando relatorio..." )

Return

/*/{Protheus.doc} Processa
Funcao para processar impressao do recibo
@type Static function
@version  
@author Joao
@since 02/03/2023
@return variant, return_description
/*/
Static Function Processa(oSay,cFilePrint,cDirDoc)

	//Variaveis locais
	Local cArquivo    := "ROGR001" + dToS(dDataBase) + "_" + StrTran(Time(), ':', '-')
	Local nLin		  := 05
	Local nLargura	  := 0


	//Fontes
	Local cNomeFont 	    := "Arial"                //9
	Private oFont9N  	    := TFont():New(cNomeFont, 9,  -10, .T., .F., 5, .T., 5, .T., .F. )
	Private oFont10N  	    := TFont():New(cNomeFont, 10, -11, .T., .T., 5, .T., 5, .T., .F. )
	Private oFont9  	    := TFont():New(cNomeFont, 09, -10, .F., .F., 5, .T., 5, .T., .F. )
	Private oFont14N  	    := TFont():New(cNomeFont, 15, -19, .T., .T., 5, .T., 5, .T., .F. )
	Private oFont11N  	    := TFont():New(cNomeFont, 11, -12, .T., .T., 5, .T., 5, .T., .F. )

	//Variaveis privadas
	Private cVendedor       :=  ZA1->ZA1_CODREP
	Private cPeriodo        :=  ZA1->ZA1_MESREF
	Private nTotalCredito   :=  0
	Private nTotalDebito    :=  0
	Private nTotalComissao  :=  0
	Private nValorReais     :=  0
	Private cEmpresa        := "  ADIMAX INDUSTRIA E COMERCIO DE ALIMENTOS LTDA "
	Private EmpCom          := "- ADIMAX MG "

	Private oPrint	 	    := Nil

	if Empty(cFilePrint)

		//Criando o objeto do FMSPrinter
		oPrint := FWMSPrinter():New(cArquivo, IMP_SPOOL, .F., "", .F., , @oPrint, "", , , , .F.)

	else

		lAdjustToLegacy := .F.
		lDisableSetup   := .T.

		//oPrint:=FwMSPrinter():New(cFilePrint,6,lAdjustToLegacy,,lDisableSetup,,,,.T.,.F.)
		oPrint := FWMSPrinter():New(cFilePrint, IMP_PDF, .F., cDirDoc, .T., , @oPrint, "", , , , .F.)
		oPrint:SetViewPDF(.F.)
		oPrint:cPathPDF := cDirDoc
		oPrint:lServer  := .T.

	endif

	oPrint:SetResolution(72)
	oPrint:SetPortrait()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(80, 60, 60, 60)

	//Imprime o cabeçalho
	Cabecalho(oPrint,@nLin,@nLargura)

	if Empty(cFilePrint)
		oPrint:Preview()
	else
		oPrint:Print()
	endif

Return

/*/{Protheus.doc} Cabecalho
Funcao para imprimir cabecalho do recibo
@type function
@version  
@author Joao
@since 02/03/2023
@param 
@param nLin, numeric, param_description
@param nLargura, numeric, param_description
@return variant, return_description
/*/
Static Function Cabecalho(oPrint,nLin,nLargura)

	Local cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())

	nLargura:= oPrint:nHorzSize() - 57
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")

	oPrint:StartPage()

	SA3->(DbSeek(xFILIAL("SA3")+cVendedor))

	nLin += 40
	//30
	oPrint:SayAlign(nLin ,0, "RECIBO" , oFont14N,nLargura,50,,V_CENTER,H_CENTER)

	//oPrint:Box(Linha ,Coluna ,altura, comprimento)
	nLin += 25
	oPrint:Box(nLin ,0 ,nLin+30,(nLargura ))  //Linha do nome

	oPrint:SayAlign(nLin +8 ,10, cPeriodo							,oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +8 ,60, AllTrim(SA3->A3_NOME)				,oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +8 ,350,"Bco: " + AllTrim(SA3->A3_BCO1)	,oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +8 ,400,"Ag: "  + AllTrim(SA2->A2_AGENCIA)	,oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +8 ,455,"CC: "  + AllTrim(SA2->A2_CONTA)	,oFont11N,nLargura,30,,V_LEFT,H_CENTER)


	//total de comissao
	nLin += 30
	oPrint:Box(nLin ,0   ,nLin+25, (nLargura  -100  )) 	//Total de comissao //140
	oPrint:Box(nLin ,nLargura -100   ,nLin+25, (nLargura  )) //140

	nTotalComissao := TotalCom()

	oPrint:SayAlign(nLin +6 ,10, "Total de Comissão: " , oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +6 ,-78, iif(nTotalComissao > 0 , "( + )","( - )"), oFont10N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +6 ,-10, Alltrim(Transform(nTotalComissao, PesqPict("SE3","E3_COMIS"))), oFont11N,nLargura,30,,V_RIGHT,H_CENTER)

	nLin += 25
	oPrint:Box(nLin ,0                    ,nLin+25, (nLargura - 100  )) //140
	oPrint:Box(nLin , nLargura  - 100     ,nLin+25, (nLargura        )) //140

	oPrint:SayAlign(nLin +6 ,10, "Descontos Diversos: " , oFont11N,nLargura,30,,V_LEFT,H_CENTER)

	nLin += 25
	oPrint:Box(nLin ,-0                    ,nLin+25, (nLargura -450   ))//450
	oPrint:Box(nLin ,(nLargura   -50    )  ,nLin+25, (nLargura -330   ))//50 //330
	oPrint:Box(nLin ,(nLargura   - 0    )  ,nLin+25, (nLargura        ))//0
	oPrint:Box(nLin , nLargura   -100      ,nLin+25, (nLargura        ))//100
	//oPrint:Box(nLin ,nLargura -405   ,nLin+25, (nLargura  ))

	oPrint:SayAlign(nLin +3 ,10, "Data Pagamento "    , oFont10N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +3 ,105, "Tipo Evento"       , oFont10N,nLargura,30,,V_LEFT,H_CENTER) //120
	oPrint:SayAlign(nLin +3 ,210, "Observações"       , oFont10N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +3 ,450, "Valor em Reais "   , oFont11N,nLargura,30,,V_LEFT,H_CENTER)

	nLin += 25

	EventImp(nLargura, oPrint, nValorReais, @nLin )

	oPrint:Box(nLin ,0 ,nLin+100,(nLargura ))
	oPrint:SayAlign(nLin +20 ,-115, "(+) Total de comissão: " , oFont10N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +20 ,-10, Transform(nTotalComissao, PesqPict("SE3","E3_COMIS")), oFont11N,nLargura,30,,V_RIGHT,H_CENTER)

	oPrint:SayAlign(nLin +35 ,-115, "(+) Total Crédito: " , oFont10N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +34 ,-10, Transform(nTotalCredito, PesqPict("SE3","E3_COMIS")), oFont10N,nLargura,30,,V_RIGHT,H_CENTER)

	oPrint:SayAlign(nLin +47 ,-115, "(-) Total Débito: " , oFont10N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +46 ,-10, Transform(nTotalDebito, PesqPict("SE3","E3_COMIS")), oFont10N,nLargura,30,,V_RIGHT,H_CENTER)

	oPrint:Box(nLin +65,((nLargura /2)+ 50) ,nLin +65,(nLargura -05))
	oPrint:SayAlign(nLin +67 ,-115, "  = Saldo a Pagar: " , oFont11N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +67 ,-10,  Transform((nTotalComissao + nTotalCredito) - nTotalDebito, PesqPict("SE3","E3_COMIS")), oFont11N,nLargura,30,,V_RIGHT,H_CENTER)

	nLin += 150      //0           //250
	oPrint:Box(nLin ,0 ,nLin,(nLargura /2)-35)

	//250          //500
	oPrint:Box(nLin ,(nLargura /2) + 25 ,nLin,(nLargura ))

	//Nome: Direita
	oPrint:SayAlign(nLin +08 ,100, AllTrim(SA3->A3_NOME), oFont10N,nLargura +100,30,,V_CENTER,H_CENTER)

	//Nome: Esquerda
	oPrint:SayAlign(nLin +08 ,01, AllTrim(cEmpresa), oFont10N,nLargura -300,50,,V_CENTER,H_CENTER)

	nLin += 15

	//Nome: esquerda(Complemento)
	oPrint:SayAlign(nLin +08 ,01, AllTrim(EmpCom), oFont10N,nLargura -300,50,,V_CENTER,H_CENTER)




	nLin += 95

Return

/*/{Protheus.doc} EvenImp
Funcao para buscar imprimir lancamento de eventos
@type Static function
@version  
@author João
@since 3/7/2023
@return Não retorna nada
/*/
Static Function EventImp(nLargura, oPrint, cValorReais, nLin)

	Local cQry   := ""
	Local cAlias := GetNextAlias()

	cQry := "SELECT"
	cQry += "	ZA3_OPER,"
	cQry += "	E3_XOBSERV,"
	cQry += "	E3_EMISSAO, "
	cQry += "	E3_COMIS, "
	cQry += "	ZA3_DESCRI "
	cQry += " FROM " + RetSqlTab("SE3")
	cQry += " INNER JOIN " + RetSqlTab("ZA3")
	cQry += " ON ZA3_FILIAL = '" + xFILIAL("ZA3") + "'"
	cQry += " 	AND ZA3_CODIGO = E3_XEVENTO"
	cQry += " 	AND ZA3.D_E_L_E_T_ = ' '"
	cQry += "WHERE SE3.D_E_L_E_T_ = ' ' "
	cQry += "   AND E3_XEVENTO <> ' '"
	cQry += "   AND E3_FILIAL = '" + xFILIAL("SE3") + "'"
	cQry += "	AND SUBSTRING(SE3.E3_EMISSAO,5,2)+SUBSTRING(SE3.E3_EMISSAO,1,4) = '" + cPeriodo  + "'"
	cQry += "	AND E3_VEND = '" + cVendedor + "'"

	if Select(cAlias) > 1
		(cAlias)->(DbCloseArea())
	endif

	TcQuery cQry New Alias (cAlias)

	while (cAlias)->(!EOF())

		oPrint:Box(nLin ,0                    ,nLin+25, (nLargura - 450  ))//450
		oPrint:Box(nLin ,(nLargura  - 450  )  ,nLin+25, (nLargura  -330  ))//450  //330
		oPrint:Box(nLin ,(nLargura  - 330  )  ,nLin+25, (nLargura  -100  ))//330  //100
		oPrint:Box(nLin , nLargura  - 100     ,nLin+25, (nLargura        ))//100

		oPrint:SayAlign(nLin +6 ,-78, iif((cAlias)->ZA3_OPER == "C" , "( + )","( - )"), oFont9,nLargura,30,,V_RIGHT,H_CENTER)

		oPrint:SayAlign(nLin +05 ,-480,   DToC(SToD((cAlias)->E3_EMISSAO))     						, oFont9,nLargura				,30,,V_RIGHT,H_CENTER)
		oPrint:SayAlign(nLin +05 ,  75,   Alltrim((cAlias)->ZA3_DESCRI)   	  						, oFont9,nLargura * 0.243       ,30,,V_CENTER,H_CENTER )
		oPrint:SayAlign(nLin +05 , 210,   AllTrim((cAlias)->E3_XOBSERV  )     						, oFont9,nLargura				,30,,V_LEFT,H_CENTER)
		oPrint:SayAlign(nLin +05 , -10,   Transform((cAlias)->E3_COMIS,PesqPict("SE3","E3_COMIS"))  , oFont9,nLargura,30,,V_RIGHT,H_CENTER)

		If (cAlias)->ZA3_OPER == "C"

			nTotalCredito += (cAlias)->E3_COMIS

		else

			nTotalDebito += (cAlias)->E3_COMIS

		EndIf

		nLin +=25

		(cAlias)->(DbSkip())
	endDo
return

/*/{Protheus.doc} TotalCom
	Funcao buscar total de comissao
	@type  Static Function
	@author user
	@since 10/03/2023
	@version version
	@param 
	@return 
	(examples)
	@see (links_or_references)
/*/
Static Function TotalCom()

	Local cQry   := ""
	Local cAlias := GetNextAlias()

	cQry := " SELECT "
	cQry += "   E3_VEND,"
	cQry += "   SUM(E3_COMIS) COMISSAO"
	cQry += "   FROM " + RetSqlTab("SE3")
	cQry += " WHERE SE3.D_E_L_E_T_ = ' '"
	cQry += " AND  E3_FILIAL = '" + xFILIAL("SE3") + "'""
	cQry += " AND  E3_VEND = '" + cVendedor + "'"
	cQry += " AND SUBSTRING(E3_EMISSAO,5,2) + SUBSTRING(E3_EMISSAO,1,4) = '" + cPeriodo + "'"
	cQry += " GROUP BY E3_VEND  "

	if Select(cAlias) > 1
		(cAlias)->(DbCloseArea())
	endif

	TcQuery cQry New Alias (cAlias)


Return (cAlias)->COMISSAO
