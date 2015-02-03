Function Get-RegistryValue
{
    <#
        .SYNOPSIS
            This function method enumerates the values of the given subkey or returns the data value for a named value 
        .DESCRIPTION
            Registry subkeys group entries with related information, and it is often useful to display that related 
            information. Unfortunately, this is not necessarily a straightforward procedure; after all, you cannot read 
            a registry value unless you use the appropriate method. But how can you call the appropriate method if you 
            do not know the data type of the value being read?
            
            The majority of registry values that hold useful information for a system administrator are made up of either 
            alphanumeric characters (REG_SZ) or numbers (REG_DWORD). String values in the registry are often clearly 
            interpretable words, such as the name of a component manufacturer.

            This function allows you to return a list of values in a given key and then using that information you can
            easily use this function to get the specific data you are after.
        .PARAMETER Hive
            A registry tree, also known as a hive, that contains the SubKeyName path
        .PARAMETER SubKeyName
            A path that contains the named values to be enumerated
        .PARAMETER ValueName
            A named value whose data value you are retrieving. Specify an empty string to get the default named value
        .PARAMETER ValueType
            This is the type of data to be returned
        .PARAMETER ComputerName
            The name of a remote computer to query, the default is localhost
        .EXAMPLE
            Get-RegistryValue -Hive HKEY_LOCAL_MACHINE -SubKeyName "SOFTWARE\Microsoft\Internet Explorer" -ValueName "Version" -ValueType String


            __GENUS          : 2
            __CLASS          : __PARAMETERS
            __SUPERCLASS     : 
            __DYNASTY        : __PARAMETERS
            __RELPATH        : 
            __PROPERTY_COUNT : 2
            __DERIVATION     : {}
            __SERVER         : 
            __NAMESPACE      : 
            __PATH           : 
            ReturnValue      : 0
            sValue           : 9.11.9600.17498
            PSComputerName   : 

            Description
            -----------
            This example shows getting the version value from the internet explorer registry
            key.
        .EXAMPLE
            Get-RegistryValue -Hive HKEY_LOCAL_MACHINE -SubKeyName "SOFTWARE\Microsoft\Internet Explorer"


            __GENUS          : 2
            __CLASS          : __PARAMETERS
            __SUPERCLASS     :
            __DYNASTY        : __PARAMETERS
            __RELPATH        :
            __PROPERTY_COUNT : 3
            __DERIVATION     : {}
            __SERVER         :
            __NAMESPACE      :
            __PATH           :
            ReturnValue      : 0
            sNames           : {Version, svcKBFWLink, svcVersion, svcUpdateVersion...}
            Types            : {1, 1, 1, 1...}
            PSComputerName   :

            Description
            -----------
            This example shows how to list all the values in a given key, simply omit the ValueName param.
        .NOTES
            FunctionName : Get-RegistryValue
            Created by   : jspatton
            Date Coded   : 02/03/2015 09:48:47
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/RegistryLibrary#Get-RegistryValue
        .LINK
            https://msdn.microsoft.com/en-us/library/aa390440(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa390445(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa390455(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa390458(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa390788(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa390388(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [ValidateSet("HKEY_CLASSES_ROOT","HKEY_CURRENT_USER","HKEY_LOCAL_MACHINE","HKEY_USERS","HKEY_CURRENT_CONFIG","HKEY_DYN_DATA")]
        [string]$Hive,
        [string]$SubKeyName,
        [string]$ValueName,
        [ValidateSet("DWORD","QWORD","String","MultiString","ExpandedString","Binary")]
        [string]$ValueType,
        [string]$ComputerName = "."
        )
    Begin
    {
        switch ($Hive)
        {
            "HKEY_CLASSES_ROOT"
            {
                [uint32]$hDefKey = 2147483648;
                }
            "HKEY_CURRENT_USER"
            {
                [uint32]$hDefKey = 2147483649;
                }
            "HKEY_LOCAL_MACHINE"
            {
                [uint32]$hDefKey = 2147483650;
                }
            "HKEY_USERS"
            {
                [uint32]$hDefKey = 2147483651;
                }
            "HKEY_CURRENT_CONFIG"
            {
                [uint32]$hDefKey = 2147483653;
                }
            "HKEY_DYN_DATA"
            {
                [uint32]$hDefKey = 2147483654;
                }
            }
        [string]$sSubKeyName = $SubKeyName;
        [string]$sValueName = $ValueName;
        }
    Process
    {
        $StandardRegistryProvider = [wmiclass]"\\$($ComputerName)\root\cimv2:StdRegProv";
        switch ($ValueType)
        {
            "DWORD"
            {
                $rValue = $StandardRegistryProvider.GetDWORDValue($hDefKey,$sSubKeyName,$sValueName);
                }
            "QWORD"
            {
                $rValue = $StandardRegistryProvider.GetQWORDValue($hDefKey,$sSubKeyName,$sValueName);
                }
            "String"
            {
                $rValue = $StandardRegistryProvider.GetStringValue($hDefKey,$sSubKeyName,$sValueName);
                }
            "MultiString"
            {
                $rValue = $StandardRegistryProvider.GetMultiStringValue($hDefKey,$sSubKeyName,$sValueName);
                }
            "ExpandedString"
            {
                $rValue = $StandardRegistryProvider.GetExpandedStringValue($hDefKey,$sSubKeyName,$sValueName);
                }
            "Binary"
            {
                $rValue = $StandardRegistryProvider.GetBinaryValue($hDefKey,$sSubKeyName,$sValueName);
                }
            default
            {
                $rValue = $StandardRegistryProvider.EnumValues($hDefKey, $sSubKeyName);
                }
            }
        }
    End
    {
        return $rValue;
        }
    }
