' UpdateFavortes.vbs
'
' This script needs to do several things, it will check the current value of HKCU\Software\Microsoft\Windows\
' Current Version\Explorer\User Shell Folders\Favorites. It will look like this:
'   \\people.soecs.ku.edu\profiles\%USERNAME%\Profile\Favorites
'
' Updated 6/29/2011 - Added call to log the update event
Dim UserName
Groups = GetGroupMembership(".")

For Each GroupName In Groups
    NetPath = "\\people.soecs.ku.edu\"
    FolderPath = "\" & UserName & "\Profile\Favorites"
    Select Case GroupName
        Case "LegacyProfile"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & "Profiles" & FolderPath
            Wscript.Quit
        Case "AGroup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "CGroup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "EGroup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "IGroup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "KGroup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "MGroup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "NGroup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "SGRoup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "TGroup"
            BackupRegKeyValue ""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
    End Select
Next

Function GetGroupMembership(ComputerName)
    Const HKEY_CURRENT_USER = &H80000001

    If ComputerName = "" Then ComputerName = "."

    Set WshNetwork = CreateObject("Wscript.Network")

    DomainName = WshNetwork.UserDomain
    UserName =  WshNetwork.UserName

    Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
    oReg.EnumKey HKEY_CURRENT_USER, "Software\Microsoft\Protected Storage System Provider", arrSubKeys

    For Each subkey In arrSubKeys
        UserSid = subkey
    Next
    
    If LCase(DomainName) = "soecs" Then
        Set User = GetObject("WinNT://" & DomainName & "/" & UserName)
        For Each Group in User.groups
            GroupNames = GroupNames & Group.Name & ","
        Next
    Else

        Set objPrincipal = GetObject("GC://cn=" & UserSid & ",cn=ForeignSecurityPrincipals,dc=soecs,dc=ku,dc=edu" )
        If isArray(objPrincipal.memberOf) Then
            For Each Group In objPrincipal.memberOf
                ThisGroup = Split(Group, ",")
                GroupName = Right(ThisGroup(0),Len(ThisGroup(0))-3)
                GroupNames = GroupNames & GroupName & ","
            Next
        Else
                ThisGroup = Split(objPrincipal.memberOf, ",")
                GroupName = Right(ThisGroup(0),Len(ThisGroup(0))-3)
                GroupNames = GroupNames & GroupName & ","
        End If
    End If
    
    GetGroupMembership = Split(GroupNames, ",")
End Function

Function SetRegKeyValue(KeyPath, Value)
    If KeyPath = "" Then KeyPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\Favorites"
    Set WshShell = WScript.CreateObject("WScript.Shell")
    WshShell.RegWrite KeyPath, Value, "REG_SZ"
    
    Call LogData(0, "Setting Favorites KeyValue = " & Value)
End Function

Function BackupRegKeyValue(KeyPath)
    If KeyPath = "" Then KeyPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\Favorites"
    
    Set WshShell = WScript.CreateObject("WScript.Shell")
    CurKey = WshShell.RegRead(KeyPath)

    Call LogData(0, "Original Favorites KeyValue = " & CurKey)
End Function

Sub LogData(intCode, strMessage)
	' Write data to application log
	' 
	' http://www.microsoft.com/technet/scriptcenter/guide/default.mspx?mfr=true
	'
	' Event Codes
	' 	0 = Success
	'	1 = Error
	'	2 = Warning
	'	4 = Information
	Dim objShell

	Set objShell = Wscript.CreateObject("Wscript.Shell")

		objShell.LogEvent intCode, strMessage

End Sub