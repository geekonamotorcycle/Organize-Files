#Just making sure there isnt any old data
if($testpath -ne $null)
	{
	Remove-Variable date -ErrorAction SilentlyContinue
	Remove-Variable datetime -ErrorAction SilentlyContinue
	Remove-Variable directoryInfo -ErrorAction SilentlyContinue
	Remove-Variable directorylog -ErrorAction SilentlyContinue
	Remove-Variable directoryloopcollector -ErrorAction SilentlyContinue
	Remove-Variable directoryObject -ErrorAction SilentlyContinue
	Remove-Variable displaylogs -ErrorAction SilentlyContinue
	Remove-Variable formateddate -ErrorAction SilentlyContinue
	Remove-Variable infologobject -ErrorAction SilentlyContinue
	Remove-Variable infoobject -ErrorAction SilentlyContinue
	Remove-Variable line -ErrorAction SilentlyContinue
	Remove-Variable linedate -ErrorAction SilentlyContinue
	Remove-Variable linedateformatted -ErrorAction SilentlyContinue
	Remove-Variable lineitem -ErrorAction SilentlyContinue
	Remove-Variable logobject -ErrorAction SilentlyContinue
	Remove-Variable loopcollector -ErrorAction SilentlyContinue
	Remove-Variable loopdirectoryname -ErrorAction SilentlyContinue
	Remove-Variable loopobject -ErrorAction SilentlyContinue
	Remove-Variable movepath -ErrorAction SilentlyContinue
	Remove-Variable path -ErrorAction SilentlyContinue
	Remove-Variable rundate -ErrorAction SilentlyContinue
	Remove-Variable runtime -ErrorAction SilentlyContinue
	Remove-Variable sortedObject -ErrorAction SilentlyContinue
	Remove-Variable testpath -ErrorAction SilentlyContinue
	Remove-Variable uniquedays -ErrorAction SilentlyContinue
	Remove-Variable uniquedirectorycollector -ErrorAction SilentlyContinue
	Remove-Variable copyormove -ErrorAction SilentlyContinue
	Remove-Variable errorlog -ErrorAction SilentlyContinue
	Remove-Variable movelogobject -ErrorAction SilentlyContinue
	Remove-Variable i -ErrorAction SilentlyContinue
	}
	
Clear-Host


$testPath = "C:\Users\joshp\desktop\test\" #this is the folder where the dated folders will be created it must already exist
$path = "C:\Users\joshp\Pictures\Unsorted\" #this is the path we will be grabbing objects to sort and move will be coming from

$directoryInfo = Get-ChildItem -Path $path -Recurse -file #the actual act of gathing info on all the pbjects in the directory.

$directoryObject = @() #instansiating the hashtable we will be storing file info in
$dateTime = Get-Date 
$runTime = $dateTime.ToShortTimeString()
$runDate = $dateTime.ToShortDateString() 
$tableCreationError

# 1 Does not show logs, 2 just creates log files on the desktop
[boolean]$displayLogs = 1
# 1 moves, 0 copies
[boolean]$copyOrMove = 0

$uniqueDirectoryCollector = @()
$moveLoopCollector = @()

#creating a hastable with data, this will be saved as a CSV for each time this runs and is used to find the copy commands
Foreach($line in $directoryInfo) 
	{
	  	$linedate = $line.CreationTime.ToShortDateString()
		$lineDateFormatted = $linedate.Replace('/','-')
		$MovePath = Join-Path $testPath $lineDateFormatted 
		$MovePath = Join-Path $MovePath $line.Name
		$formatedDate = $line.CreationTime.ToShortDateString() 
		$formatedDate = $formatedDate.Replace('/','-')
		
		#Array Block
		$LoopObject = New-Object PSObject @()            
	  	$LoopObject | Add-Member -MemberType NoteProperty -Name "CreationDate" -Value $formatedDate -ErrorVariable $tableCreationError
		$LoopObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $line.Name -ErrorVariable $tableCreationError
		$LoopObject | Add-Member -MemberType NoteProperty -Name "Length" -Value $line.Length -ErrorVariable $tableCreationError
		$LoopObject | Add-Member -MemberType NoteProperty -Name "FileType" -Value $line.Extension -ErrorVariable $tableCreationError
		$LoopObject	| Add-Member -MemberType NoteProperty -Name "FullPath" -Value $line.FullName -ErrorVariable $tableCreationError
		$LoopObject	| Add-Member -MemberType NoteProperty -Name "MovePath" -Value $MovePath -ErrorVariable $tableCreationError
		$LoopObject | Add-Member -MemberType NoteProperty -Name "RunDate" -Value $runDate -ErrorVariable $tableCreationError
		$LoopObject | Add-Member -MemberType NoteProperty -Name "RunTime" -Value $runTime -ErrorVariable $tableCreationError
		#$LoopObject
		$script:directoryObject += $LoopObject
	}

