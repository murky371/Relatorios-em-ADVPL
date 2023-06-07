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

/*/{Protheus.doc} ROGR004
Funcao para relatorio de comissao e Adiantamento Analitico
@type User function
@version  
@author Joao
@since 02/03/2023
@return variant, return_description
/*/

User Function ROGR004(cFilePrint,cDirDoc )

	Default cFilePrint      := ""

	Local cQry              := " "
	Local cPerg             := "ROGR004"
	Local cAlias            := GetNextAlias()

	Local cArquivo          := "ROGR004" + dToS(dDataBase) + "_" + StrTran(Time(), ':', '-')

	Private cVendedor       :=  ""
	Private cPeriodo        :=  ""
	Private oPrint	 	    := Nil

	Private nLin	        := 05

	//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FIN"


	if Pergunte(cPerg,.T.,"")

		cQry :=   " SELECT "
		cQry +=   " Top 10 "
		cQry +=	    "  SA3.R_E_C_N_O_  RECNOSA3,  "
		cQry +=	    "  ZA1.R_E_C_N_O_  RECNOZA1  "
		cQry +=	 " FROM " + RetSqlTab("SA3") "
		cQry +=  " INNER JOIN " + RetSqlTab("ZA1") 
		cQry +=  "   ON   ZA1_FILIAL = '" + xFilial("ZA1") + "' "
		cQry +=  "   AND  ZA1_CODREP       =  A3_COD "
		cQry +=  "   AND  ZA1.D_E_L_E_T_   = ' ' "
		cQry +=  "  WHERE  SA3.D_E_L_E_T_ = ' ' "
		cQry +=  "   AND   A3_MSBLQL = '2' "

		If !Empty(MV_PAR01)

			cQry += "   AND ZA1_FILIAL  = '"  + MV_PAR01 + "' "

		endif

		   cQry += "   AND ZA1_MESREF  = '"  + MV_PAR02 + "' "

		If !Empty(MV_PAR03)

			cQry += "   AND ZA1_CODREP  = '"  + MV_PAR03 + "' "

		EndIf

		if MV_PAR04 != 3

			cQry += "   AND ZA1_FECHD  = '" + iif(MV_PAR04 == 2,"T","F") + "' "

		endif

		if Select(cAlias) > 1

			(cAlias)->(DbCloseArea())

		endif

		TcQuery cQry New Alias (cAlias)

		cPeriodo   := MV_PAR02

		oPrint := FWMSPrinter():New(cArquivo, IMP_SPOOL, .F., "", .F., , @oPrint, "", , , , .F.)

		oPrint:SetResolution(72)
		oPrint:SetPortrait()
		oPrint:SetPaperSize(DMPAPER_A4)
		oPrint:SetMargin(80, 60, 60, 60)

		oPrint:StartPage()

		while (cAlias)->(!EOF())

			SA3->(DbGoTo( (cAlias)->RECNOSA3))
			ZA1->(DbGoTo( (cAlias)->RECNOZA1))

			If nLin > 650

				oPrint:StartPage()

				nLin := 05 

			EndIf

			// SA2->(DbSetOrder(3))

			SA2->(DbSeek(xFILIAL("SA2")+ SA3->A3_FORNECE + SA3->A3_LOJA ))

			FWMsgRun(,{ |oSay| Processa(oSay,cFilePrint,cDirDoc)} ,"Aguarde..."  , "Processando relatorio..." )

			(cAlias)->(DbSkip())

		endDo

		oPrint:Preview()
	EndIf

Return

