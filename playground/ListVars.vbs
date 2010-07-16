

Wscript.echo Now()
Set objWMIService = GetObject("winmgmts:\\delete-me.soecs.ku.edu\root\cimv2")

Set colItems = objWMIService.ExecQuery("Select * from Win32_Environment") ' Where Name = 'LM_LICENSE_FILE'")
Wscript.echo "Query Executed"

	For Each objItem in colItems


		If objItem.Name = "LM_LICENSE_FILE" Then
			blnFound = vbTrue
			Wscript.echo "True " & objItem.Name
			Wscript.Echo objItem.VariableValue
			Wscript.echo objItem.username
			Exit For
		Else
			Wscript.echo "False " & objItem.Name
			Wscript.Echo objItem.VariableValue
			Wscript.echo objItem.username
			blnFound = vbFalse
		End If

	Next
