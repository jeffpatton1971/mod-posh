'
' UpdateFavortes.vbs
'
' This script needs to do several things, it will check the current value of HKCU\Software\Microsoft\Windows\
' Current Version\Explorer\User Shell Folders\Favorites. It will look like this:
'   \\people.soecs.ku.edu\profiles\%USERNAME%\Profile\Favorites
'
' 
Dim UserName
Groups = GetGroupMembership(".")

For Each GroupName In Groups
    NetPath = "\\people.soecs.ku.edu\"
    FolderPath = "\" & UserName & "\Profile\Favorites"
    Select Case GroupName
        Case "LegacyProfile"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & "Profiles" & FolderPath
            Wscript.Quit
        Case "AGroup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "CGroup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "EGroup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "IGroup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "KGroup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "MGroup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "NGroup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "SGRoup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
        Case "TGroup"
            BackupRegKeyValue "","",""
            SetRegKeyValue "", NetPath & Left(GroupName, 1) & FolderPath
            Wscript.Quit
    End Select
Next

Function GetGroupMembership(ComputerName)
    If ComputerName = "" Then ComputerName = "."

    Set objWMIService = GetObject("winmgmts:\\" & ComputerName & "\root\cimv2")
    Set colItems = objWMIService.ExecQuery("Select * From Win32_ComputerSystem")

    For Each objItem in colItems
        arrName = Split(objItem.UserName, "\")
        DomainName = arrName(0)
        UserName =  arrName(1)
    Next

    If LCase(DomainName) = "soecs" Then
        Set User = GetObject("WinNT://" & DomainName & "/" & UserName)
        For Each Group in User.groups
            GroupNames = GroupNames & Group.Name & ","
        Next
    Else
        Set objWMIService = GetObject("winmgmts:\\" & ComputerName & "\root\CIMV2") 
        Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_UserAccount WHERE Name = '" & UserName & "'",,48) 
        For Each objItem in colItems 
            UserSid = objItem.SID
        Next

        Set objPrincipal = GetObject("GC://cn=" & UserSid & ",cn=ForeignSecurityPrincipals,dc=soecs,dc=ku,dc=edu" )
        
        For Each Group In objPrincipal.memberOf
            ThisGroup = Split(Group, ",")
            GroupName = Right(ThisGroup(0),Len(ThisGroup(0))-3)
            GroupNames = GroupNames & GroupName & ","
        Next
    End If
    
    GetGroupMembership = Split(GroupNames, ",")
End Function

Function SetRegKeyValue(KeyPath, Value)
    If KeyPath = "" Then KeyPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\Favorites"
    Set WshShell = WScript.CreateObject("WScript.Shell")
    WshShell.RegWrite KeyPath, Value, "REG_SZ"
End Function

Function BackupRegKeyValue(KeyPath, BackupPath, FileName)
    If KeyPath = "" Then KeyPath = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders\Favorites"
    If FileName = "" Then FileName = "Backup-RegistryKey.txt"
    If BackupPath = "" Then BackupPath = "U:"
    
    Set WshShell = WScript.CreateObject("WScript.Shell")
    CurKey = WshShell.RegRead(KeyPath)

    Dim objFSO
	
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    
    Set File = objFSO.OpenTextFile(BackupPath & "\" & FileName ,8, True)
    File.WriteLine("Backup-RegKeyValue ran on " & Now())
    File.WriteLine("Backing up registry key:" & KeyPath)
    File.WriteLine("Original value: " & CurKey)
    File.WriteLine
    File.Close
End Function