# Scripts

## Sentinel artifacts deployment script (DeploySentinelArtifacts.ps1)

This script deploys Analytics Rules, Automation Rules, Watchlists, Hunting Queries and Parsers. The script takes all the ARM templates in the specified folder and deploys them into the given resource group and workspace.

### Syntax

`CreatePlaybooks.ps1 -ResourceGroup <String> -Folder <String> -Workspace <String>`

## Playbooks deployment script (CreatePLaybooks.ps1)

Takes all the json files within a folder (specified as PlaybooksFolder parameter) and deploys them as playbooks (Logic Apps).

### Syntax

`CreatePlaybooks.ps1 -ResourceGroup <String> -PlaybooksFolder <String>`

## Workbooks deployment script (CreateWorkbooks.ps1)

Takes all the json files within a folder (specified as WorkbooksFolder) and deploys them as Workbooks in the Sentinel environment. Parameter *WorkbookSourceId* is needed to specify that the workbook will be located inside Sentinel environment. If no parameter is provided, the workbook will be deployed in Azure Monitor.

### Syntax

`CreateWorkbooks.ps1 -ResourceGroup <String> -WorkbooksFolder <String> -WorkbookSourceId <String>`

## Install Sentinel script (InstallSentinel.ps1)

Reads configuration file under Onboard folder and installs SecurityInsights (Sentinel) solution where required.

### Syntax

`InstallSentinel.ps1 -OnboardingFile <String>`