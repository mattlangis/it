function Invoke-Download {
    param (
        [string]$url,
        [string]$destination
    )

    $downloadResult = Start-BitsTransfer $url -Destination $destination

    switch ($downloadResult.JobState) {
        'Transferred' {
            Complete-BitsTransfer -BitsJob $downloadResult
            break
        }
        'Error' {
            throw 'Error downloading'
        }
    }
} 

$downloadFolder = "$HOME\Downloads\"

# Decrypt ApiToken and ConfigId
echo 'Downloading teamviewer encrypted settings'
$teamviewerEncryptedSettingsUri = "https://raw.githubusercontent.com/mattlangis/it/main/settings/teamviewer"
$teamviewerEncryptedPath = Join-Path $downloadFolder "teamviewer-encrypted"
Invoke-Download -url $teamviewerEncryptedSettingsUri -destination $teamviewerEncryptedPath
$encryptedTeamviewerStr = Get-Content $teamviewerEncryptedPath -raw
$decryptedTeamviewerJson = Unprotect-CmsMessage -Content $encryptedTeamviewerStr | ConvertFrom-Json

$apiToken = $decryptedTeamviewerJson.full.apiKey
$tvConfigId = $decryptedTeamviewerJson.full.configId

# Download teamviewer
echo 'Downloading teamviewer MSI'
$teamviewerUri = "https://dl.teamviewer.com/download/version_15x/TeamViewer_MSI64.zip"
$teamviewerFileName = "Teamviewer-Setup-Matt"
$teamviewerPath = Join-Path $downloadFolder $teamviewerFileName

Invoke-Download -url $teamviewerUri -destination "$teamviewerPath.zip"

# Unzip
echo 'Unzip Teamviewer setup'
Expand-Archive -Path "$teamviewerPath.zip" -DestinationPath "$teamviewerPath"
$teamviewerSetupPath = Join-Path $teamviewerPath 'Full\TeamViewer_Full.msi'

# Start install 
echo 'Start installation'
$exeArgs = "/i '$teamviewerSetupPath' /qn APITOKEN=$apiToken CUSTOMCONFIGID=$tvConfigId ASSIGNMENTOPTIONS= --grant-easy-access"
Start-Process -Wait msiexec.exe $teamviewerPath -ArgumentList $exeArgs

# Clean file
echo 'Cleaning'
$teamviewerEncryptedPath | Remove-Item