Function Set-RegistryValue
{
    <#
        .SYNOPSIS
            This function sets the data value for a named value
        .DESCRIPTION
            Changing the values of registry entries is a common registry management task. The most challenging 
            aspect of that task is determining which entries you need to change, and to which values they must 
            be changed. After you have this information, you must choose the appropriate Registry Provider 
            methods for making the change.

            This function allows you to do this by simply choosing the appropriate ValueType on the command line
        .PARAMETER Hive
            A registry tree, also known as a hive, that contains the SubKeyName path
        .PARAMETER SubKeyName
            A path that contains the named values to be enumerated
        .PARAMETER ValueName
            A named value whose data value you are retrieving. Specify an empty string to get the default named value
        .PARAMETER ValueType
            This is the type of data to be returned
        .PARAMETER Value
            The value to be stored in the key
        .PARAMETER ComputerName
            The name of a remote computer to query, the default is localhost
        .EXAMPLE
            Set-RegistryValue -Hive HKEY_LOCAL_MACHINE -SubKeyName "SOFTWARE\Test" -ValueName "testing" -ValueType String -Value "tval"


            __GENUS          : 2
            __CLASS          : __PARAMETERS
            __SUPERCLASS     :
            __DYNASTY        : __PARAMETERS
            __RELPATH        :
            __PROPERTY_COUNT : 1
            __DERIVATION     : {}
            __SERVER         :
            __NAMESPACE      :
            __PATH           :
            ReturnValue      : 0
            PSComputerName   :


        .NOTES
            FunctionName : Set-RegistryValue
            Created by   : jspatton
            Date Coded   : 02/03/2015 10:50:52
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/RegistryLibrary#Set-RegistryValue
        .LINK
            https://msdn.microsoft.com/en-us/library/aa393286(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa393297(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa393590(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa393299(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa393465(v=vs.85).aspx
        .LINK
            https://msdn.microsoft.com/en-us/library/aa393600(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [ValidateSet("HKEY_CLASSES_ROOT","HKEY_CURRENT_USER","HKEY_LOCAL_MACHINE","HKEY_USERS","HKEY_CURRENT_CONFIG","HKEY_DYN_DATA")]
        [string]$Hive,
        [string]$SubKeyName,
        [string]$ValueName,
        [ValidateSet("DWORD","QWORD","String","MultiString","ExpandedString","Binary")]
        [string]$ValueType,
        $Value,
        [string]$ComputerName = "."
        )
    Begin
    {
        switch ($Hive)
        {
            "HKEY_CLASSES_ROOT"
            {
                [uint32]$hDefKey = 2147483648;
                }
            "HKEY_CURRENT_USER"
            {
                [uint32]$hDefKey = 2147483649;
                }
            "HKEY_LOCAL_MACHINE"
            {
                [uint32]$hDefKey = 2147483650;
                }
            "HKEY_USERS"
            {
                [uint32]$hDefKey = 2147483651;
                }
            "HKEY_CURRENT_CONFIG"
            {
                [uint32]$hDefKey = 2147483653;
                }
            "HKEY_DYN_DATA"
            {
                [uint32]$hDefKey = 2147483654;
                }
            }
        [string]$sSubKeyName = $SubKeyName;
        [string]$sValueName = $ValueName;
        }
    Process
    {
        $StandardRegistryProvider = [wmiclass]"\\$($ComputerName)\root\cimv2:StdRegProv";
        switch ($ValueType)
        {
            "DWORD"
            {
                [uint32]$uValue = $Value;
                $rValue = $StandardRegistryProvider.SetDWORDValue($hDefKey,$sSubKeyName,$sValueName,$uValue);
                }
            "QWORD"
            {
                [uint64]$uValue = $Value;
                $rValue = $StandardRegistryProvider.SetQWORDValue($hDefKey,$sSubKeyName,$sValueName,$uValue);
                }
            "String"
            {
                [string]$sValue = $Value;
                $rValue = $StandardRegistryProvider.SetStringValue($hDefKey,$sSubKeyName,$sValueName,$sValue);
                }
            "MultiString"
            {
                [string[]]$sValue = $Value;
                $rValue = $StandardRegistryProvider.SetMultiStringValue($hDefKey,$sSubKeyName,$sValueName,$sValue);
                }
            "ExpandedString"
            {
                [string]$sValue = $Value;
                $rValue = $StandardRegistryProvider.SetExpandedStringValue($hDefKey,$sSubKeyName,$sValueName,$sValue);
                }
            "Binary"
            {
                [uint8array]$uValue = $Value;
                $rValue = $StandardRegistryProvider.SetBinaryValue($hDefKey,$sSubKeyName,$sValueName,$uValue);
                }
            }
        }
    End
    {
        return $rValue;
        }
    }
