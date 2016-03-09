#include <Date.au3>
#include <File.au3>
#include <Array.au3>
#include <AutoItConstants.au3>
#include <helper_functions.au3>

Global $SAVE_DIR = @ScriptDir&"/save.ini"
Global $TAX_DATE = "2016/07/01"
Global $TRANSACTION_COST = 10
Global $CTR = 0.3 ; corporate tax rate
Global $DISCOUNT_RATE = 0.02
Global $wealth, $totalFrankingCredits, $currentMoney, $pendingDivPayments[1][3] = [['Code','Pay Date','Payment amount']], $divPaymentHistory[1][3] = [['Code','Date','Payment amount']], $holdings[1][2] = [['Code','Number of Stocks']]
_initValuesForTesting()

Func _initValuesForTesting()
	$wealth = 1000
	$currentMoney = $wealth
	Local $divPayments[2][3] = [['DCK',"2016/01/01",500],['BCG','2016/03/01',100]]
	_ArrayAdd($pendingDivPayments, $divPayments)
	Local $sharesOwned[2][2] = [['CBA',1000],['RIO',50]]
	_ArrayAdd($holdings, $sharesOwned)

EndFunc


Func _sellStock($code, $sellPrice)
	Local $stock_index = _ArraySearch($holdings, $code,0, 0,0,0,1,0)
	If $stock_index < 0 Then
		MsgBox(0,'Error','No such code')
	Else
		Local $numStocks = $holdings[$stock_index][1]
		Local $money = $sellPrice * $numStocks
		_ArrayDelete($holdings,$stock_index) ; remove from holdings since sold
		$currentMoney = $currentMoney + $money - $TRANSACTION_COST
;~ 		$aInfo[4] = [$code,"Number of shares "&$numStocks,"Money earned "&$money,"Current money "&$currentMoney]
;~ 		_writeToLog($aInfo)
	EndIf
EndFunc

; updates appropriate variables
Func _buyStock($code, $divPayDate, $numStocks, $buyPrice, $franking, $dividend)
	Local $aholdings[1][2] = [[$code,$numStocks]]
	_ArrayAdd($holdings, $aholdings)

	Local $total_dividends = _calcDividendAmount($dividend, $numStocks)
	_addDivToPending($total_dividends, $divPayDate,$code)

	$currentMoney = $currentMoney - ($TRANSACTION_COST + ($buyPrice*$numStocks))

	Local $frankingCredits = _calcFrankingCredits($dividend, $franking, $numStocks, $CTR)
	$totalFrankingCredits += $frankingCredits

	;_writeToLog($aInfo)
EndFunc


Func _checkPendingDivsToday() ; checks if dividends are due to be paid today if so update appropriate variables
	Local $dateNow = @YEAR&'/'&@MON&'/'&@MDAY
	For $i = 1 To UBound($pendingDivPayments, $UBOUND_ROWS)-1
		Local $code = $pendingDivPayments[$i][0]
		Local $payDate = $pendingDivPayments[$i][1]
		Local $amount = $pendingDivPayments[$i][2]
		Local $aDiv[1][3] = [[$code,$payDate,$amount]]
		If (_DateDiff('D',$dateNow,$payDate) <= 0) And ($amount > 0) Then ; datediff will return a negative number if startdate is larger than enddate
			$currentMoney += $amount
			$pendingDivPayments[$i][2] = 0 ; set dividend at that particular date to 0 since no longer pending
			_ArrayAdd($divPaymentHistory,$aDiv)
			MsgBox(0,'You received',$code&': $'&$amount&' dividend today')
		EndIf
	Next
EndFunc


Func _addDivToPending($dividendAmount, $payDate, $code)
	Local $aDiv[1][3] = [[$code, $payDate, $dividendAmount]]
	_ArrayAdd($pendingDivPayments, $aDiv)
EndFunc

Func _LoadSave()
	$aData = IniReadSection($SAVE_DIR,"General")
	For $i = 1 To $aData[0][0]
		$data = $aData[$i][1]
		Switch $aData[$i][0]
			Case "$wealth"
				$wealth = $data
			Case "$totalFrankingCredits"
				$totalFrankingCredits = $data
			Case "$pendingDivPayments"
				$pendingDivPayments = $data
			Case "$divPaymentHistory"
				$divPaymentHistory = $data
			Case "$holdings"
				$holdings = $data
			Case "$currentMoney"
				$currentMoney = $data
		EndSwitch
	Next
EndFunc

Func _Save()
	$data = "$totalFrankingCredits="&$totalFrankingCredits&@LF&"$currentMoney="&$currentMoney&@LF&"$pendingDivPayments="&_ArrayToString($pendingDivPayments)&@LF&"$divPaymentHistory="&$divPaymentHistory&@LF&"$holdings="&_ArrayToString($holdings)
	_FileCreate($SAVE_DIR)
	IniWriteSection($SAVE_DIR, "General", $data)

EndFunc
_Save()
;~ $f = FileOpen(@ScriptDir&"/test.txt", 2)
;~ _FileWriteFromArray($f,$pendingDivPayments)
;~ Local $array
;~ _FileReadToArray(@ScriptDir&'/test.txt',$array)
;~ $array = _ArrayToString($pendingDivPayments,'|')
;$array = StringSplit($array,'|')
;~ ; _ArrayDisplay($array)

;~ MsgBox(0,'',$array)
;~ $array = StringSplit($array,@CRLF,2)
;~ _ArrayDisplay($array)
;~ $array = _ArrayToString($array)
;~ MsgBox(0,'',$array)
;~ $array = StringSplit($array,@CRLF,2)

;~ _ArrayDisplay($array)



