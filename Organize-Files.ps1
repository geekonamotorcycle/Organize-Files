# Organize-Files.ps1
# Version 0.9
# Designed for powershell 5.1
# Copyright 2017 - Joshua Porrata
# Not for business use without an inexpensive license, contatc 
# Localbeautytampabay@gmail.com for questions about a lisence 
# there is no warranty, this might destroy everything it touches. 
Function Read-Paths {
    Param
    (
        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        $Source,
        [Parameter(Mandatory = $False)]
        [AllowEmptyString()]
        $Destination
    )
 

    #Source logic
    if ($source -ne $null) {
        $testSource = Test-Path $Source
        Write-Host "Source: $testsource`n"
        $script:sourcePath = $Source
    }
    elseif ($source -eq $null) {
        $i = 1
        [boolean]$sourcePrompt = $true

        while ($sourcePrompt) {
            Write-Host "Enter Source Path [Attempt $i/3]" -ForegroundColor Green
            $inputSource = Read-Host  -ErrorAction 'SilentlyContinue' -InformationAction 'SilentlyContinue'
            $iSourceTest = Test-Path $inputSource 
            if ($iSourceTest) {
                Write-Host "The source path you entered Passed`n" -ForegroundColor Green
                $script:sourcePath = $inputSource
                $sourcePrompt = $False
            }
            else {
                $i++        
                Write-Host "The path could not be validated `n" -ForegroundColor Red
            }
            if ($i -gt 3) {
                write-host "Too Many Attempts, Contact your Systems Adminstrator for help" -ForegroundColor Red
                $script:runScript = $False
                exit
            }
        }
    }
            
    
    #Destination Logic
    If ($destination -ne $null) {
        $testdest = Test-Path $Destination
        Write-Host "Destination: $testDest`n"
        $script:destPath = $Destination
    }
    elseif ($Destination -eq $null) {
        [boolean]$destPrompt = $true
        $i = 1
        while ($destPrompt) {
            Write-Host "Enter Destination Path [Attempt $i/3]" -ForegroundColor Green
            $inputDest = Read-Host 
            $iDestTest = Test-Path -path $inputDest -ErrorAction 'SilentlyContinue'
            if ($iDestTest) {
                Write-Host "The Destination Path you entered Passed`n" -ForegroundColor Green
                $script:destPath = $inputDest
                $destPrompt = $False
            }
            else {
                $i++        
                Write-Host "The path could not be validated `n" -ForegroundColor Red
            }
            if ($i -gt 3) {
                write-host "Too Many Attempts, Contact your Systems Adminstrator for help" -ForegroundColor Red
                $script:runScript = $False
                exit
            }
        }
    }
}
Function Get-ObjectTable {
    Param(
        [Parameter(Mandatory = $false)]
        $getSourceHash = $false,
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [string]$fileTypeFilter,
        [Parameter(Mandatory = $True)]
        [string]$ScanPath
    )
 
    $i = 1
    $time = Get-Date
    $scanObject = @()

    #First, use get-childitems using $Script:sourcePath from Read-paths function to enumerate all of the objects in the table
    Write-Host "`Looking for files in`n$ScanPath"
    $sourceObject = Get-ChildItem  -recurse -File -Path $ScanPath 

    #Second-Check if the source path is empty, if it is break the script. 
    $sourceCount = $sourceObject.count
    If ($sourceCount -eq 0) {
        write-host "Source Path is empty." -ForegroundColor red
        $Script:runscript = $false
        exit
    }
    Write-Host "`nExtracting File details and sorting..`n" -ForegroundColor green
    #third for each item, select just the required propteries
    foreach ($File in $sourceObject) {
        $cDateToString = $file.CreationTime
        $cDateToShort = $cDateToString.ToShortDateString()
        $cDateFormated = $cDateToShort.replace('/', '-')
        #Include: CreationTime, FileName, Size, FileType, FullPath.
        $LoopObject = New-Object PSObject @()
        $LoopObject | Add-Member -MemberType NoteProperty -Name "CreationTime" -Value $file.CreationTime -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "CDate" -Value $cDateFormated -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $file.name -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "Size" -Value $file.Length -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "FileType" -Value $file.extension -ErrorVariable $ObjectTableError
        $LoopObject | Add-Member -MemberType NoteProperty -Name "FullPath" -Value $file.FullName -ErrorVariable $ObjectTableError
        #include: If (getSourceHash - eq $true)Then Get the file Hash and add it, if $false then output "NotCalculated"
        If ($getSourceHash) {
            $fileHash = Get-FileHash -Path $File.FullName -Algorithm SHA1 -ErrorVariable $hasherror
            $LoopObject | Add-Member -MemberType NoteProperty -Name "Hash" -Value $fileHash.Hash -ErrorVariable $ObjectTableError
        }
        Else {
            $LoopObject | Add-Member -MemberType NoteProperty -Name "Hash" -Value "NotCalculated" -ErrorVariable $ObjectTableError
        }
        #Include: ScriptTime
        $LoopObject | Add-Member -MemberType NoteProperty -Name "LoopTime" -Value $time -ErrorVariable $ObjectTableError
        #Add them to a loop collector
        $scanObject += $LoopObject
    
        If ($watchWork) {
            Write-Progress -Activity "Scanning Objects " -status "Scanned $i of $sourceCount "  -percentComplete ($i / $sourceCount) -ErrorVariable $progressError
        }
        $i++
    }
    #Have the loop collectory select only unique filenames. I know its inelegant, but it will prevent writing over objects
    $scanObject = $scanObject | Sort-Object filename -Unique -Descending
    
    
    #Output $Script:directoryObject For the Move-Objects  function
    $script:directoryObject = $scanObject 
    if ($scanObject -ne $null) {
       
        $creationTimesObject = $scanobject.CreationTime
        Write-Host "Selecting files by creation time 1/4" -ForegroundColor Green
        $shortDateString = $creationTimesObject.ToShortDateString()
        Write-Host "Converting to String 2/4" -ForegroundColor Green
        $uniqueStrings = $shortDateString | Select-Object -Unique
        Write-Host "Selecting only unique Dates 3/4" -ForegroundColor Green
        $script:uniquedays = $uniqueStrings.replace('/', '-')
        Write-Host "Creating names compatible with Windows File system 4/4 `n" -ForegroundColor Green
    }
    else {
        Write-Host "Something has gone wrong, while scanning for unique dates a null object was found. Exiting Script" -ForegroundColor Red
        $Script:runscript = $false
        Exit
    }
}
function Set-Paths {
    Param(
        #testMode = Not Mandatory - default is True - actually makes the paths
        [Parameter(Mandatory = $false)]
        [boolean]
        $testMode = $true,
        #Uniquedays = Mandatory - a string opbject of unique dates, passed in from find-uniquedays
        [Parameter(Mandatory = $true)]
        $uniqueDays,
        #DestPath = Mandatory - A String, root path that subfolders will be created in
        [Parameter(Mandatory = $true)]
        [string]
        $destinationpath

    )
    $time = Get-Date
    $MadePaths = @()
    If ($testMode) {
        #Write-Host "TestMode is $testMode"
        foreach ($date in $UniqueDays) {
            #join DestPath and uniuedate
            $newDestPath = Join-Path $destinationpath $date
            Write-Host "`nRunning in Test Mode, Calculated path is $newDestPath" -ForegroundColor Green
        }
    }
    else {
        #Write-Host "`nI am Not in Test mode!" -ForegroundColor Red
        #Write-Host "$destinationpath" -ForegroundColor Green
        #Write-Host "$uniquedays`n" -ForegroundColor Green
        foreach ($date in $uniquedays) {
            $loopobject = New-Object PSObject @()
            #join DestPath and uniuedate
            $newDestPath = Join-Path $destinationpath $date
            #Checking if the path exists.
            $testDestPath = Test-Path $newDestPath
            #if exists then write to log
            if ($testDestPath) {
                #Include: Fullpath, existence(Yes), was not create (Already exists), Time
                $loopobject | Add-Member -MemberType NoteProperty -Name "Path" -Value $newDestPath
                $loopobject | Add-Member -MemberType NoteProperty -Name "Exists" -Value "Yes"
                $loopobject | Add-Member -MemberType NoteProperty -Name "Created" -Value "No"
                $loopobject | Add-Member -MemberType NoteProperty -Name "Time" -Value $time
                #$loopobject | Add-Member -MemberType NoteProperty -Name "" -Value AAAA
                $MadePaths += $loopobject
            }
            else {
                New-Item -Path $newDestPath -ItemType Directory -InformationAction 'silent'
                $newPathTest = Test-Path -Path $newDestPath
                #Include: Fullpath
                $loopobject | Add-Member -MemberType NoteProperty -Name "Path" -Value $newDestPath
                
                If ($newPathTest) {
                    #include: If creation was successful
                    $loopobject | Add-Member -MemberType NoteProperty -Name "Exists" -Value "Yes"            
                }
                else {
                    $loopobject | Add-Member -MemberType NoteProperty -Name "Exists" -Value "No"
                }

                if ($newPathTest) {
                    $loopobject | Add-Member -MemberType NoteProperty -Name "Created" -Value "Yes"            
                }
                else {
                    $loopobject | Add-Member -MemberType NoteProperty -Name "Created" -Value "Fail"
                }
                $loopobject | Add-Member -MemberType NoteProperty -Name "Time" -Value $time
                $MadePaths += $loopobject
            }
        }
    }
    #Pay no mind to this thing below here, will be useful later
    #$script:newPaths = $MadePaths
}
function Set-Files {
    Param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory = $true,
            ParameterSetName = "Array Object for Directory Information",
            HelpMessage = "This needs to be an array with a bunch of information")]
        [Alias("Directory Input Array")]
        [ValidateNotNullOrEmpty()]
        $directoryObject,
        $testmode = $true,
        $showResults = $true,
        $copyMove = $true
    )
    class loopObject {
        [String]$Filename
        [string]$Filetype
        [String]$Fullpath
        [string]$NewPath
        [string]$copyMove
        [string]$Success
        [string]$Time
        [String]$Size
        [string]$Hash
    }
    
    $time = Get-Date
    $time = $time.ToShortDateString()

    if ($testmode) {
        $i = 1
        $liveObject = @()
        $objectCount = $directoryObject.Count
        foreach ($file in $directoryObject) {
            $newPath = Join-Path $destPath $file.cdate 
            $properties = @{FileName = $file.filename; Size = $file.size; Filetype = $file.filetype; Fullpath = $file.FullPath; NewPath = $newPath; Time = $time; Hash = $file.hash}
            $properties += @{CopyMove = "TestMode"; Success = "TestMode"; }
            $loopObject = New-Object loopObject -Property $properties
            $liveObject += $loopObject
            Write-Progress -Activity "Creating Table" -Status "Working" -percentComplete ($i / $objectCount * 100)
            $i++
        }
        if ($showResults) {
            $liveObject | Out-GridView -Title "test Object"
            $liveObject | ConvertTo-Csv -NoTypeInformation > Oraganize_Files_Test.csv 
        }
    }
    else {
        Write-Host "Attempting to Move or Copy Files`n" -ForegroundColor Green
        $i = 1
        $liveObject = @()
        $objectCount = $directoryObject.Count
        foreach ($file in $directoryObject) {
            $newPath = Join-Path $destPath $file.cdate 
            $newPath = Join-Path $newPath $file.fileName
            $properties = @{FileName = $file.filename; Size = $file.size; Filetype = $file.filetype; Fullpath = $file.FullPath; NewPath = $newPath; Time = $time; Hash = $file.hash}
            if ($copyMove) {
                $properties += @{CopyMove = "Copy"}
                Copy-Item -Path $file.Fullpath -Destination $newPath -Force -InformationAction 'silent'
                $copytest = Test-Path -Path $newPath
                if ($copytest) {
                    $properties += @{Success = "Yes"}
                }
                else {
                    $properties += @{Success = "No"}
                }
            }
            else {
                $properties += @{CopyMove = "Move"}
                Move-Item -Path $file.Fullpath -Destination $newPath -Force -InformationAction 'silent'
                $copytest = Test-Path -Path $newPath
                if ($copytest) {
                    $properties += @{Success = "Yes"}
                }
                else {
                    $properties += @{Success = "No"}
                }
            }
            $loopObject = New-Object loopObject -Property $properties
            $liveObject += $loopObject
            Write-Progress -Activity "Copying or moving Files" -Status "Working" -PercentComplete ($i / $objectCount * 100 )
            $i++
        }
        if ($showResults) {
            $liveObject | Out-GridView -Title "Live Object Output"
            $liveObject | ConvertTo-Csv -NoTypeInformation > Organize_Files_Results.csv
        }
    } 
}
Function Copyright {
    Write-Host "`n***********************************************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Copyright 2017, Joshua Porrata**************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***This program is not free for business use***" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Contact me at localbeautytampabay@gmail.com*" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***for a cheap business license****************" -BackgroundColor Black -ForegroundColor DarkGreen
    Write-Host "***Donations are wholeheartedly accepted ******" -BackgroundColor Black -ForegroundColor Red
    Write-Host "***accepted @ www.paypal.me/lbtpa**************" -BackgroundColor Black -ForegroundColor Red
    Write-Host "***********************************************`n" -BackgroundColor Black -ForegroundColor DarkGreen
}


