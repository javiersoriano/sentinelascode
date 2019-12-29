param (
    [string]
    $workspaceName,
    [string]
    $AlertRulesFile
)

Install-Module AzSentinel -Scope CurrentUser -Force

Import-Module AzSentinel

Import-AzSentinelAlertRule -WorkspaceName $workspaceName -SettingsFile $AlertRulesFile