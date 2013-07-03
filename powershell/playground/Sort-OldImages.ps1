Set-Location 'C:\Users\jspatton\SkyDrive\Old Images'
$Files = Get-ImagesFromWDS -LocalPath 'C:\Users\jspatton\SkyDrive\SkyDrive camera roll'
$Images = $Files.Tables[0]
$Lumia900 = @()
$sghi917 = @()
$sghi937 = @()
foreach ($Image in $Images.Rows)
{
    switch ($Image."SYSTEM.PHOTO.CAMERAMODEL")
    {
        "Nokia Lumia 900"
        {
            $Lumia900 += $Image
            }
        "SGH-I917"
        {
            $sghi917 += $Image
            }
        "SGH-i937"
        {
            $sghi937 += $Image
            }
        default
        {
            Move-Item $Image."SYSTEM.ITEMPATHDISPLAY" "$($PWD.Path)"
            }
        }
    }
$Lumia900 = $Lumia900 |Sort-Object -Property "System.Photo.DateTaken"
$sghi917 = $sghi917 |Sort-Object -Property "System.Photo.DateTaken"
$sghi937 = $sghi937 |Sort-Object -Property "System.Photo.DateTaken"

$Counter = 0
foreach ($Image in $Lumia900)
{
    $DestPath = $Image."SYSTEM.PHOTO.CAMERAMANUFACTURER"
    $SubFolder = $Image."SYSTEM.PHOTO.CAMERAMODEL"

    New-Item "$($PWD.Path)\$($DestPath)\$($SubFolder)" -ItemType Directory -Force |Out-Null
    $Filename = "WP_{0:D6}.jpg" -f $Counter

    Move-Item $Image."SYSTEM.ITEMPATHDISPLAY" "$($PWD.Path)\$($DestPath)\$($SubFolder)\$($Filename)"
    $Counter ++
    }

$Counter = 0
foreach ($Image in $sghi917)
{
    $DestPath = $Image."SYSTEM.PHOTO.CAMERAMANUFACTURER"
    $SubFolder = $Image."SYSTEM.PHOTO.CAMERAMODEL"

    New-Item "$($PWD.Path)\$($DestPath)\$($SubFolder)" -ItemType Directory -Force |Out-Null
    $Filename = "WP_{0:D6}.jpg" -f $Counter

    Move-Item $Image."SYSTEM.ITEMPATHDISPLAY" "$($PWD.Path)\$($DestPath)\$($SubFolder)\$($Filename)"
    $Counter ++
    }

$Counter = 0
foreach ($Image in $sghi937)
{
    $DestPath = $Image."SYSTEM.PHOTO.CAMERAMANUFACTURER"
    $DestPath = $Image."SYSTEM.PHOTO.CAMERAMANUFACTURER"
    $SubFolder = $Image."SYSTEM.PHOTO.CAMERAMODEL"

    New-Item "$($PWD.Path)\$($DestPath)\$($SubFolder)" -ItemType Directory -Force |Out-Null
    $Filename = "WP_{0:D6}.jpg" -f $Counter

    Move-Item $Image."SYSTEM.ITEMPATHDISPLAY" "$($PWD.Path)\$($DestPath)\$($SubFolder)\$($Filename)"
    $Counter ++
    }