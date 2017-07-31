Remove-Variable directoryInfo
Remove-Variable directoryObject
Remove-Variable finalobject
Remove-Variable loopobject
Remove-Variable sortedObject
Remove-Variable uniqueDays
Clear-Host

$testPath = "C:\Users\joshp\Pictures\2017\" #this is the folder where the dated folders will be created
$path = "C:\Users\joshp\pictures\unsorted" #this is the path we will be grabbing objects to sort and move will be coming from
$directoryInfo = Get-ChildItem -Path $path #the actual act of gathing info on all the pbjects in the directory, not recursive
$finalObject = @() #instansiating the hashtable we will be storing file info in
$dateTime = Get-Date 
$runTime = $dateTime.ToShortTimeString()
$runDate = $dateTime.ToShortDateString() 

#creating a hastable with data, this will be saved as a CSV for each time this runs and is used to find the copy commands
Foreach($line in $directoryInfo) 
	{
  	$linedate = $line.CreationTime.ToShortDateString()
	$lineDateFormatted = $linedate.Replace('/','-')
	$MovePath = Join-Path $testPath $lineDateFormatted 
	$MovePath = Join-Path $MovePath $line.Name
	$LoopObject = New-Object PSObject @()            
  	$LoopObject | Add-Member -MemberType NoteProperty -Name "CreationDate" -Value $lineDateFormatted
	$LoopObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $line.Name
	$LoopObject	| Add-Member -MemberType NoteProperty -Name "FullPath" -Value $line.FullName
	$LoopObject	| Add-Member -MemberType NoteProperty -Name "MovePath" -Value $MovePath
	$LoopObject | Add-Member -MemberType NoteProperty -Name "RunDate" -Value $runDate
	$LoopObject | Add-Member -MemberType NoteProperty -Name "RunTime" -Value $runTime
	#$LoopObject
	$script:finalObject += $LoopObject
	}

#this section creates an array of unique dates from the hashtable
$sortedObject = $finalobject | Sort-Object CreationDate
$uniqueDays = $sortedObject|Select-Object CreationDate | Sort-Object -Unique CreationDate
$uniqueDays = $uniqueDays.CreationDate.Replace('/','-')

# This section Tests if a Particular date path already exists. if true it outputs a message, if false it creates the path 
foreach($Date in $uniquedays) {
	$loopDirectoryname = Join-Path $testPath $Date
		If( Test-Path -Path $loopDirectoryname ) 
			{
			Write-Host $loopDirectoryname " Path Exists" -BackgroundColor Black -ForegroundColor Red
			} 
		else 
			{
			New-Item -Path $loopDirectoryname -ItemType Directory -ErrorAction Inquire
			Write-Host $loopDirectoryname " Created Path " $loopDirectoryname -BackgroundColor Black -ForegroundColor Green
			}
								}

$logObject = $finalObject | Format-List
$logObject >> c:\Users\joshp\Desktop\MovePiclog.txt 


#from final object I plug the string in "MovePath" into the Copy or move command
Foreach ($lineitem in $finalObject)
	{
	Write-Host "I am going to attempt to copy from " $lineitem.FullPath " to " $lineitem.MovePath 
	Move-Item -Path $lineitem.FullPath -Destination $lineitem.MovePath -ErrorAction Inquire 
	}