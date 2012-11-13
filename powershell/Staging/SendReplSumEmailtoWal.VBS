SMTPServer="smtp.ku.edu" 
SendTo="wal@ku.edu"
SendFrom="ccline@ku.edu" 
crlf=chr(10) & chr(13)
Block=""
ErrorStatus="No Errors!"

RunRepadmin
SendMail




Sub RunRepadmin


	Command = "cmd /c repadmin /replsummary"
	set WshShell = wscript.createobject("wscript.shell")
	on error resume next
	set objExec = WshShell.Exec(Command)

	Block=""

	Do WHile not objExec.StdOut.AtEndOfStream
		Raw = trim (objExec.StdOut.ReadLine)
		' wscript.echo Raw
		Block = Block & Raw & crlf		        	
		If instr(Raw,":") then
			If instr(Raw,"Replication Summary") Then
			ElseIf instr(Raw,"Beginning") Then
					'Do Nothing
		   		else	
					Raw2=Replace(Raw,"  "," ")
					Raw2=Replace(Raw2,"  "," ")
					Raw2=Replace(Raw2,"  "," ")
					Raw2=Replace(Raw2,"  "," ")
					Raw2=Replace(Raw2,"  "," ")
					Raw2=Replace(Raw2,"  "," ")
					Raw2=Replace(Raw2,"  "," ")
					arrRaw=Split(Raw2," ")
					if arrRaw(5) <> "0" then
						ErrorStatus="Replication Errors Detected!"
					end if
       		   	end if	
		end if
	Loop
	Set objExec = Nothing
	wscript.echo Block

End Sub








Sub SendMail


Set objEmail = CreateObject("CDO.Message") 
 
objEmail.From = SendFrom
objEmail.To = SendTo
objEmail.Subject = "Replication Status: " & ErrorStatus  
objEmail.Textbody = Block
objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = SMTPServer 
objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25 
objEmail.Configuration.Fields.Update 
objEmail.Send 


End Sub