Function New-RegistryKey
{
    <#
        .SYNOPSIS
            This function creates a subkey in the specified tree
        .DESCRIPTION
            You rarely need to create a registry subkey. However, in some circumstances 
            the solution to a problem - as described in a Knowledge Base article or a 
            security bulletin - requires the addition of a subkey. If you need to create 
            a subkey on a large number of computers, the best solution might very well be 
            a script. After all, a single script can be used to create the subkey on every 
            computer affected by the problem.
        .PARAMETER Hive
            A registry tree, also known as a hive, that contains the SubKeyName path
        .PARAMETER SubKeyName
            A path that contains the named values to be enumerated
        .PARAMETER ComputerName
            The name of a remote computer to query, the default is localhost
        .EXAMPLE
            New-RegistryKey -Hive HKEY_LOCAL_MACHINE -SubKeyName "SOFTWARE\Test"


            __GENUS          : 2
            __CLASS          : __PARAMETERS
            __SUPERCLASS     :
            __DYNASTY        : __PARAMETERS
            __RELPATH        :
            __PROPERTY_COUNT : 1
            __DERIVATION     : {}
            __SERVER         :
            __NAMESPACE      :
            __PATH           :
            ReturnValue      : 0
            PSComputerName   :
        .NOTES
            FunctionName : New-RegistryKey
            Created by   : jspatton
            Date Coded   : 02/03/2015 11:00:40
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/RegistryLibrary#New-RegistryKey
        .LINK
            https://msdn.microsoft.com/en-us/library/aa389385(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [ValidateSet("HKEY_CLASSES_ROOT","HKEY_CURRENT_USER","HKEY_LOCAL_MACHINE","HKEY_USERS","HKEY_CURRENT_CONFIG","HKEY_DYN_DATA")]
        [string]$Hive,
        [string]$SubKeyName,
        [string]$ComputerName = "."
        )
    Begin
    {
        switch ($Hive)
        {
            "HKEY_CLASSES_ROOT"
            {
                [uint32]$hDefKey = 2147483648;
                }
            "HKEY_CURRENT_USER"
            {
                [uint32]$hDefKey = 2147483649;
                }
            "HKEY_LOCAL_MACHINE"
            {
                [uint32]$hDefKey = 2147483650;
                }
            "HKEY_USERS"
            {
                [uint32]$hDefKey = 2147483651;
                }
            "HKEY_CURRENT_CONFIG"
            {
                [uint32]$hDefKey = 2147483653;
                }
            "HKEY_DYN_DATA"
            {
                [uint32]$hDefKey = 2147483654;
                }
            }
        [string]$sSubKeyName = $SubKeyName;
        }
    Process
    {
        $StandardRegistryProvider = [wmiclass]"\\$($ComputerName)\root\cimv2:StdRegProv";
        $rValue = $StandardRegistryProvider.CreateKey($hDefKey,$sSubKeyName);
        }
    End
    {
        return $rValue;
        }
    }
