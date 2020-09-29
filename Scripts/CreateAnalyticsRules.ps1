param(
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$RulesFile
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force
Import-Module AzSentinel

#Name of the Azure DevOps artifact
$artifactName = "RulesFile"

#Build the full path for the analytics rule file
$artifactPath = Join-Path $env:Pipeline_Workspace $artifactName 
$rulesFilePath = Join-Path $artifactPath $RulesFile

try {
    Import-AzSentinelAlertRule -WorkspaceName $Workspace -SettingsFile $rulesFilePath
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Error "Rule import failed with message: $ErrorMessage" 
}