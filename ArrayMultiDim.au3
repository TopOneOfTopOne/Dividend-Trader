#include-once

#include <Array.au3>


; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayAssign
; Description ...: Assigns an array variable by name with the data.
; Syntax ........: _ArrayAssign($sArray, $vValue[, $Flag = 0])
; Parameters ....: $sArray    - Name of the array variable you wish to assign an array, or the array you wish to assign
;                                         a value.
;                  $vValue    - The data you wish to assign to the variable (see remarks).
;                  $Flag      - [optional] Checks if a variable is already assigned. Default is 0.
; Return values .: Success    - 1
;                  Failure    - 0 and set @error to 1
; Author ........: jguinch
; Remarks .......: $sArray can be a variable name or an array variable element (like array[0][1])
;                  If $sArray is a single variable name, $vValue must be an array.
;                  The function works with global variables only.
; ===============================================================================================================================
Func _ArrayAssign($sArray, $vValue, $Flag = 0)
	Local $iIsArray, $sStruct, $sElem
	If Not StringRegExp($sArray, "^\h*\w+(?:\h*\[\h*\d+\h*\])*\h*$") Then Return SetError(1, 0, 0)

	Local $sVarname = StringRegExpReplace($sArray, "^\h*(\w+)[\h\d\[\]]*$", "$1")
	If Not @extended Then Return SetError(1, 0, 0)

	Local $aDims = StringRegExp($sArray, "\[\h*(\d+)\h*\]", 3)
	If @error Then
		$iIsArray = True
		If Not IsArray($vValue) Then Return SetError(1, 0, 0)
		For $i = 1 To UBound($vValue, 0)
			$sStruct &= "[" & UBound($vValue, $i)& "]"
		Next

	Else
		$iIsArray = False
		For $i = 0 To UBound($aDims) - 1
			$sStruct &= "[" & $aDims[$i] + 1  & "]"
			$sElem &= "[" & $aDims[$i] & "]"
		Next
	EndIf

	If IsDeclared($sVarname) Then
		If $Flag Then Return SetError(1, 0, 0)
	Else
		If Not Assign($sVarname, "", 2) Then Return SetError(1, 0, 0)
		Local $aTmp = _ArrayDeclare($sStruct)
		If @error Then Return SetError(1, 0, 0)
		If Not Execute("__ArrayAssignValue($" & $sVarname & ", $aTmp, 1)") Then Return SetError(1, 0, 0)
	EndIf

	If $iIsArray Then
		Execute("__ArrayAssignValue($" & $sVarname & ", $vValue, 1)")
	Else
		Execute("__ArrayAssignValue($" & $sVarname & $sElem & ", $vValue )")
	EndIf
	If @error Then Return SetError(1, 0, 0)

	Return 1
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayCompare
; Description ...: Checks if two array are identical.
; Syntax ........: _ArrayCompare($aArray1, $aArray2[, $iFlag = 0])
; Parameters ....: $aArray1   - First array.
;                  $aArray2   - Second array.
;                  $iFlag     - [optional] Compare the data. Default is 0.
;                                  0   : Only compare the size.
;                                  1   : Compare the data (case sensitive)
; Return values .: Success    -  1 if the two arrays are identical.
;                                0 if the two arrays are differents. Sets @extended to non-zero value. See remarks.
;                  Failure    - -1 : Unable to compare the arrays.
; Author ........: jguinch
; Remarks .......: If the two array are differents, @extended is set to :
;                     1 : Different size.
;                     2 : Different of data.
;                  On failure, @error is set to :
;                     1 : One of the two variable is not an array.
;                     2 : Unable ro read one of the two array.
; ===============================================================================================================================
Func _ArrayCompare($aArray1, $aArray2, $iFlag = 0)
	If Not IsArray($aArray1) Or Not IsArray($aArray2) Then Return SetError(1, 0, -1)
	If UBound($aArray1, 0) <> UBound($aArray2, 0) Then Return SetError(0, 2, 0)

	For $i = 1 To UBound($aArray1, 0)
		If UBound($aArray1, $i) <> UBound($aArray2, $i) Then Return SetError(0, 2, 0)
	Next

	If $iFlag Then
		Local $aValues1 = _ArrayEnumValues($aArray1)
		If @error Then Return SetError(2, 0, -1)

		Local $aValues2 = _ArrayEnumValues($aArray2)
		If @error Then Return SetError(2, 0, -1)
		For $i = 0 To UBound($aValues1) - 1
			If Not ($aValues1[$i][1] == $aValues2[$i][1]) Then Return SetError(0, 2, 0)
		Next
	EndIf

	Return 1
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayDeclare
; Description ...: Creates an empty array with the specified size.
; Syntax ........: _ArrayDeclare($vStruct)
; Parameters ....: $vStruct   - Structure of the he array to create. See remarks
; Return values .: Success    - An empty array with the specified size.
;                  Failure    - 0 and set @error to 1.
; Author ........: jguinch
; Remarks .......: The function can create a multidimensioannal array, up to 32 dimensions.
;                  The $vStruct parameter can be a 1D array or a array size-type string.
;                  - A 1D array must have the following structure :
;                      $vStruct[0] : 1st dimension size
;                      $vStruct[1] : 2nd dimension size
;                      $vStruct[3] : 3rd dimension size
;                      $vStruct[x] : ...
;                  - A declaration-type string has the following format :
;                      "[10]" or "[10][5]" or "[15][3][2]" ...
; ===============================================================================================================================
Func _ArrayDeclare($vStruct)
	Local $aStruct, $aRet[1]

	If IsArray($vStruct) Then
		If UBound($vStruct, 0) <> 1 Then Return SetError(1, 0, 0)
		For $i = 0 To UBound($vStruct) - 1
			If Not IsInt($vStruct[$i]) Or $vStruct[$i] < 1 Then Return SetError(1, 0, 0)
		Next
		$aStruct = $vStruct
	ElseIf IsString($vStruct) Then
		$aStruct = StringRegExp($vStruct, "(?:^|\G)(?:\h*\[\h*(\d+)\h*\])", 3)
		If @error Then Return SetError(1, 0, 0)
	Else
		 Return SetError(1, 0, 0)
	EndIf

	Switch UBound($aStruct)
		Case 1
			Redim $aRet[$aStruct[0]]
		Case 2
			Redim $aRet[$aStruct[0]][$aStruct[1]]
		Case 3
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]]
		Case 4
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]]
		Case 5
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]]
		Case 6
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]]
		Case 7
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]]
		Case 8
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]]
		Case 9
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]]
		Case 10
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]]
		Case 11
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]]
		Case 12
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]]
		Case 13
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]]
		Case 14
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]]
		Case 15
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]]
		Case 16
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]]
		Case 17
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]]
		Case 18
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]]
		Case 19
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]]
		Case 20
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]]
		Case 21
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]]
		Case 22
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]]
		Case 23
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]]
		Case 24
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]]
		Case 25
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]][$aStruct[24]]
		Case 26
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]][$aStruct[24]][$aStruct[25]]
		Case 27
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]][$aStruct[24]][$aStruct[25]][$aStruct[26]]
		Case 28
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]][$aStruct[24]][$aStruct[25]][$aStruct[26]][$aStruct[27]]
		Case 29
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]][$aStruct[24]][$aStruct[25]][$aStruct[26]][$aStruct[27]][$aStruct[28]]
		Case 30
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]][$aStruct[24]][$aStruct[25]][$aStruct[26]][$aStruct[27]][$aStruct[28]][$aStruct[29]]
		Case 31
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]][$aStruct[24]][$aStruct[25]][$aStruct[26]][$aStruct[27]][$aStruct[28]][$aStruct[29]][$aStruct[30]]
		Case 32
			Redim $aRet[$aStruct[0]][$aStruct[1]][$aStruct[2]][$aStruct[3]][$aStruct[4]][$aStruct[5]][$aStruct[6]][$aStruct[7]][$aStruct[8]][$aStruct[9]][$aStruct[10]][$aStruct[11]][$aStruct[12]][$aStruct[13]][$aStruct[14]][$aStruct[15]][$aStruct[16]][$aStruct[17]][$aStruct[18]][$aStruct[19]][$aStruct[20]][$aStruct[21]][$aStruct[22]][$aStruct[23]][$aStruct[24]][$aStruct[25]][$aStruct[26]][$aStruct[27]][$aStruct[28]][$aStruct[29]][$aStruct[30]][$aStruct[31]]
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch

	Return $aRet
