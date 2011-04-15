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
                This example shows the use of both the ScriptBlock and Counter parameters. This only works when the 
                Parameter comments are removed and the ScriptBlock variable and Return statement are commented out.
            .NOTES
                Your boss is working on a script that needs to halt execution for five seconds and then check a specific
                value. In the course of writing the script, your boss became concerned about the accuracy of using the 
                Start-Sleep Windows PowerShell cmdlet to halt execution for five seconds. The script is not going to be 
                used to control a space probe to mars, but it should be more accurate than a traditional egg timer. To 
                be assured of the accuracy of the Start-Sleep command, your boss asks that you measure the time the 
                Start-Sleep command takes to pause for five seconds. To check for variation, your boss wants you to take
                five measurements and provide the average time in milliseconds. 
                
                For the purposes of the ScriptingGames I have commented out the ScriptBlock variable, but in actuality 
                you *should* be able to pass this function a block of code to run and number of iterations and it will  
                return the proper value for you.
                
                Uncomment out the comments in the following lines:
                    61, 62, 72
                Comment out the following lines:
                    66, 67, 71
            .LINK
                http://blogs.technet.com/b/heyscriptingguy/archive/2011/04/15/the-2011-scripting-games-beginner-event-10-use-powershell-to-measure-time-to-complete-a-command.aspx
        #>
        
        Param
            (
                $Counter = 5 # ,
                # $ScriptBlock = 'Start-Sleep $Duration'
            )

        $Counter = 0..($Counter - 1)
        $Duration = 5
        $ScriptBlock = 'Start-Sleep $Duration'
        $TotalMilliseconds = ((Measure-Command {ForEach ($Count In $Counter) 
                             { Measure-Command {Invoke-Expression $ScriptBlock} }}).TotalMilliseconds / [int]$Counter.Count)

        Return "Average time of " + $Counter.Count + " runs of " + $Duration + " seconds is " + $TotalMilliseconds + " milliseconds."
        # Return "Average time of " + $Counter.Count + " runs of (" + $ScriptBlock + ") is " + $TotalMilliseconds + " milliseconds" 
    }