$filelist = Get-ChildItem $MyInvocation.Path -filter *.mp4 -recurse
$filelist += Get-ChildItem $MyInvocation.Path -filter *.avi -recurse
$filelist += Get-ChildItem $MyInvocation.Path -filter *.mpg -recurse
$filelist += Get-ChildItem $MyInvocation.Path -filter *.wmv -recurse
$filelist += Get-ChildItem $MyInvocation.Path -filter *.mov -recurse
 
$num = $filelist | measure
$filecount = $num.count

ForEach ($file in $filelist)
{
	if ($file -And !($file -like '*converted.mp4') -And $file.length -gt 10MB)
	{
		$oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
		$temporaryFile = $file.DirectoryName + "\" + $file.BaseName + "_temporary.mp4";
		$newfile = $file.DirectoryName + "\" + $file.BaseName + "_converted.mp4";
	 
		Write-Host "Processing - $oldfile"
		Write-Host "Writing to - $newfile"
		
		Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -ArgumentList "-i `"$oldfile`" -o `"$temporaryFile`" -Z `"Fast 1080p30`" -verbose=0" -Wait -NoNewWindow
		
		# Copy the original date to the converted video
		Start-Process "ffmpeg" -ArgumentList "-i `"$oldfile`" -i `"$temporaryFile`" -map 1 -map_metadata 0 -c copy `"$newfile`"" -Wait -NoNewWindow
		
		Remove-Item $temporaryFile
		
		$processed_files += "`n$oldfile"
	}
}

Write-Host "Succesfully converted all files:"
Write-Host $processed_files