#include <Date.au3>

Func _calcDividendAmount($dividend, $numStocks) ; assume dividend unit is CPS
	Local $amount = ($dividend/100) * $numStocks
	return $amount
EndFunc

Func _calcFrankingCredits($dividend, $franking, $numStocks, $corporate_tax_rate)
	$dividend = $dividend/100
	$frankingCreditsPerShare = $dividend/(1-$corporate_tax_rate) - $dividend
	$adjusted = $frankingCreditsPerShare * ($franking/100)
	$frankingCredits = $adjusted * $numStocks
	return $frankingCredits
EndFunc


Func _sumPendingDivs($aPendingDivs) ; format [[Code,Date,Amount]] ; skips the first row to allow for headers
	Local $total = 0
	For $i = 1 To UBound($aPendingDivs,$UBOUND_ROWS)-1
		$total += $aPendingDivs[$i][2]
	Next
	return $total
EndFunc

Func _moneyAtDate($date,$currentMoney,$pendingDivPayments) ; format [[Code,Date,Amount]] ;skips the first row to allow for headers
	For $i = 1 To UBound($pendingDivPayments, $UBOUND_ROWS)-1
		$payDate = $pendingDivPayments[$i][1]
		$amount = $pendingDivPayments[$i][2]
		If (_DateDiff('D',$date,$payDate) < 0) And ($amount > 0) Then ; datediff will return a negative number if startdate is larger than enddate
			$currentMoney += $amount
		EndIf
	Next
	Return $currentMoney
EndFunc

Func _displayHoldingsInCombo($combo, $holdings)
	For $i = 1 To UBound($holdings, $UBOUND_ROWS)-1
		local $code = $holdings[$i][0]
		Local $numStocks = $holdings[$i][1]
		GUICtrlSetData($combo,$code&' - '&$numStocks)
	Next
EndFunc