#this section creates an array of unique dates from the hashtable
$sortedObject = $directoryObject | Sort-Object CreationDate
$sortedObject = $sortedObject|Select-Object CreationDate | Sort-Object -Unique CreationDate
$uniqueDays = $sortedObject.CreationDate.Replace('/','-')


# This section Tests if a Particular date path already exists. if true it outputs a message, if false it creates the path 
foreach($Date in $uniquedays) 
	{
	
		$loopDirectoryName = Join-Path $testPath $Date -ErrorAction Inquire -ErrorVariable $directoryCreationError
			If( Test-Path -Path $loopDirectoryName ) 
				{ 	
					Write-Host $loopDirectoryName " Path Exists" -BackgroundColor Black -ForegroundColor Red
					
					#Array Block
					$directoryLoopCollector = New-Object PSObject @()
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "Path" -Value $loopDirectoryname -ErrorVariable $directoryCreationError
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "DirectoryExists" -Value "Yes" -ErrorVariable $directoryCreationError
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "DirectoryCreated" -Value "No" -ErrorVariable $directoryCreationError
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "RunDate" -Value $runDate -ErrorVariable $directoryCreationError
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "RunTime" -Value $runTime -ErrorVariable $directoryCreationError
					$uniqueDirectoryCollector += $directoryLoopCollector
				} 
			else 
				{
					New-Item -Path $loopDirectoryName -ItemType Directory -ErrorAction Inquire -ErrorVariable $directoryCreationError 
					Write-Host $loopDirectoryname " Created Path " $loopDirectoryname -BackgroundColor Black -ForegroundColor Green
					
					#Array Block
					$directoryLoopCollector = New-Object PSObject @()
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "Path" -Value $loopDirectoryname -ErrorVariable $directoryCreationError
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "DirectoryExists" -Value "No" -ErrorVariable $directoryCreationError
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "DirectoryCreated" -Value "Yes" -ErrorVariable $directoryCreationError
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "RunDate" -Value $runDate -ErrorVariable $directoryCreationError
					$directoryLoopCollector | Add-Member -MemberType NoteProperty -Name "RunTime" -Value $runTime -ErrorVariable $directoryCreationError
					$uniqueDirectoryCollector += $directoryLoopCollector
				}
	}


# from final object I plug the string in "MovePath" into the Copy or move command
if ($copyOrMove -eq $False)
	{
		$i = 1
		Foreach ($lineitem in $directoryObject)
			{
						Write-Host $i " of " $directoryObject.Count  " I am going to attempt to COPY from " $lineitem.FullPath " to " $lineitem.MovePath 
			Copy-Item -Path $lineitem.FullPath -Destination $lineitem.MovePath -ErrorAction Inquire 
									
			#Array Block
			$CopyloopObject = New-Object PSObject @()            
			$CopyloopObject | Add-Member -MemberType NoteProperty -Name "CreationDate" -Value $lineitem.CreationDate -ErrorVariable $tableCreationError
			$CopyloopObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $lineitem.FileName -ErrorVariable $tableCreationError
			$CopyloopObject  | Add-Member -MemberType NoteProperty -Name "Length" -Value $lineitem.Length -ErrorVariable $tableCreationError
			$CopyloopObject | Add-Member -MemberType NoteProperty -Name "FileType" -Value $lineitem.FileType -ErrorVariable $tableCreationError
			$CopyloopObject | Add-Member -MemberType NoteProperty -Name "FullPath" -Value $lineitem.FullPath -ErrorVariable $tableCreationError
			$CopyloopObject	| Add-Member -MemberType NoteProperty -Name "MovePath" -Value $lineitem.MovePath -ErrorVariable $tableCreationError
			
			#Checking to see if the copy worked
			if (Test-Path -Path $lineitem.MovePath)	
				{
				$CopyloopObject | Add-Member -MemberType NoteProperty -Name "CopySuccess" -Value "Yes" -ErrorVariable $tableCreationError
				}
			else	
				{
				$CopyloopObject | Add-Member -MemberType NoteProperty -Name "CopySuccess" -Value "No" -ErrorVariable $tableCreationError
				}
			$CopyloopObject | Add-Member -MemberType NoteProperty -Name "RunDate" -Value $lineitem.runDate -ErrorVariable $tableCreationError
			$CopyloopObject | Add-Member -MemberType NoteProperty -Name "RunTime" -Value $lineitem.runTime -ErrorVariable $tableCreationError
			#collect the harsh table data 
			$moveLoopCollector += $CopyloopObject
			$i++
			Write-Progress -Activity "Copying files... " -status "Copied $i of $directoryObject.Count " $directoryObject.Count  -percentComplete ($i / $directoryObject.Count*100)
			}
	}
