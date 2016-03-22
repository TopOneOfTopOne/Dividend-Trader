#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <main_functions.au3>
#include <GuiComboBox.au3>
#include <GuiTab.au3>


#Region ### START Koda GUI section ### Form=c:\users\p\desktop\dividend trade logger\tradergui.kxf
$traderGUI = GUICreate("Dividend Trader by noobling", 364, 415, -1, -1)
GUISetIcon("C:\Users\P\AppData\Roaming\uTorrent\uTorrent.exe", -1)
$tab = GUICtrlCreateTab(8, 0, 345, 401)
$TabSheet1 = GUICtrlCreateTabItem("Snapshot")
$snapshotGUI = GUICtrlCreateGroup("Snapshot", 50, 33, 257, 305, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
$currentMoneyInput = GUICtrlCreateInput("", 66, 81, 129, 21)
$currentMoneyLabel = GUICtrlCreateLabel("Available Funds ($)", 66, 57, 94, 17)
$currentMoneyBtnChange = GUICtrlCreateButton("Change", 202, 81, 75, 25)
$totalPendingDividendsInput = GUICtrlCreateInput("", 66, 153, 129, 21)
$totalPendingDivLabel = GUICtrlCreateLabel("Total Pending Dividends", 66, 129, 120, 17)
$pendingDividendsBtn = GUICtrlCreateButton("View Dividends", 202, 153, 83, 25)
$totalFrankingCreditsInput = GUICtrlCreateInput("", 66, 225, 129, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
$totalFrankingCreditsLabel = GUICtrlCreateLabel("Total Franking Credits", 66, 201, 107, 17)
$dividendHistoryBtn = GUICtrlCreateButton("Dividend History", 178, 273, 115, 25)
$holdingsLabel = GUICtrlCreateLabel("Holdings", 214, 200, 45, 17)
$holdingsCombo = GUICtrlCreateCombo("", 198, 224, 89, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$transactionHistoryBtn = GUICtrlCreateButton("Transaction History", 62, 272, 115, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$TabSheet2 = GUICtrlCreateTabItem("Buy")
$codeInput = GUICtrlCreateInput("", 32, 64, 89, 21)
$buyPriceInput = GUICtrlCreateInput("", 224, 64, 89, 21)
$numSharesInput = GUICtrlCreateInput("", 32, 144, 89, 21)
$useFullCapitalBtn = GUICtrlCreateButton("Use Full Capital", 128, 144, 83, 25)
$dividendInput = GUICtrlCreateInput("", 224, 144, 89, 21)
$divDateInput = GUICtrlCreateInput("", 32, 224, 89, 21)
$frankingInput = GUICtrlCreateInput("", 224, 224, 89, 21)
$buyBtn = GUICtrlCreateButton("Buy", 141, 272, 75, 25)
$codeLabel = GUICtrlCreateLabel("Code", 32, 40, 29, 17)
$buyPriceLabel = GUICtrlCreateLabel("Buy Price ($)", 224, 40, 64, 17)
$numSharesLabel = GUICtrlCreateLabel("Number of Shares", 32, 120, 89, 17)
$dividendLabel = GUICtrlCreateLabel("Dividend (CPS)", 224, 120, 76, 17)
$divDateLabel = GUICtrlCreateLabel("Dividend Pay Date", 32, 200, 93, 17)
$frankingLabel = GUICtrlCreateLabel("Franking (%)", 224, 200, 62, 17)

$TabSheet3 = GUICtrlCreateTabItem("Sell")
$sellPriceInput = GUICtrlCreateInput("", 116, 178, 129, 21)
$sellPriceLabel = GUICtrlCreateLabel("Sell Price", 154, 144, 48, 17)
$holdingsLabelSell = GUICtrlCreateLabel("Holdings", 156, 53, 45, 17)
$sellBtn = GUICtrlCreateButton("Sell", 141, 224, 75, 25)
$holdingsComboSell = GUICtrlCreateCombo("", 113, 80, 129, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$TabSheet4 = GUICtrlCreateTabItem("About")
$aboutBox = GUICtrlCreateEdit("", 32, 33, 281, 249)
GUICtrlSetTip($currentMoneyLabel,'How much money you have to spend on shit')
GUICtrlSetTip($currentMoneyBtnChange, 'Change your money to amount in currently Available Funds box')
GUICtrlSetTip($totalPendingDivLabel, 'Sum of dividends you should receive in the future')
GUICtrlSetTip($pendingDividendsBtn, 'View your dividends')
GUICtrlSetTip($totalFrankingCreditsLabel, 'This is the amount of franking credits you should receive on tax date - 30th of June')
GUICtrlSetTip($holdingsLabel, 'Stocks you hold right now')
GUICtrlSetTip($codeLabel, 'Stock code e.g. CBA')
GUICtrlSetTip($buyPriceLabel, 'The price one stock')
GUICtrlSetTip($numSharesLabel, 'How many shares you are going to buy')
GUICtrlSetTip($useFullCapitalBtn, 'Calculate number of shares when you spend all your money, "Buy Price" must be filled in.')
GUICtrlSetTip($divDateLabel, 'Date when you will receive the dividend')
GUICtrlSetTip($frankingLabel, 'What percentage of dividend is franked')
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


_init()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Save()
			Exit
		Case $pendingDividendsBtn
			_ArrayDisplay($pendingDivPayments,"Pending Dividends")
		Case $currentMoneyBtnChange
			$value = GUICtrlRead($currentMoneyInput)
			$moneyBefore = $currentMoney
			$currentMoney = $value
			MsgBox(0,'Done','Funds changed from: $'&$moneyBefore&' To: $'&$currentMoney)
		Case $dividendHistoryBtn
			_ArrayDisplay($divPaymentHistory, "Dividend Payment History")
		Case $useFullCapitalBtn
			$numShares = Round(($currentMoney - $TRANSACTION_COST)/GUICtrlRead($buyPriceInput),0)
			GUICtrlSetData($numSharesInput, $numShares)
		Case $buyBtn

			Local $code = GUICtrlRead($codeInput)
			Local $divDate = GUICtrlRead($divDateInput)
			Local $dividend = GUICtrlRead($dividendInput)
			Local $numStock = GUICtrlRead($numSharesInput)
			Local $franking = GUICtrlRead($frankingInput)
			Local $buyPrice = GUICtrlRead($buyPriceInput)
			$id = MsgBox(1,'Confirmation', 'Code: '&$code&@CRLF&'Dividend Pay Date: '&$divDate&@CRLF&'Dividend Per share(cents): '&$dividend&@CRLF&'Number of shares purchased: '&$numStock&@CRLF&'Buy Price: $'&$buyPrice&@CRLF&'Franking: '&$franking&'%'&@CRLF)
			If $id = $IDOK Then
				_buyStock($code, $divDate, $numStock, $buyPrice, $franking, $dividend)
				_refresh()
			EndIf
		Case $sellBtn
			Local $data = GUICtrlRead($holdingsComboSell)
			Local $aData = StringSplit($data,' ')
			Local $code = $aData[1]
			Local $sellPrice = GUICtrlRead($sellPriceInput)
			If $code = "Holdings" Then
				MsgBox(0,'Invalid','You did not choose anything')
			Else
				$id = MsgBox(1,'Confirmation','Code: '&$code&@CRLF&'Selling Price: $'&$sellPrice)
				If $id = $IDOK Then
					_sellStock($code,$sellPrice)
					_refresh()
				EndIf
			EndIf
		Case $transactionHistoryBtn
			_ArrayDisplay($history,"Transaction History")
	EndSwitch

WEnd

Func _loadData() ; sets data into gui
	_checkPendingDivsToday()
	GUICtrlSetData($currentMoneyInput,$currentMoney)
	GUICtrlSetData($totalPendingDividendsInput,'$'&_sumPendingDivs($pendingDivPayments))
	GUICtrlSetData($totalFrankingCreditsInput,'$'&$totalFrankingCredits)
	_GUICtrlComboBox_ResetContent($holdingsCombo)
	_GUICtrlComboBox_ResetContent($holdingsComboSell)
	_displayHoldingsInCombo($holdingsCombo,$holdings)
	_displayHoldingsInCombo($holdingsComboSell,$holdings)
EndFunc

Func _setDataForAboutTab()
	GUICtrlSetData($aboutBox,"Programming Language: Autoit"&@CRLF&"Coded By: noobling"&@CRLF&@CRLF&"================CONSTANTS================"&@CRLF&@CRLF&"Corporate tax rate = 30%"&@CRLF&"Transaction Cost = $11*"&@CRLF&@CRLF&"*Taken from CMC market")
EndFunc

Func _refresh()
	_loadData()
	_GUICtrlTab_SetCurFocus($tab,0) ; sets focus on snapshot tab
EndFunc

Func _setTooTips()
EndFunc

Func _init() ; things to run when program is first run
	If FileExists($SAVE_DIR) Then
	    _LoadSave()
    EndIf
	_refresh()
	_setDataForAboutTab()
	_setTooTips()
	MsgBox(0, 'Notice', 'Currently there is a bug when you try to sell but that is your only holding. Fix: make sure you have more than 1 holding at any one time')
EndFunc


