'
' ListObjectAttribs
'
' This script lists all attributes for a given object
' within your AD.
'
' USAGE:
'
' The best way to run this is to redirect the output
' to a file.
'
' cscript //nologo ListObjectAttribs.vbs > ObjectAttribs.txt
'
Dim strObject

	strObject = "computer"
	
	Set objGroupClass = GetObject("LDAP://schema/" & strObject)
	Set objSchemaClass = GetObject(objGroupClass.Parent)
	 
	i = 0

	WScript.Echo "Mandatory attributes:"
	For Each strAttribute in objGroupClass.MandatoryProperties
		i = i + 1
		WScript.Echo i & vbTab & strAttribute

		Set objAttribute = objSchemaClass.GetObject("Property",  strAttribute)
		WScript.Echo " (Syntax: " & objAttribute.Syntax & ")"

		If objAttribute.MultiValued Then
			WScript.Echo " Multivalued"
		Else
			WScript.Echo " Single-valued"
		End If
	Next
	 
	WScript.Echo VbCrLf & "Optional attributes:"
	For Each strAttribute in objGroupClass.OptionalProperties
		i = i + 1
		Wscript.Echo i & vbTab & strAttribute
		Set objAttribute = objSchemaClass.GetObject("Property",  strAttribute)

		Wscript.Echo " [Syntax: " & objAttribute.Syntax & "]"

		If objAttribute.MultiValued Then
			WScript.Echo " Multivalued"
		Else
			WScript.Echo " Single-valued"
		End If
	Next