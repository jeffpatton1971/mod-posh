<#
    .SYNOPSIS
        This script returns a collection of unique images from a folder.
    .DESCRIPTION
        This script processes each image it finds in order to build a unique
        list of images to transfer. The resulting object can be used to copy
        the images to a new folder, or folder structure.
        
        Initially the the script will process each image and MD5 the content.
        This code was found here, http://www.out-web.net/?p=847. the author
        Dennis Damen was working through a similar problem. Getting a unique
        list of images. His Get-BitmapHash opens each image, and creates a 
        hashcode of the contents. In testing it was pretty accurate as it 
        processed only the content of the image and no metadata.
        
        The next part of the script uses some code that I borrowed from here, 
        http://nicholasarmstrong.com/2010/02/exif-quick-reference/. Nicholas
        wrote up some quick PowerShell code to pull the Exif data from an image.
        I borrowed that code to pull out all the tags from the stored metadata.
        
        The syntax used was based in large part from what I got from Nicholas' site
        as well as what I read from the MSDN site regarding imaging in .Net. There
        is still a fair bit of magic involved in that code but in my limited testing
        it seemed to work well.
    .PARAMETER Photos
        This is a string that represents the path to where you've stored all your
        images. It can be a network path, a local path or you can leave it blank
        and it will pull images from the default pictures folder for the current user.
    .EXAMPLE
        .\Get-UniqueImages.ps1 -Photos "\\fs\gallery\"
        
        Description
        -----------
        This will search the network folder provided for JPEG images to process.
    .NOTES
        ScriptName: Get-UniqueImages.ps1
        Created By: Jeff Patton
        Date Coded: July 11, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
        
        This script relies on the Get-Bitmaphash function that is included in,
        http://scripts.patton-tech.com/browser/powershell/playground/EXIFFunctions.ps1.
        It needs to be in the same folder as this script.
        
        I'm only parsing for JPEG files, if you want to process other files change
        or remove the filter, in the PARAM or the initial FOREACH loop in the 
        Processing section of the script.
        
        This script does NOT remove/delete any EXIF data, it only reads it from 
        the image, and stores it in an object. There is a wealth of code out
        there that will show you how to remove it if that's what you're after.
    .LINK
        http://www.out-web.net/?p=847
    .LINK
        http://nicholasarmstrong.com/2010/02/exif-quick-reference/
    .LINK
        http://scripts.patton-tech.com/browser/powershell/playground/Get-UniqueImages.ps1
#>
Param
    (
    $Photos = (Get-ChildItem -Path "C:\Users\$($env:username)\Pictures" -Filter *.jpg -Recurse)
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
        . .\EXIFFunctions.ps1
        $HashedImages = @()
        $Images = @()
    }
