strComputer = "bastion.soecs.ku.edu"
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set colVolumes = objWMIService.ExecQuery("Select * from Win32_Volume")

For Each objVolume in colVolumes
    errResult = objVolume.DefragAnalysis(blnRecommended, objReport)
    If errResult = 0 Then
        Wscript.Echo "Volume name: " & objVolume.Name
        If blnRecommended Then
           Wscript.Echo "You should defragment this volume."
        Else
           Wscript.Echo "You do not need to defragment this volume."
        End If
        Wscript.Echo

        Wscript.Echo "Volume size: " & objReport.VolumeSize  
        Wscript.Echo "Cluster size: " & objReport.ClusterSize
        Wscript.Echo "Used space: " & objReport.UsedSpace
        Wscript.Echo "Free space: " & objReport.FreeSpace
        Wscript.Echo "Percent free space: " & objReport.FreeSpacePercent
        Wscript.Echo

        Wscript.Echo "Total fragmentation: " & _
            objReport.TotalPercentFragmentation
        Wscript.Echo "File fragmentation: " & _
            objReport.FilePercentFragmentation
        Wscript.Echo "Free space fragmentation: " & _
            objReport.FreeSpacePercentFragmentation
        Wscript.Echo

        Wscript.Echo "Total files: " & objReport.TotalFiles
        Wscript.Echo "Average file size: " & objReport.AverageFileSize
        Wscript.Echo "Total fragmented files: " & _
            objReport.TotalFragmentedFiles
        Wscript.Echo "Total excess fragments: " & _
            objReport.TotalExcessFragments
        Wscript.Echo "Average fragments per file: " & _
            objReport.AverageFragmentsPerFile
        Wscript.Echo

        Wscript.Echo "Page file size: " & objReport.PageFileSize
        Wscript.Echo "Total fragments: " & _
            objReport.TotalPageFileFragments
        Wscript.Echo

        Wscript.Echo "Total folders: " & objReport.TotalFolders
        Wscript.Echo "Fragmented folders: " & objReport.FragmentedFolders
        Wscript.Echo "Excess folder fragments: " & _
            objReport.ExcessFolderFragments
        Wscript.Echo

        Wscript.Echo "Total MFT size: " & objReport.TotalMFTSize
        Wscript.Echo "MFT record count: " & objReport.MFTRecordCount
        Wscript.Echo "Percent MFT in use: " & objReport.MFTPercentInUse
        Wscript.Echo "Total MFT fragments: " & objReport.TotalMFTFragments
        Wscript.Echo     

    Else
        Wscript.Echo objVolume.Name & " could not be analyzed."
        Wscript.Echo "Error number " & errResult & " occurred."
        Wscript.Echo
    End If
Next