Clear-Host
Copyright
#Readpaths 
#grabs the source and destination root Paths and checks that they 
#exist before Passing them on.
#ReadPaths can be interactive or you can add some parameters here
# -Source will specify a source path Make sure its valid!
# -destination will specify a destination path Make sure its valid!
#Output: $sourcePath - the root of the folder we will be scanning.
#OutPut: $destPath - The root of the folder files will be headed to 
Read-Paths
#Get-objectTable 
#scans a path and gathers the required information.
# -getSourceHash $true will calculate an SHA1 hash for every file
# -scanpath is the path we will be scanning and is mandatory
# -fileTypeFilter is not implimented yet, its there to remind me to impliment it
#Output: $uniquedays - a string array of unique dates in MM-DD-YYYY format
#Output: $directoryObject - an array of data needed for the set-files Function
Get-ObjectTable -ScanPath $sourcePath 
#Set-Paths 
#Firsts takes $uniquedays from Get-ObjectTable and tests if the paths exist if
#They do not exist the function will attampt to create them.
# -TestMode = $true(default) Just runs a test, outputs the unique fodlers
# -destinationPath can be entered manualy or grab from read-paths $destpath
# -uniqueDays should come from Get-ObjectTable $uniquedays
# There is no output, Just action
Set-Paths -destinationpath $destPath -uniqueDays $uniqueDays -testMode $false
#Set-Files
#attempts to copy or move the files 
# -directoryObject Comes from Get-ObjectTable named $directoryObject
# -Testmode($True) No changes are made, but a simulated results table is created
#   Usefule if you want a list to work with manually
# -copyMove($true) $True = Copy; $False = Move
# -showResults ($true) outputs CSV files in the same folder the command is run 
#   from. Also runs out-gridview on the final hoshtables
# There is no output
set-files  -directoryobject $directoryObject -testmode $false -copyMove $true
#Ignore this line and the one below
#Copy-Item -Path c:\tes\8-23-2017\*.* -Destination C:\unsorte
Copyright