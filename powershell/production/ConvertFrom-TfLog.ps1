<#
 this will parse the error message from a terraform plan
 D:\CODE\terraform.exe plan -no-color 2> .\tf.log
#>
function ConvertFrom-TfLog {
 [cmdletbinding()]
 param(
  [string]$FilePath
 )
 try {
  $ErrorActionPreference = 'Stop';
  $Error.Clear();

  $Log = Get-Content -Path $FilePath;
  $Index = 0;

  foreach ($Line in $Log) {
   $Record = New-Object -TypeName psobject -Property @{'Type' = ''; 'Message' = ''; 'FileName' = ''; 'ModuleName' = ''; 'Variable' = ''; 'Details' = '' };
   if (!([string]::IsNullOrEmpty($Line))) {
    switch ($Line) {
     'Error: Duplicate module call' {
      $End = $Index + 7;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.ModuleName = $Entry[3].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[5] + $Entry[6] + $Entry[7]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Invalid block definition' {
      $End = $Index + 5;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      if ($Entry[3].Contains('variable')) {
       $Record.Variable = $Entry[3].Trim().Split(' ')[2].Trim();
      }
      if ($Entry[3].Contains('module')) {
       $Record.Variable = $Entry[3].Trim().Split(' ')[2].Trim();
      }
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Invalid expression' {
      $End = $Index + 5;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.Variable = $Entry[2].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[5] + " (" + $Entry[3].Split(":")[1].Trim() + ")").Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Invalid module instance name' {
      $End = $Index + 6;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.ModuleName = $Entry[3].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Invalid multi-line string' {
      $End = $Index + 8;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.Variable = $Entry[2].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[6] + $Entry[7] + $Entry[8]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Invalid resource name' {
      $End = $Index + 6;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.ModuleName = $Entry[3].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Invalid variable name' {
      $End = $Index + 6;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.Variable = $Entry[3].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Missing item separator' {
      $End = $Index + 6;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.Variable = $Entry[2].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Missing newline after argument' {
      $End = $Index + 5;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      if ($Entry[3].Contains('"')) {
       $Record.ModuleName = $Entry[3].Trim().Split('"')[1].Trim();
      }
      else {
       $Record.Variable = $Entry[3].Trim().Split('=')[1].Trim();
      }
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Missing required argument' {
      $End = $Index + 5;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.ModuleName = $Entry[3].Trim().Split(' ')[2].Trim();
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Unsupported argument' {
      $End = $Index + 6;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.ModuleName = $Entry[3].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     'Error: Variables not allowed' {
      $End = $Index + 6;
      $Entry = $Log[$Index..$End];
      $Record.Type = $Entry[0].Split(':')[0].Trim();
      $Record.Message = $Entry[0].Split(':')[1].Trim();
      $Record.FileName = $Entry[2].Trim().Split(' ')[1].Trim();
      $Record.Variable = $Entry[2].Trim().Split('"')[1].Trim();
      $Record.Details = ($Entry[5] + $Entry[6]).Trim();
      Write-Output $Record | Select-Object -Property 'type', 'message', 'filename', 'modulename', 'variable', 'details';
     }
     default
     {}
    }
   }
   $Index += 1;
  }
 }
 catch {
  Write-Output $Start
  Write-Output $End
  Write-Output $Entry
  throw $_;
 }
}