Function Get-AverageRunTime
    {
        <#
            .SYNOPSIS
                Return the average time in milliseconds it takes a command to run.
            .DESCRIPTION
                This function returns the average time in milliseconds for a command to run over several iterations. 
                Simply pass in the number of iterations, and the script block you wish to test.
            .PARAMETER Counter
                A number representing how many times to time the block.
            .PARAMETER ScriptBlock
                A valid cmdlet or block of code for example:
                
                Start-Sleep 5
                Get-Process
                Get-WmiObject win32_bios -ComputerName server01
            .EXAMPLE
                Get-AverageRunTime
                Average time of 5 runs of 5 seconds is 5005.9882 milliseconds.
                
                Description
                -----------
                An example showing the function running with no parameters.
            .EXAMPLE
                Get-AverageRunTime -Counter 3
                Average time of 3 runs of 5 seconds is 5006.80143333333 milliseconds.
                
                Description
                -----------
                An example showing the function with a different counter value.
            .EXAMPLE
                Get-AverageRunTime -Counter 5 -ScriptBlock "Start-Sleep 3"
                Average time of 5 runs of (Start-Sleep 3) is 3008.26246 milliseconds
                
                Description
                -----------
                This example shows the use of both the ScriptBlock and Counter parameters.
            .NOTES
            .LINK
                https://code.google.com/p/mod-posh/wiki/PerformanceTesting#Get-AverageRunTime
        #>
        
        Param
            (
                $Counter = 5 ,
                $ScriptBlock = 'Start-Sleep 5'
            )

        $Counter = 0..($Counter - 1)
        $TotalMilliseconds = (
            (Measure-Command {ForEach ($Count In $Counter) 
            { Measure-Command {Invoke-Expression $ScriptBlock} }}).TotalMilliseconds / [int]$Counter.Count)

        Return "Average time of " + $Counter.Count + " runs of (" + $ScriptBlock + ") is " `
                + $TotalMilliseconds + " milliseconds" 
    }
