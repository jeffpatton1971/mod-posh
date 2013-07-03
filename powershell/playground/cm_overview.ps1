<#

    Change Management Runbook
    -------------------------

    This will be a collection of functions that will be used to determine when
    a change happens on a given server. These will be triggered from a runbook
    on a System Center Orchestrator server.

    Overview
    --------

    1. Active Directory will be queried daily for a list of servers to process
    2. Each hour that list will be processed for changes
        a. Network info for each ipenabled nic
            1. IP
            2. Subnet
            3. Gateway
            4. DNS
            5. Suffix search order
        b. Hardware
            1. CPU's
                a. Speed
                b. Cores
            2. Ram
                a. Quantity
                b. Capacity
            3. Disks
                a. Size
                b. Used space
                c. Free space
        c. Operating System
            1. Version
            2. Service Pack Level
            3. Services
                a. Running
                b. Stopped
                c. Logon Account
            4. Processes
                a. Name
                b. Username
                c. Memory
                d. Threads
                e. Image Path Name
                f. Command Line
                g. PID
            5. Installed Features/Roles
        d. Applications
            1. Name
            2. Publisher
            3. Install Date
            4. Version
        e. Local Accounts
            1. Users
            2. Groups
            3. Group Membership
                a. Administrators
                b. Backup Operators
                c. Power Users
                d. Remote Desktop Users
    3. For each item scanned, if something has changed an alert is thrown in
       System Center Operations Manager. Additionally a changelog for each 
       server is appended to.

    Process
    -------

    Wanting to keep this as simple as possible we'll use .xml files as 
    opposed to a full fledged database. If it becomes a performance issue to
    work with text files, porting the code to use a database will be trivial.

    Every 24 hours a new servers.xml file will be created in the servers root
    folder from the AD query for servers. This file will contain the Name, 
    adspath, sid and date created. On the first query a CHANGELOG file will 
    also be created that will contain the intial list, and subsequent add's
    and delete's will be stored in the CHANGELOG.

    For each server discovered, a folder named after the server will be created
    in the servers root folder. An initial CHANGELOG file will be created that 
    will list the information above. Changes will be appended to this file as
    they are discovered. 
    
    For each item that is scanned an xml file will be created that will hold the
    current information for that item. On a newly discovered computer there will
    be no pre-existing information which will trigger the creation of the file.
    If the file exists it will be read into memory, and if there are differences
    between what is in memory and what is discovered an entry will be added to 
    the CHANGELOG, and an alert triggered in System Center Operations Manager.

    Requirements
    ------------

    1. A Windows 2008 R2 server to run from
    2. WinRM enabled on all servers
    3. Administrative Credentials to use
    4. Firewall rules to allow access to remote machines
#>