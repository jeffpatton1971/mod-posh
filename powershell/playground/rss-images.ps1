$url = 'http://themeserver.microsoft.com/default.aspx?p=Bing&c=Desktop&m=en-US'
#$url = 'http://www.nasa.gov/rss/lg_image_of_the_day.rss'
$web = New-Object System.Net.WebClient
$scRss = $web.DownloadString($url)
[xml]$feed = $scRss
$resources = $feed.GetElementsByTagName('item')
foreach ($item in $resources)
{
    (get-date($item.pubDate) -format MMM-dd-yyy)
    if ((get-date($item.pubDate) -format MMM-dd-yyy) -eq (Get-Date -format MMM-dd-yyy))
    {
        $item.title
        $item.pubDate
        $item.enclosure.url
        }
    }