Process
    {
        #
        # Process images and return the Fullname (path) and MD5 sum
        #
        foreach ($photo in (Get-ChildItem $photos -Filter *.jpg -Recurse))
        {
            $ThisHash = New-Object -TypeName PSObject -Property @{
                FullName = $photo.FullName
                Hash = Get-BitmapHash -FileName $photo.FullName
                }
            $HashedImages += $ThisHash
            }

        #
        # Sort the returned object to get only the unique hash codes
        #
        $HashedImages = $HashedImages |Sort-Object -Property Hash -Unique

        #
        # Process each image to pull out the EXIF tags and store them in an object
        #
        foreach ($photo in $HashedImages)
        {
            [System.Reflection.Assembly]::LoadWithPartialName("PresentationCore") > $null

            $filename = $photo.FullName
            $ImageFileName = ([System.IO.FileInfo]$filename).Name
            $ImageDirectoryName = ([System.IO.FileInfo]$filename).DirectoryName
            $ImageHash = $photo.Hash

            $stream = new-object System.IO.FileStream($filename, [System.IO.FileMode]::Open)
            $decoder = new-object System.Windows.Media.Imaging.JpegBitmapDecoder($stream,
                [System.Windows.Media.Imaging.BitmapCreateOptions]::PreservePixelFormat,
                [System.Windows.Media.Imaging.BitmapCacheOption]::None)

            $metadata = $decoder.Frames[0].Metadata

            $Tags = @()
            foreach ($tag in $ifd)
            {
                if ($tag -ne "/{ushort=34665}")
                {
                    $ThisTag = New-Object -TypeName PSObject -Property @{
                        TagType = "ifd"
                        TagName = $tag
                        TagValue = $metadata.GetQuery("/app1/ifd$($tag)")
                        }
                    $Tags += $ThisTag
                    }
                else
                {
                    $exif = $metadata.GetQuery("/app1/ifd$($tag)")
                    foreach ($eTag in $exif)
                    {
                        $ThisTag = New-Object -TypeName PSObject -Property @{
                            TagType = "exif"
                            TagName = $eTag
                            TagValue = $metadata.GetQuery("/app1/ifd/exif$($eTag)")
                            }
                        $Tags += $ThisTag
                        }
                    }
            }

            #
            # Work through each tag, and add only the ones listed below to the returned object
            #
            Foreach ($Tag in $Tags)
            {
                $myTag = ((($Tag.TagName).TrimStart("/{ushort=")).TrimEnd("}"))
                Switch ($myTag)
                {
                    271
                    {
                        # Make, the manufacturer of the equipment
                        $TagMake = $Tag.TagValue
                        }
                    272
                    {
                        # Model, the model name or model number of the equipment
                        $TagModel = $Tag.TagValue
                        }
                    274
                    {
                        # Orientation, the image orientation in terms of rows and columns
                        $TagOrientation = $Tag.TagValue
                        }
                    33434
                    {
                        # ExposureTime
                        $TagExposureTime = $Tag.TagValue
                        }
                    33437
                    {
                        # FNumber
                        $TagFNumber = $Tag.TagValue
                        }
                    34855
                    {
                        # ISOSpeedRatings
                        $TagISOSpeedRatings = $Tag.TagValue
                        }
                    36867
                    {
                        # DateTimeOriginal, Date and teim original image was generated
                        $TagDateTimeOriginal = $Tag.TagValue
                        }
                    37385
                    {
                        # Flash
                        $TagFlash = $Tag.TagValue
                        }
                    37386
                    {
                        # FocalLength, Lens focal length
                        $TagFocalLength = $Tag.TagValue
                        }
                    40962
                    {
                        # PixelXDimension, valid image width
                        $TagPixelXDimension = $Tag.TagValue
                        }
                    40963
                    {
                        # PixelYDimension, valid image height
                        $TagPixelYDimension = $Tag.TagValue
                        }
                    4097
                    {
                        # RelatedImageWidth, image width
                        $TagRelatedImageWidth = $Tag.TagValue
                        }
                    4098
                    {
                        # RelatedImageHeight, image height
                        $TagRelatedImageHeight = $Tag.TagValue
                        }
                    41728
                    {
                        # FileSource, indicates the image source
                        $TagFileSource = $Tag.TagValue
                        }
                    }
                }
            $ThisImage = New-Object -TypeName PSObject -Property @{
                ImageFileName = $ImageFileName
                ImageDirectoryName = $ImageDirectoryName
                Make = $TagMake
                Model = $TagModel
                Orientation = $TagOrientation
                ExposureTime = $TagExposureTime
                FNumber = $TagFNumber
                ISOSpeedRatings = $TagISOSpeedRatings
                DateTimeOriginal = $TagDateTimeOriginal
                Flash = $TagFlash
                FocalLength = $TagFocalLength
                PixelXDimension = $TagPixelXDimension
                PixelYDimension = $TagPixelYDimension
                RelatedImageWidth = $TagRelatedImageWidth
                RelatedImageHeight = $TagRelatedImageHeight
                FileSource = $TagFileSource
                Hash = $ImageHash
                }
            $Images += $ThisImage
            $stream.Dispose()
        }
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
        Return $Images
    }