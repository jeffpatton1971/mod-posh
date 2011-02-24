' file_stat.vbs 
' Determine the largest, smallest, and average file sizes  
' in the subdirectories of a given directory 
 '
 ' http://gallery.technet.microsoft.com/scriptcenter/8ab05dfd-f476-4e62-9333-203109d225c2
' ----- configuration ----- 
 
strFolderPath = "U:\" 
 
strLogFile = "C:\TEMP\filestats.log" 
' ----------------------------- 
Const ForAppending = 8 
 
' Open log file for appending 
 
Set objFSO = CreateObject("Scripting.FileSystemObject") 
Set objLogFile   = objFSO.OpenTextFile( strLogFile, ForAppending) 
 
' Walk the tree, logging info to file 
 
'Set objFSO = CreateObject("Scripting.FileSystemObject") 
Set objParent = objFSO.GetFolder( strFolderPath ) 
 
For Each objFolder in objParent.SubFolders 
    'Field: FolderName 
    objLogFile.Write ( objFolder.Path & ",") 
    'Field: StartTime 
    objLogFile.Write ( now()          & ",") 
 
    ' Get statistics 
    iLargest  = 0 
    iCount    = 0 
    iTotal    = 0 
     
    ProcessFolders objFolder 
 
    'Field: FileCount 
    objLogFile.Write ( iCount & ",") 
 
    If iCount > 0 Then 
    'Field: Largest 
        objLogFile.Write(iLargest & ",") 
    'Field: Average 
        objLogFile.Write((iTotal/iCount) & ",") 
    Else 
        'no values if no files 
        objLogFile.Write(",,") 

    End IF 
    'Field: Finished 
    objLogFile.Write ( now() & VbCrLF) 
Next 
 
objLogFile.Close 
 
'------------------------------------------------------------- 
' Recursive subroutine for processing all files and subfolders 
 
Sub ProcessFolders( objFolder ) 
    For Each objSubFolder in objFolder.SubFolders 
        'Wscript.Echo objSubFolder.Path 
        ProcessFolders objSubFolder 
    Next 
 
    Set colFiles = objFolder.Files 
 
    For Each objFile in colFiles 
        iCount = iCount + 1 
 
        'The First File is the largest and Smallest 
        if iCount = 1 Then 
            iLargest  = ObjFile.Size 
        End If 
         
        'is this the largest file? 
        if objFile.Size > iLargest Then 
            iLargest = objFile.Size 
        End If 
 
        iTotal = iTotal + ObjFile.Size 
         
    Next 
 
End Sub 