Import-Module AzSentinel

#Variables
$Workspace = "sorisentinel"
$RulesPath = "..\AnalyticsRules\analytics-rules.json"
$rules = Get-Content -Raw -Path "$RulesPath" | ConvertFrom-Json

foreach ($rule in $rules.analytics) {
    Write-Host "$($rule.displayName)"

    $content = Get-AzSentinelAlertRule -WorkspaceName $Workspace -RuleName $rule.displayName

    $item = @{ }

    if ($content) {
        Write-Host "Rule $($rule.displayName) exists in Azure Sentinel. Updating if needed..."

        New-AzSentinelAlertRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Description $rule.description -Severity $rule.severity -Enabled $rule.enabled -Query $rule.query -QueryFrequency $rule.queryFrequency -QueryPeriod $rule.queryPeriod -TriggerOperator $rule.triggerOperator -TriggerThreshold $rule.triggerThreshold -SuppressionDuration $rule.suppressionDuration -SuppressionEnabled $rule.suppressionEnabled -Tactics $rule.tactics

    }
    else {
        Write-Host "Rule $($rule.displayName) doesn't exist in Azure Sentinel. Creating new rule..."


        New-AzSentinelAlertRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Description $rule.description -Severity $rule.severity -Enabled $rule.enabled -Query $rule.query -QueryFrequency $rule.queryFrequency -QueryPeriod $rule.queryPeriod -TriggerOperator $rule.triggerOperator -TriggerThreshold $rule.triggerThreshold -SuppressionDuration $rule.suppressionDuration -SuppressionEnabled $rule.suppressionEnabled -Tactics $rule.tactics
    }
}


