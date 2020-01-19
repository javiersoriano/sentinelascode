param (
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$Workspace
)

#Adding AzSentinel module
Install-Module AzSentinel -Scope CurrentUser -Force
Import-Module AzSentinel

$solutions = Get-AzOperationalInsightsIntelligencePack -resourcegroupname $ResourceGroup -WorkspaceName $Workspace

if (($solutions | Where-Object Name -eq 'SecurityInsights').Enabled) {
    Write-Error "SecurityInsights solution is already enabled for workspace $Workspace"
    exit
}
else {
    Set-AzSentinel -WorkspaceName $Workspace -Confirm:$false
}