EndFunc ; ===> _ArrayDeclare


; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayDeclareFromString
; Description ...: Creates an array from a string.
; Syntax ........: _ArrayDeclareFromString($sString)
; Parameters ....: $sString   - String containing the data. See remarks.
; Return values .: Success    - An array with the specified values and the desired size.
;                  Failure    - 0 and sets @error to 1.
; Author ........: jguinch
; Remarks .......: The string must have the same syntax than a standard array declaration, like :
;                  "[123, 'abc', 0x10, -0.5]" or "[[ 'abc', 123, True], ['def', 124.1, False]]"...
;                  The function can create a multidimensioannal array, up to 32 dimensions.
;                  An array element can only contain a string, a numerical value or a boolean.
;                  WARNING : The function may fail with large arrays because of a recursion limitation.
; ===============================================================================================================================
Func _ArrayDeclareFromString($sString)
	Local $sPatternExtract = "[\[,]\K\h*(?|(""(?:.*?(?:"""")?)*"")|('(?:.*?(?:'')?)*')|(0x\d+)|([+-]?\d*\.?\d+(?:[eE]?[+-]?\d+)?)|(True|False|Null))\h*(?=[,\]])"
	Local $sPatternCheck = "(?x),\] | [^\[\]0,] | \[\] | \]\h*\["
	$sString = StringRegExpReplace($sString, "\[\h*\]", '[""]')

	Local $aElems = StringRegExp($sString, $sPatternExtract, 3)
	If @error Then Return SetError(1, 0, 0)

	StringRegExpReplace($sString, "(?:^|\G)(\h*\[)", "")
	Local $iDims = @extended,  $aTemp[$iDims + 1], $aStruct[$iDims], $iSubscript = $iDims - 1, $iMaxElems, $a, $iCountElems

	For $i = 0 To UBound($aElems) - 1
		$aElems[$i] = StringReplace( $aElems[$i], '[""]', "[]")
	Next
	$aTemp[0] = $aElems

	Local $sBuildString = StringReplace(StringRegExpReplace($sString, $sPatternExtract, "0"), " ", "")
	If StringRegExp($sBuildString, $sPatternCheck) Then Return SetError(1, 0, 0)

	For $n = 1 To UBound($aTemp) - 1
		$iMaxElems = 0
		$a = StringRegExp($sBuildString, "(\[[\d,]+\])", 3)

		For $i = 0 To UBound($a) - 1
			StringRegExpReplace($a[$i], "\d+", "")
			$iCountElems = @extended
			$sBuildString = StringReplace($sBuildString, $a[$i], $iCountElems)
			If $iCountElems > $iMaxElems Then $iMaxElems = $iCountElems

		Next
		$aTemp[$n] = StringRegExp($sBuildString, "\d+", 3)
		$aStruct[$iSubscript] = $iMaxElems
		$iSubscript -= 1
	Next
	If Not StringRegExp($sBuildString, "^\d+$") Then Return SetError(1, 0, 0)

	Local $aRet = _ArrayDeclare($aStruct)
	If @error Then Return SetError(1, 0, 0)

	__ArrayFromStringProc($aRet, $aTemp, UBound($aTemp) - 1)
	If @error Then Return SetError(1, 0, 0)

	Return $aRet
EndFunc ; ===> _ArrayDeclareFromString


; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayEnumValues
; Description ...: Returns all values and indexes of an array in a 2D array. See remarks.
; Syntax ........: _ArrayEnumValues($aArray)
; Parameters ....: $aArray    - Array to enum values.
; Return values .: Sucess     - a 2D array. See remarks.
;                  Failure    - 0 and sets @error to 1.
; Author ........: jguinch
; Remarks .......: A returned index is a string with the following format : "[12]" or "[2][3][1]"
;                  The array returned is two-dimensional and is made up as follows:
;                    $aArray[0][0] : 1st element index
;                    $aArray[0][1] : 1st element value
;                    $aArray[1][0] : 2nd element index
;                    $aArray[1][1] : 2nd element value
;                    $aArray[n][n] : ...
; ===============================================================================================================================
Func _ArrayEnumValues($aArray)
	If Not IsArray($aArray) Then Return SetError(1, 0, 0)
	Local $aRet = __ArrayEnumValuesProc($aArray, 1, "", 1)
	Return $aRet
EndFunc ; ===> _ArrayEnumValues


; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayEval
; Description ...: Returns the array from an array variable name, or the value of an array element.
; Syntax ........: _ArrayEval($sArray)
; Parameters ....: $sArray    - String representing name of the variable, or variable element. See remarks.
; Return values .: Success    - Returns an array if $sArray is an array variable name.
;                               Returns the array element value if $sArray is an array element.
; Author ........: jguinch
; Remarks .......: The format for an array element is "aArray[1][2]". For an array, just use the variable name like "aArray".
;                  If there is a need to use _ArrayEval(), then in most situations _ArrayAssign() should be used to create/write
;                  the array.
; ===============================================================================================================================
Func _ArrayEval($sArray)
	If Not StringRegExp($sArray, "^\h*\w+(?:\h*\[\h*\d+\h*\])*\h*$") Then Return SetError(1, 0, 0)
	Local $sVarInfo = StringRegExp($sArray, "^\h*(\w+)([\h\d\[\]]*)$", 1)
	If @error Then Return SetError(1, 0, 0)
	If $sVarInfo[1] = "" And Not Execute("IsArray($" & $sVarInfo[0] & ")") Then Return SetError(1, 0, 0)

	Local $aRet = Execute("$" & $sArray)
	If @error Then Return SetError(1, 0, 0)
	Return $aRet
EndFunc ; ===> _ArrayEval


; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayShuffleMultiDim
; Description ...: Shuffle the whole data of an array.
; Syntax ........: _ArrayShuffleMultiDim($aArray)
; Parameters ....: $aArray    - Array to modify.
; Return values .: Success    - 1
;                  Failure    - 0 and set @error to 1.
; Author ........: jguinch
; ===============================================================================================================================
Func _ArrayShuffleMultiDim(Byref $aArray)
	Local $aElems = _ArrayEnumValues($aArray)
	If @error Then SetError(1, 0, 0)

	_ArrayShuffle($aElems, 0, 0, 1)
	For $i = 0 To UBound($aElems) - 1
		Execute("__ArrayAssignValue($aArray" & $aElems[$i][0] & ", $aElems[$i][1])" )
		If @error Then Return SetError(1, 0, 0)
	Next

	Return 1
EndFunc ; ===> _ArrayShuffleMultiDim


; #FUNCTION# ====================================================================================================================
; Name ..........: _ArrayToDeclarationString
; Description ...: Returns an array declaration string. The returned string can be used with _ArrayDeclareFromString.
; Syntax ........: _ArrayToDeclarationString($aArray)
; Parameters ....: $aArray    - Array to build the declaration string from.
; Return values .: Success    - A string with a standard array declaration format.
;                  Failure    - Returns 0 and sets @error to 1.
; Author ........: jguinch
; ===============================================================================================================================
Func _ArrayToDeclarationString($aArray)
	If Not IsArray($aArray) Then Return SetError(1, 0, 0)
	Local $aRet =__ArrayToStringProc($aArray)
	Return $aRet
EndFunc ; ===> _ArrayToDeclarationString





; #INTERNAL_USE_ONLY# ===========================================================================================================
Func __ArrayAssignValue(ByRef $aArray, $aValues, $iFlag = 0)
	If $iFlag And Not IsArray($aValues) Then Return SetError(1, 0, 0)
	$aArray = $aValues
	Return 1
EndFunc ; ===> __ArrayAssignValue

; #INTERNAL_USE_ONLY# ===========================================================================================================
Func __ArrayEnumValuesProc($a, $iDim = 1, $sStruct = "", $iReset = 0)
	Local Static $iFlag = 0, $aRet[1], $iIndex = 0
	Local $iCountElems = 1
	If Not $iFlag Or $iReset Then
		Local $aNew[1]
		$aRet = $aNew
		For $i = 1 To UBound($a, 0)
			$iCountElems *= UBound($a, $i)
		Next

		ReDim $aRet[$iCountElems][2]
		$iFlag = 1
		$iIndex = 0
	EndIf


	For $i = 0 To UBound($a, $iDim) - 1
		If $iDim = UBound($a, 0) Then
			$aRet[$iIndex][0] = $sStruct & "[" & $i & "]"
			$aRet[$iIndex][1] = Execute("$a" & $sStruct & "[" & $i & "]")
			$aRet[$iIndex][1] = Execute("$aRet[$iIndex][1]")
			$iIndex += 1
		Else
			__ArrayEnumValuesProc($a, $iDim + 1, $sStruct & "[" & $i & "]")
		EndIf
	Next

	Return $aRet
EndFunc ; ===> __ArrayEnumValuesProc

; #INTERNAL_USE_ONLY# ===========================================================================================================
Func __ArrayFromStringProc(Byref $aRet, Byref $a, $iDim, $sStruct = "")
	Local $aTemp = $a[$iDim], $iRet
	Local $iElems = UBound($aTemp)
	Local $iValue = $aTemp[$iElems - 1]

	If $iDim = 0 Then
		$iValue = StringRegExpReplace($iValue, "\\(?=[\[\]])", "")
		Execute("__ArrayAssignValue($aRet" & $sStruct & ", " & $iValue & ")")
		If @error Then Return SetError(1, 0, 0)
	Else
		For $n = $iValue - 1 To 0 Step - 1
			__ArrayFromStringProc($aRet, $a, $iDim - 1, $sStruct & "[" & $n & "]")
			If @error Then Return SetError(1, 0, 0)
		Next
	EndIf
	Redim $aTemp[UBound($aTemp) - 1]
	$a[$iDim] = $aTemp
EndFunc ; ===> __ArrayFromStringProc

; #INTERNAL_USE_ONLY# ===========================================================================================================
Func __ArrayToStringProc($a, $iDim = 1, $sStruct = "")
	Local Static $sRet
	$iUBound = UBound($a, $iDim)
	If $iDim = 1 Then $sRet &= "["
	For $i = 0 To $iUBound - 1
		If $iDim = UBound($a, 0) Then
			$sVal = Execute("$a" & $sStruct & "[" & $i & "]")
			If IsString($sVal) Then $sVal = '"' & StringReplace($sVal, '"', '""') & '"'
			$sRet &= $sVal
			If $i < $iUBound - 1 Then $sRet &= ","
		Else
			If $i > 0 Then $sRet &= ","
			$sRet &= "["
			__ArrayToStringProc($a, $iDim + 1, $sStruct & "[" & $i & "]")
			$sRet &= "]"
		EndIf
	Next
	If $iDim = 1 Then $sRet &= "]"

	$sRet = StringRegExpReplace($sRet, ',?(?:"",)*""(?=\])', '')

	Return $sRet
EndFunc ; ===> __ArrayToStringProc
