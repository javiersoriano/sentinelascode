# Scripts

## Alert Rules deployment script (CreateAnalyticsRulesAPI.ps1)

This script reads the config file in the AnalyticsRules folder and deploys its contents to a specific environment. The script will detect if the alert is brand new and needs to be created or if the alert is already active and just needs to be updated. Currently this script doesn't support attaching a playbook to an alert rule.

### Syntax 

`CreateAnalyticsRulesAPI.ps1 -TenantId <String> -ClientId <String> -ClientSecret <String> -SubscriptionId <String> -ResourceGroup <String> -Workspace <String> -RulesFile <String>`

## Hunting Rules deployment script

This script reads the config file in the HuntingRules folder and deploys its contents to a specific environment. The script will detect if the hunting rule is brand new and needs to be created or if it's already active and just needs to be updated.

`CreateHuntingRulesAPI.ps1 -Workspace <String> -RulesFile <String>`