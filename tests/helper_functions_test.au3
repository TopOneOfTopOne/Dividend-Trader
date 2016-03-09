#include <Array.au3>
#include <../helper_functions.au3>


	Global $wealth = 1000
	Global $currentMoney = $wealth
;~ 	Local $divPayments[2][2] = [["2016/01/01",500],['2016/03/01',100]]
;~ 	_ArrayAdd($pendingDivPayments, $divPayments)
;~ 	Local $sharesOwned[2][2] = [['CBA',1000],['RIO',50]]
;~ 	_ArrayAdd($holdings, $sharesOwned)
	Global $pendingDivPayments[3][3] = [['DGK','2016/03/01',200],['DGK','2016/03/01',200],['DGK','2016/03/01',200]]
	Global $divPaymentHistory[1][3] = [[0,0,0]]



Func _displayOutcome($funcName,$outCome)
	ConsoleWrite('Function: '&$funcName&' Outcome: '&$outCome&@CRLF)
EndFunc


Func moneyAtDateTest()
	; _initValuesForTesting()
	$date = @YEAR&'/'&@MON&'/'&@MDAY
	$money = _moneyAtDate($date,$currentMoney,$pendingDivPayments)
	MsgBox(0,'money',$money)
	_ArrayDisplay($pendingDivPayments, 'Pending dividends')
EndFunc

moneyAtDateTest()

Func _calcDividendAmountTest()
	If _calcDividendAmount(10,100) = 10 Then ; 10 cent dividend and 100 stocks
		_displayOutcome('_calcDividendAmount','Passed')
	Else
		_displayOutcome('_calcDividendAmount','Failed')
	EndIf
EndFunc

;_calcDividendAmountTest()

Func _calcFrankingCreditsTest()
	If round(_calcFrankingCredits(10, 66, 1, 0.3), 4) = 0.0283   Then ; 10 cent dividend, 66% franking, 1 stock
		_displayOutcome('_calcFrankingCredits','Passed')
	Else
		_displayOutcome('_calcFrankingCredits','Failed')
	EndIf
EndFunc
; _calcFrankingCreditsTest()

Func _sumPendingDivsTest()
	;_initValuesForTesting()
	MsgBox(0,'',_sumPendingDivs($pendingDivPayments))
EndFunc
; _calcTotalPendingDivsTest()