else 
	{
	$i = 1
	Foreach ($lineitem in $directoryObject)
		{	
		Write-Host $i " of " $directoryObject.Count " I am going to attempt to MOVE from " $lineitem.FullPath " to " $lineitem.MovePath 
		#Move-Item -Path $lineitem.FullPath -Destination $lineitem.MovePath -ErrorAction Inquire 
									
		#Array Block
		$MoveloopObject = New-Object PSObject @()            
		$MoveloopObject | Add-Member -MemberType NoteProperty -Name "CreationDate" -Value $lineitem.CreationDate -ErrorVariable $tableCreationError
		$MoveloopObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $lineitem.FileName -ErrorVariable $tableCreationError
		$MoveloopObject  | Add-Member -MemberType NoteProperty -Name "Length" -Value $lineitem.Length -ErrorVariable $tableCreationError
		$MoveloopObject | Add-Member -MemberType NoteProperty -Name "FileType" -Value $lineitem.FileType -ErrorVariable $tableCreationError
		$MoveloopObject | Add-Member -MemberType NoteProperty -Name "FullPath" -Value $lineitem.FullPath -ErrorVariable $tableCreationError
		$MoveloopObject	| Add-Member -MemberType NoteProperty -Name "MovePath" -Value $lineitem.MovePath -ErrorVariable $tableCreationError
		
		#Checking to see if the copy worked
		if (Test-Path -Path $lineitem.MovePath)	
			{
			$MoveloopObject | Add-Member -MemberType NoteProperty -Name "MoveSuccess" -Value "Yes" -ErrorVariable $tableCreationError
			}
		else	
			{
			$MoveloopObject | Add-Member -MemberType NoteProperty -Name "MoveSuccess" -Value "No" -ErrorVariable $tableCreationError
			}
		$MoveloopObject | Add-Member -MemberType NoteProperty -Name "RunDate" -Value $lineitem.runDate -ErrorVariable $tableCreationError
		$MoveloopObject | Add-Member -MemberType NoteProperty -Name "RunTime" -Value $lineitem.runTime -ErrorVariable $tableCreationError
		#collect the harsh table data 
		$moveLoopCollector += $MoveloopObject
		$i++
		Write-Progress -Activity "Moving files... " -status "Moved $i of $directoryObject.Count " $directoryObject.Count  -percentComplete ($i / $directoryObject.Count*100)
		}
	}
	
#Log creation and display 
If ($displayLogs -eq $false) 
	{
	#Displaying stuff
	$directoryLog = $uniqueDirectoryCollector | Out-GridView -ErrorAction Inquire
	$moveLogObject = $moveLoopCollector | Out-GridView -ErrorAction Inquire
	#creating te logs
	$moveLogObject = $moveLoopCollector
	$moveLogObject | Out-File ~\desktop\MovePicsLog.txt -Force -ErrorAction Inquire
	$directoryLog = $uniqueDirectoryCollector 
	$directoryLog | Out-File ~\desktop\MovePicsDirectoryLog.txt -Force -ErrorAction Inquire
	
	<#dont need these anymore
	$infoObject = $directoryObject | Out-GridView -ErrorAction Inquire
	$errorLog = $Error | Out-GridView
	#creating Log files 
	$infologObject = $directoryObject 
	$infologObject > c:\Users\joshp\Desktop\MovePiclog-Info.txt 
	#$directoryLog = $uniqueDirectoryCollector
	
	$errorLog = $Error 
	$Error > c:\Users\joshp\Desktop\MovePiclog-Errors.txt
	#>	

	}
Else
	{
	$moveLogObject = $moveLoopCollector
	$moveLogObject | Out-File ~\desktop\MovePicsLog.txt -Force -ErrorAction Inquire
	$directoryLog = $uniqueDirectoryCollector 
	$directoryLog | Out-File ~\desktop\MovePicsDirectoryLog.txt -Force -ErrorAction Inquire
	<# Dont need this anymore
	$infologObject = $directoryObject 
	$infologObject > c:\Users\joshp\Desktop\MovePiclog-Info.txt 
	$directoryLog = $uniqueDirectoryCollector
	$directoryLog > c:\Users\joshp\Desktop\MovePiclog-DirectoryCreation.txt
	#>
	}	
	