/*/{Protheus.doc} Processa
Funcao para processar impressao do recibo
@type Static function
@version  
@author Joao
@since 02/03/2023
@return variant, return_description
/*/
Static Function Processa(oSay, cFilePrint,cDirDoc)

	//Variaveis locais
	Local nLargura	  := 0

	//Fontes
	Local cNomeFont 	    := "Arial"                //9
	Private oFont9N  	    := TFont():New(cNomeFont, 9,  -10, .T., .F., 5, .T., 5, .T., .F. )
	Private oFont10N  	    := TFont():New(cNomeFont, 10, -11, .T., .T., 5, .T., 5, .T., .F. )
	Private oFont9  	    := TFont():New(cNomeFont, 09, -10, .F., .F., 5, .T., 5, .T., .F. )
	Private oFont14N  	    := TFont():New(cNomeFont, 15, -19, .T., .T., 5, .T., 5, .T., .F. )
	Private oFont11N  	    := TFont():New(cNomeFont, 11, -12, .T., .T., 5, .T., 5, .T., .F. )

	//Variaveis privadas
	Private nTotalCredito   :=  0
	Private nTotalDebito    :=  0
	Private nTotalComissao  :=  0
	Private nValorReais     :=  0
	Private cEmpresa        := "  ADIMAX INDUSTRIA E COMERCIO DE ALIMENTOS LTDA "
	Private EmpCom          := "- ADIMAX MG "


	//Imprime o cabeçalho
	Cabecalho(oPrint,@nLin,@nLargura)

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

	nLin += 20
	//30
	// oPrint:SayAlign(nLin ,0, "RECIBO" , oFont14N,nLargura,50,,V_CENTER,H_CENTER)

	//oPrint:Box(Linha ,Coluna ,altura, comprimento)
	nLin += 25
	oPrint:Box(nLin ,0 ,nLin+30,(nLargura ))  //Linha do nome
	oPrint:SayAlign(nLin +8 ,10, cPeriodo,oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +8 ,60, AllTrim(SA3->A3_NOME),oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +8 ,350,"Bco: "  + AllTrim(SA3->A3_BCO1),oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +8 ,400,"Ag: "  + AllTrim(SA2->A2_AGENCIA),oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +8 ,455,"CC: "  + AllTrim(SA2->A2_CONTA),oFont11N,nLargura,30,,V_LEFT,H_CENTER)


	//total de comissao
	nLin += 30
	oPrint:Box(nLin ,0   ,nLin+25, (nLargura  -100  )) 	//Total de comissao //140
	oPrint:Box(nLin ,nLargura -100   ,nLin+25, (nLargura  )) //140

	nTotalComissao := TotalCom()

	oPrint:SayAlign(nLin +6 ,10, "Total de Comissão: " , oFont11N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +6 ,-78, iif(nTotalComissao > 0 , "( + )","( - )"), oFont10N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +6 ,-10, Alltrim(Transform(nTotalComissao, PesqPict("ZA4","ZA4_VALOR"))), oFont11N,nLargura,30,,V_RIGHT,H_CENTER)

	nLin += 25
	oPrint:Box(nLin ,0                    ,nLin+25, (nLargura - 100  )) //140
	oPrint:Box(nLin , nLargura  - 100     ,nLin+25, (nLargura        )) //140

	oPrint:SayAlign(nLin +6 ,10, "Descontos Diversos: " , oFont11N,nLargura,30,,V_LEFT,H_CENTER)

	nLin += 25
	oPrint:Box(nLin ,-0                    ,nLin+25,(nLargura - 435   ))//435
	oPrint:Box(nLin ,(nLargura  - 435  )  ,nLin+25, (nLargura  -350   ))//435 //335
	oPrint:Box(nLin ,(nLargura  - 350  )  ,nLin+25, (nLargura  -100   ))//350 //140
	oPrint:Box(nLin , nLargura  - 100     ,nLin+25, (nLargura         ))//140
	//oPrint:Box(nLin ,nLargura -405   ,nLin+25, (nLargura  ))

	oPrint:SayAlign(nLin +3 ,10, "Data do Pagamento " , oFont10N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +3 ,110, "Tipo de Evento"    , oFont10N,nLargura,30,,V_LEFT,H_CENTER) //120
	oPrint:SayAlign(nLin +3 ,205, "Observações"       , oFont10N,nLargura,30,,V_LEFT,H_CENTER)
	oPrint:SayAlign(nLin +3 ,450, "Valor em Reais "   , oFont11N,nLargura,30,,V_LEFT,H_CENTER)

	nLin += 25

	EventImp(nLargura, oPrint, nValorReais, @nLin )

	oPrint:Box(nLin ,0 ,nLin+100,(nLargura ))
	oPrint:SayAlign(nLin +20 ,-115, "(+) Total de comissão: " , oFont10N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +20 ,-10, Transform(nTotalComissao, PesqPict("ZA4","ZA4_VALOR")), oFont11N,nLargura,30,,V_RIGHT,H_CENTER)

	oPrint:SayAlign(nLin +35 ,-115, "(+) Total Crédito: " , oFont10N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +34 ,-10, Transform(nTotalCredito, PesqPict("ZA4","ZA4_VALOR")), oFont10N,nLargura,30,,V_RIGHT,H_CENTER)

	oPrint:SayAlign(nLin +47 ,-115, "(-) Total Débito: " , oFont10N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +46 ,-10, Transform(nTotalDebito, PesqPict("ZA4","ZA4_VALOR")), oFont10N,nLargura,30,,V_RIGHT,H_CENTER)

	oPrint:Box(nLin +65,((nLargura /2)+ 50) ,nLin +65,(nLargura -05))
	oPrint:SayAlign(nLin +67 ,-115, "  = Saldo a Pagar: " , oFont11N,nLargura,30,,V_RIGHT,H_CENTER)
	oPrint:SayAlign(nLin +67 ,-10, Transform((nTotalComissao + nTotalCredito) - nTotalDebito, PesqPict("ZA4","ZA4_VALOR")), oFont11N,nLargura,30,,V_RIGHT,H_CENTER)



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

	cQry := "  SELECT "
	cQry += "	ZA4_DTPAG,"
	cQry += "	ZA4_TIPO,"
	cQry += "	ZA4_OBSERV,"
	cQry += "	ZA4_VALOR, "
	cQry += "	ZA3_DESCRI "
	cQry += " FROM " + RetSqlTab("ZA4")
	cQry += " INNER JOIN " + RetSqlTab("ZA3")
	cQry += " ON ZA3_FILIAL = '" + xFILIAL("ZA3") + "'"
	cQry += " 	AND ZA3_CODIGO = ZA4_EVENTO"
	cQry += " 	AND ZA3.D_E_L_E_T_ = ' ' "
	cQry += " WHERE ZA4.D_E_L_E_T_ = ' ' "
	cQry += "   AND ZA4_FILIAL = '" + xFILIAL("ZA4") + "'"
	cQry += "	AND ZA4_MESREF = '" + cPeriodo  + "'"
	cQry += "	AND ZA4_REPRES = '" + cVendedor + "'"

	if Select(cAlias) > 1

		(cAlias)->(DbCloseArea())

	endif

	TcQuery cQry New Alias (cAlias)

	while (cAlias)->(!EOF())

		oPrint:Box(nLin ,0                    ,nLin+25, (nLargura - 435  ))//435
		oPrint:Box(nLin ,(nLargura  - 435  )  ,nLin+25, (nLargura  -350  ))//435            //335
		oPrint:Box(nLin ,(nLargura  - 350  )  ,nLin+25, (nLargura  -100  ))//335   //140
		oPrint:Box(nLin , nLargura  - 100     ,nLin+25, (nLargura        ))//140

		oPrint:SayAlign(nLin +6 ,-78, iif((cAlias)->ZA4_TIPO == "C" , "( + )","( - )"), oFont9,nLargura,30,,V_RIGHT,H_CENTER)

		oPrint:SayAlign(nLin +05 ,-460,   DToC(SToD((cAlias)->ZA4_DTPAG))     , oFont9,nLargura				,30,,V_RIGHT,H_CENTER)
		oPrint:SayAlign(nLin +05 ,  80,   Alltrim((cAlias)->ZA3_DESCRI)   	  , oFont9,nLargura * 0.243,30	   ,,V_CENTER,H_CENTER )
		oPrint:SayAlign(nLin +05 , 195,   AllTrim((cAlias)->ZA4_OBSERV  )     , oFont9,nLargura				,30,,V_LEFT,H_CENTER)
		oPrint:SayAlign(nLin +05 , -10,   Transform((cAlias)->ZA4_VALOR,PesqPict("ZA4","ZA4_VALOR")) , oFont9,nLargura,30,,V_RIGHT,H_CENTER)

		If (cAlias)->ZA4_TIPO == "C"

			nTotalCredito += (cAlias)->ZA4_VALOR

		else

			nTotalDebito += (cAlias)->ZA4_VALOR

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


	cQry := "  SELECT "
	cQry += "   E3_VEND,"
	cQry += "   SUM(E3_COMIS) COMISSAO"
	cQry += "   FROM " + RetSqlTab("SE3")
	cQry += " WHERE SE3.D_E_L_E_T_ = ' '"
	cQry += "   AND  E3_FILIAL = '" + xFILIAL("SE3") + "'""
	cQry += "   AND  E3_VEND = '" + cVendedor + "'"
	cQry += "   AND SUBSTRING(E3_EMISSAO,5,2) + SUBSTRING(E3_EMISSAO,1,4) = '" + cPeriodo + "'"
	cQry += " GROUP BY E3_VEND  "

	if Select(cAlias) > 1

		(cAlias)->(DbCloseArea())

	endif

	TcQuery cQry New Alias (cAlias)

Return (cAlias)->COMISSAO