Function Remove-RegistryKey
{
    <#
        .SYNOPSIS
            This function deletes a subkey in the specified tree
        .DESCRIPTION
            This function deletes a subkey in the specified tree
        .PARAMETER Hive
            A registry tree, also known as a hive, that contains the SubKeyName path
        .PARAMETER SubKeyName
            A path that contains the named values to be enumerated
        .PARAMETER ComputerName
            The name of a remote computer to query, the default is localhost
        .EXAMPLE
            Remove-RegistryKey -Hive HKEY_LOCAL_MACHINE -SubKeyName "SOFTWARE\Test"


            __GENUS          : 2
            __CLASS          : __PARAMETERS
            __SUPERCLASS     :
            __DYNASTY        : __PARAMETERS
            __RELPATH        :
            __PROPERTY_COUNT : 1
            __DERIVATION     : {}
            __SERVER         :
            __NAMESPACE      :
            __PATH           :
            ReturnValue      : 0
            PSComputerName   :
        .NOTES
            FunctionName : Remove-RegistryKey
            Created by   : jspatton
            Date Coded   : 02/03/2015 11:41:58
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/RegistryLibrary#Remove-RegistryKey
        .LINK
            https://msdn.microsoft.com/en-us/library/aa389869(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [ValidateSet("HKEY_CLASSES_ROOT","HKEY_CURRENT_USER","HKEY_LOCAL_MACHINE","HKEY_USERS","HKEY_CURRENT_CONFIG","HKEY_DYN_DATA")]
        [string]$Hive,
        [string]$SubKeyName,
        [string]$ComputerName = "."
        )
    Begin
    {
        switch ($Hive)
        {
            "HKEY_CLASSES_ROOT"
            {
                [uint32]$hDefKey = 2147483648;
                }
            "HKEY_CURRENT_USER"
            {
                [uint32]$hDefKey = 2147483649;
                }
            "HKEY_LOCAL_MACHINE"
            {
                [uint32]$hDefKey = 2147483650;
                }
            "HKEY_USERS"
            {
                [uint32]$hDefKey = 2147483651;
                }
            "HKEY_CURRENT_CONFIG"
            {
                [uint32]$hDefKey = 2147483653;
                }
            "HKEY_DYN_DATA"
            {
                [uint32]$hDefKey = 2147483654;
                }
            }
        [string]$sSubKeyName = $SubKeyName;
        }
    Process
    {
        $StandardRegistryProvider = [wmiclass]"\\$($ComputerName)\root\cimv2:StdRegProv";
        $rValue = $StandardRegistryProvider.DeleteKey($hDefKey,$sSubKeyName);
        }
    End
    {
        return $rValue;
        }
    }
Function Get-RegistryKey
{
    <#
        .SYNOPSIS
            This function enumerates the subkeys for a path
        .DESCRIPTION
            In some instances, useful configuration information is stored as the names 
            of a set of subkeys. In a case such as this, simply listing the names of 
            the subkeys provides useful information. 

            This function enables you to return the subkeys of a registry key or subkey. 
            Note that the function returns only the immediate subkeys of a key or subkey; 
            it does not return any subkeys that might be contained within those top-level 
            subkeys. 
        .PARAMETER Hive
            A registry tree, also known as a hive, that contains the SubKeyName path
        .PARAMETER SubKeyName
            A path that contains the named values to be enumerated
        .PARAMETER ComputerName
            The name of a remote computer to query, the default is localhost
        .EXAMPLE
            Get-RegistryKey -Hive HKEY_LOCAL_MACHINE -SubKeyName "SOFTWARE"


            __GENUS          : 2
            __CLASS          : __PARAMETERS
            __SUPERCLASS     :
            __DYNASTY        : __PARAMETERS
            __RELPATH        :
            __PROPERTY_COUNT : 2
            __DERIVATION     : {}
            __SERVER         :
            __NAMESPACE      :
            __PATH           :
            ReturnValue      : 0
            sNames           : {Classes, Clients, IM Providers, Intel...}
            PSComputerName   :
        .NOTES
            FunctionName : Get-RegistryKey
            Created by   : jspatton
            Date Coded   : 02/03/2015 11:52:49
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/RegistryLibrary#Get-RegistryKey
        .LINK
            https://msdn.microsoft.com/en-us/library/aa390387(v=vs.85).aspx
    #>
    [CmdletBinding()]
    Param
        (
        [ValidateSet("HKEY_CLASSES_ROOT","HKEY_CURRENT_USER","HKEY_LOCAL_MACHINE","HKEY_USERS","HKEY_CURRENT_CONFIG","HKEY_DYN_DATA")]
        [string]$Hive,
        [string]$SubKeyName,
        [string]$ComputerName = "."
        )
    Begin
    {
        switch ($Hive)
        {
            "HKEY_CLASSES_ROOT"
            {
                [uint32]$hDefKey = 2147483648;
                }
            "HKEY_CURRENT_USER"
            {
                [uint32]$hDefKey = 2147483649;
                }
            "HKEY_LOCAL_MACHINE"
            {
                [uint32]$hDefKey = 2147483650;
                }
            "HKEY_USERS"
            {
                [uint32]$hDefKey = 2147483651;
                }
            "HKEY_CURRENT_CONFIG"
            {
                [uint32]$hDefKey = 2147483653;
                }
            "HKEY_DYN_DATA"
            {
                [uint32]$hDefKey = 2147483654;
                }
            }
        [string]$sSubKeyName = $SubKeyName;
        }
    Process
    {
        $StandardRegistryProvider = [wmiclass]"\\$($ComputerName)\root\cimv2:StdRegProv";
        $rValue = $StandardRegistryProvider.EnumKey($hDefKey,$sSubKeyName);
        }
    End
    {
        return $rValue;
        }
    }

Export-ModuleMember *