$teamviewerUri = "https://get.teamviewer.com/6v5i2ut"
$teamviewerPath = "$HOME/Downloads/Teamviewer-Setup-Matt.exe"

$downloadResult = Start-BitsTransfer $teamviewerUri -Destination $teamviewerPath

switch ($downloadResult.JobState) {
    'Transferred' {
        Complete-BitsTransfer -BitsJob $downloadResult
        break
    }
    'Error' {
        throw 'Error downloading'
    }
}

$exeArgs = '/S /norestart'

Start-Process -Wait $teamviewerPath -ArgumentList $exeArgs