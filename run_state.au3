#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <main_functions.au3>
#include <GuiComboBox.au3>


#Region ### START Koda GUI section ### Form=c:\users\p\desktop\tradergui.kxf
$traderGUI = GUICreate("Dividend Trader by noobling", 324, 338, -1, -1)
GUISetIcon("C:\Users\P\AppData\Roaming\uTorrent\uTorrent.exe", -1)
$Tab1 = GUICtrlCreateTab(8, 0, 633, 561)
$TabSheet1 = GUICtrlCreateTabItem("Snapshot")
$snapshotGUI = GUICtrlCreateGroup("Snapshot", 28, 25, 257, 433, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
$currentMoneyInput = GUICtrlCreateInput("", 44, 113, 129, 21)
$currentMoneyLabel = GUICtrlCreateLabel("Available Funds", 44, 89, 79, 17)
$currentMoneyBtnChange = GUICtrlCreateButton("Change", 180, 113, 75, 25)
$totalPendingDividendsInput = GUICtrlCreateInput("", 44, 177, 129, 21)
$totalPendingDivLabel = GUICtrlCreateLabel("Total Pending Dividends", 44, 153, 120, 17)
$pendingDividendsBtn = GUICtrlCreateButton("View Dividends", 180, 177, 83, 25)
$totalFrankingCreditsInput = GUICtrlCreateInput("", 44, 281, 129, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
$totalFrankingCreditsLabel = GUICtrlCreateLabel("Total Franking Credits", 44, 257, 107, 17)
$dividendHistoryBtn = GUICtrlCreateButton("View past dividends", 76, 217, 155, 25)
$holdingsLabel = GUICtrlCreateLabel("Holdings", 200, 256, 45, 17)
$holdingsCombo = GUICtrlCreateCombo("Holdings", 180, 280, 100, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$refreshBtn = GUICtrlCreateButton("Refresh", 120, 48, 75, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$TabSheet2 = GUICtrlCreateTabItem("Buy")
$codeInput = GUICtrlCreateInput("", 40, 64, 73, 21)
$buyPriceInput = GUICtrlCreateInput("", 184, 64, 81, 21)
$numSharesInput = GUICtrlCreateInput("", 40, 144, 81, 21)
$dividendInput = GUICtrlCreateInput("", 184, 144, 81, 21)
$divDateInput = GUICtrlCreateInput("", 40, 224, 89, 21)
$frankingInput = GUICtrlCreateInput("", 184, 224, 89, 21)
$buyBtn = GUICtrlCreateButton("Buy", 120, 272, 75, 25)
$codeLabel = GUICtrlCreateLabel("Code", 40, 40, 29, 17)
$buyPriceLabel = GUICtrlCreateLabel("Buy Price ($)", 184, 40, 64, 17)
$numSharesLabel = GUICtrlCreateLabel("Number of Shares", 40, 120, 89, 17)
$dividendLabel = GUICtrlCreateLabel("Dividend (CPS)", 184, 120, 76, 17)
$divDateLabel = GUICtrlCreateLabel("Dividend Pay Date", 40, 200, 93, 17)
$frankingLabel = GUICtrlCreateLabel("Franking (%)", 184, 200, 62, 17)
$TabSheet3 = GUICtrlCreateTabItem("Sell")
$codeSellinput = GUICtrlCreateInput("", 101, 136, 121, 21)
$sellPriceInput = GUICtrlCreateInput("", 101, 218, 121, 21)
$codeLabel2 = GUICtrlCreateLabel("Code", 139, 106, 29, 17)
$sellPriceLabel = GUICtrlCreateLabel("Sell Price ($)", 136, 184, 48, 17)
$holdingsLabelSell = GUICtrlCreateLabel("Holdings", 137, 29, 45, 17)
$holdingsComboSell = GUICtrlCreateCombo("Holdings", 102, 58, 121, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$sellBtn = GUICtrlCreateButton("Sell", 128, 272, 75, 25)
GUICtrlCreateTabItem("")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


Func _loadData()
	_checkPendingDivsToday()
	GUICtrlSetData($currentMoneyInput,$currentMoney)
	GUICtrlSetData($totalPendingDividendsInput,'$'&_sumPendingDivs($pendingDivPayments))
	GUICtrlSetData($totalFrankingCreditsInput,'$'&$totalFrankingCredits)
	_GUICtrlComboBox_ResetContent($holdingsCombo)
	_GUICtrlComboBox_ResetContent($holdingsComboSell)
	_displayHoldingsInCombo($holdingsCombo,$holdings)
	_displayHoldingsInCombo($holdingsComboSell,$holdings)
EndFunc

If FileExists($SAVE_DIR) Then
	_LoadSave()
EndIf

_loadData()


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_Save()
			Exit
		Case $refreshBtn
			_loadData()
		Case $pendingDividendsBtn
			_ArrayDisplay($pendingDivPayments,"Pending Dividends")
		Case $currentMoneyBtnChange
			$value = GUICtrlRead($currentMoneyInput)
			$moneyBefore = $currentMoney
			$currentMoney = $value
			MsgBox(0,'Done','Funds changed from: $'&$moneyBefore&' To: $'&$currentMoney)

		Case $dividendHistoryBtn
			_ArrayDisplay($divPaymentHistory, "Dividend Payment History")
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
				MsgBox(0,'Transaction Executed','Go to snapshot tab and click "refresh" to view changes')
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
					MsgBox(0,'Transaction Executed','Go to snapshot tab and click "refresh" to view changes')

				EndIf
			EndIf

	EndSwitch

WEnd


