param(
    [Parameter(Mandatory=$true)]$resourceGroup,
    [Parameter(Mandatory=$true)]$workbooksFolder,
    [Parameter(Mandatory=$true)]$workbookSourceId
)

Write-Host "Folder is: $($workbooksFolder)"

$armTemplateFiles = Get-ChildItem -Path $workbooksFolder -Filter *.json

Write-Host "Files are: " $armTemplateFiles

foreach ($armTemplate in $armTemplateFiles) {
        New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate -workbookSourceId $workbookSourceId 
}