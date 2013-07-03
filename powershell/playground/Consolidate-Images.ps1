<#
    .SYNOPSIS
        Consolidate all my photos into a single repository.
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER RepoPath
        The path to your checked out repo
    .EXAMPLE
        .\Consolidate-Images.ps1 -RepoPath C:\Repository\
        
        Description
        -----------
        Showing the only usage of this script.
    .NOTES
        ScriptName: Consolidate-Images.ps1
        Created By: Jeff Patton
        Date Coded: July 15, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
        
        This script has gone through several iterations over the past few weeks. It includes a library
        that has the function I created to grab images using WDS, as well as the MD5 function to
        generate the hash code from the image.
        
        
    .LINK
#>
Param
    (
    $RepoPath = "C:\Photos\"
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME

        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue

        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

        #	Dotsource in the functions you need.
        . .\includes\ImagingLibrary.ps1
        
        $Photos = @()
        $Count = $null
        }
Process
    {
        # Pull images from the default Windows Vista/7 location
        $SearchResult = Get-ImagesFromWDS -LocalPath F:\Pictures
        
        # Setup the progress bar counter
        foreach ($record in $SearchResult.Tables[0]){$PhotoCount ++}
        
        # Build an object out of the database results, add the MD5Sum
        foreach ($record in $SearchResult.Tables[0])
        {
            $Count ++
            Write-Progress -Id 1 -Activity "Retrieving and hashing images" -Status "Processing $Count of $($PhotoCount)" -PercentComplete (($Count / $PhotoCount) * 100)
            $ThisPhoto = New-Object -TypeName PSObject -Property @{
                FileName = $record.item("SYSTEM.FILENAME")
                ItemPath = $record.item("SYSTEM.ITEMPATHDISPLAY")
                DestPath = "$($RepoPath)$(get-date(($record.item("SYSTEM.PHOTO.DATETAKEN"))) -format "yyyy")\$(get-date(($record.item("SYSTEM.PHOTO.DATETAKEN"))) -format "MMM")"
                Hash = Get-BitmapHash -FileName ($record.item("SYSTEM.ITEMPATHDISPLAY")).Replace("My ","")
                CameraManufacturer = $record.item("SYSTEM.PHOTO.CAMERAMANUFACTURER")
                CameraModel = $record.item("SYSTEM.PHOTO.CAMERAMODEL")
                DateTaken = $record.item("SYSTEM.PHOTO.DATETAKEN")
                Flash = $record.item("SYSTEM.PHOTO.FLASH")
                FNumber = $record.item("SYSTEM.PHOTO.FNUMBER")
                FocalLength = $record.item("SYSTEM.PHOTO.FOCALLENGTH")
                ISOSpeed = $record.item("SYSTEM.PHOTO.ISOSPEED")
                Orientation = $record.item("SYSTEM.PHOTO.ORIENTATION")
                ShutterSpeed = $record.item("SYSTEM.PHOTO.SHUTTERSPEED")
                SubjectDistance = $record.item("SYSTEM.PHOTO.SUBJECTDISTANCE")
                }
            $Photos += $ThisPhoto
            }

        # Remove invalid MD5Sums, duplicate MD5Sums, sort by date, skip images from folders I don't care about
        $Photos = $Photos |Where-Object {$_.Hash -ne "D41D8CD98F00B204E9800998ECF8427E"} |Sort-Object -Property Hash -Unique
        $Photos = $Photos |Where-Object {$_.ItemPath -notlike "*Downloaded Albums*"}
        $Photos = $Photos |Where-Object {$_.ItemPath -notlike "*Saved pictures*"} |Sort-Object -Property DateTaken
        $Photos = $Photos |Sort-Object -Property DateTaken

        $Count = $null
        # Loop through each photo add it to the repo and then commit it.
        foreach ($Photo in $Photos)
        {
            $DestPath = $Photo.DestPath

            $Count ++
            Write-Progress -Id 2 -ParentId 1 -Activity "Sending images to server" -Status "Processing $Count of $($Photos.Count)" -PercentComplete (($Count / $Photos.Count) * 100)
            
            # Check if the DestPath exists, if not create it, add it and commit it
            if ((test-path $DestPath) -eq $false)
            {
                New-Item $DestPath -ItemType Directory
                & svn add $DestPath
                & svn ci $DestPath -m "Added directory $($DestPath)"
                }

            # Copy the image from the original location to the new location
            Copy-Item ($Photo.ItemPath).Replace("My ","") -Destination $DestPath
            
            # Export the EXIF date to an xml
            Export-Clixml -InputObject $Photo -Path "$($DestPath)\$($Photo.FileName).xml"
            
            # Add the image to the repo, set it's mime-type to image/jpeg, and commit it
            & svn add "$($DestPath)\$($Photo.FileName)"
            & svn propset svn:mime-type image/jpeg "$($DestPath)\$($Photo.FileName)"

            # Check if there is a GPS tag stored in the image if so, adjust message to
            # display Google Maps URLof the image.
            $Gps = Get-GpsCoords -FileName ($Photo.ItemPath).Replace("My ","")
            If ($Gps -eq $null)
            {
                $Message = "Photo taken on $($Photo.DateTaken)`nPhoto captured with a $($Photo.CameraManufacturer) $($Photo.CameraModel)`nAdded $($Photo.FileName) to the repo on $(Get-Date)"
                & svn ci "$($DestPath)\$($Photo.FileName)" -m $Message
                }
            Else
            {
                $MapsURL = "http://maps.google.com/maps?q=$($Gps.laDeg)+$($Gps.laMin)%27+$($Gps.laSec)%22$($Gps.laDir),$($Gps.loDeg)+$($Gps.loMin)%27+$($Gps.loSec)%22$($Gps.loDir)"
                $MapsAlt = "Photo taken at $($Gps.laDeg) $($Gps.laMin)`' $($Gps.laSec)`"$($Gps.laDir), $($Gps.loDeg) $($Gps.loMin)`' $($Gps.loSec)`"$($Gps.loDir). Altitude of $($Gps.alt)"
                $Message = "Photo taken on $($Photo.DateTaken)`nPhoto captured with a $($Photo.CameraManufacturer) $($Photo.CameraModel)`nAdded $($Photo.FileName) to the repo on $(Get-Date)`n[[$($MapsURL) | $($MapsAlt)]]"
                & svn ci "$($DestPath)\$($Photo.FileName)" -m $Message
                }
            
            # Add the XML file to the repo, set it's mime-type to text/xml and commit it.
            & svn add "$($DestPath)\$($Photo.FileName).xml"
            & svn propset svn:mime-type text/xml "$($DestPath)\$($Photo.FileName).xml"
            & svn ci "$($DestPath)\$($Photo.FileName).xml" -m "EXIF xml data for $($Photo.FileName).xml to the repo on $(Get-Date)"
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
        }