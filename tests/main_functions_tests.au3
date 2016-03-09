#include <../main_functions.au3>

Func _checkPendingDivsTodayTest()
	;_initValuesForTesting()
	_checkPendingDivsToday()
	_ArrayDisplay($pendingDivPayments)
	MsgBox(0,'','Pending divs '&$totalPendingDivs& ' Money '&$currentMoney)
EndFunc
; _checkPendingDivsTodayTest()


Func _sellStockTest()
	_ArrayDisplay($holdings)
	_sellStock('RIO', 30.25)
	MsgBox(0, 'sellStockTest','current money '&$currentMoney)
	_ArrayDisplay($holdings)
EndFunc
; _sellStockTest()

Func _buyStockTest()
	_buyStock('ANZ','2015/02/03',20,12,100,15)
	MsgBox(0,'buyStockTest','current money '&$currentMoney& 'Franking credits '&$totalFrankingCredits)
	_ArrayDisplay($holdings)
	_ArrayDisplay($pendingDivPayments)
EndFunc
 ; _buyStockTest()
