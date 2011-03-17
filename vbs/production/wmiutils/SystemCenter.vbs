Function SCCMPerformAction(sActionName, strComputerName)
	' Available Actions in the Configuration Manager
	' Properties Dialog, Action tab.
	'
	' "Software Inventory Collection Cycle"
	' "MSI Product Source Update Cycle"
	' "Hardware Inventory Collection Cycle"
	' "Software Updates Assignments Evaluation Cycle"
	' "Standard File Collection Cycle"
	' "Discovery Data Collection Cycle"
	' "Request & Evaluate User Policy"
	' "Peer DP Maintenance Task"
	' "Request & Evaluate Machine Policy"
	' "Software Metering Usage Report Cycle"
		Dim oCPAppletMgr
		Dim oClientActions
		Dim oClientAction

		Set oCPAppletMgr = CreateObject("CPApplet.CPAppletMgr", strComputerName)
		Set oClientActions = oCPAppletMgr.GetClientActions()
		For Each oClientAction In oClientActions
			If oClientAction.Name = sActionName Then
				SCCMPerformAction = oClientAction.PerformAction
			End If
		Next
End Function