Option Explicit
' Declare variables
Dim strComputer, strServer
Dim fso, tf
Dim objWMIService, colItems, objItem, objConnection, colResources, objResource
Dim strPath, strUser, strFileSize, i
Dim arrFile, myFile

' This script returns a list of open files
' the user who has the file open
' and the reported size of the file on the disk

' Usage
' This script should be run on the machine you wish to query

' To/Do 
' Modify the script to create output file
' Remove inputbox in favor of pulling in the name of the system.

' Credits
' This script is based on two sources
' Open Sessions and Open Files on a computer script
' http://www.microsoft.com/technet/scriptcenter/resources/qanda/feb05/hey0216.mspx
' 
' Enumerating Files and File Properties script
' http://www.microsoft.com/technet/scriptcenter/guide/sas_fil_ciaj.mspx?mfr=true

' Get server name
	strComputer = "." 
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem",,48) 
	For Each objItem in colItems 
	strServer = objItem.Caption
	Next

' Open filesystem to create output file
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set tf = fso.CreateTextFile("c:\usrfiles.txt", True)

' Connect to the LanMan Service to retrieve list of open files
	Set objConnection = GetObject("WinNT://" & strServer & "/LanmanServer")
	Set colResources = objConnection.Resources


' There is no way to pull the size of a file directly from the lanman service
' so you need to reformat the path listing to feed it into the CIM_DataFile property
	For Each objResource in colResources
	
		strPath = "Path: " & objResource.Path
		
		'place additional \ in the drive location c:\ becomes c:\\
		'need to find each \ and replace it with \\
		
		arrFile = Split(objResource.Path, "\")
		
		myFile = ""
		
		for i = 0 to ubound(arrFile)
		myFile = myFile & arrFile(i) & "\\"
		next
		
		'Get rid of trailing \\
		
		myfile = left(myfile, len(myfile)-2)
			
		' The path returned by the above code is local to this computer "." therefore
		' it runs against the local machine.
		Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2") 
		Set colItems = objWMIService.ExecQuery( "SELECT * FROM CIM_DataFile WHERE Name = '" & myfile & "'",,48)
		
		For Each objItem in colItems 
		strFileSize =  "FileSize: " & objItem.FileSize
		Next
		
		strUser = "User: " & objResource.User
	
	' Build output file
	tf.WriteLine(strUser)
	tf.WriteLine(strpath)
	tf.WriteLine(strfilesize)
	tf.WriteBlankLines(1)
	tf.Close
	
	Next

