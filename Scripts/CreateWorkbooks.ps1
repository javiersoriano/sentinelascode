param(
    [Parameter(Mandatory=$true)]$resourceGroup,
    [Parameter(Mandatory=$true)]$workbooksFolder,
    [Parameter(Mandatory=$true)]$workbookSourceId
)

Write-Host "Folder is: $($workbooksFolder)"

$armTemplateFiles = Get-ChildItem -Path $workbooksFolder -Filter *.json

Write-Host "Files are: " $armTemplateFiles

foreach ($armTemplate in $armTemplateFiles) {
        $filePath = Join-Path $workbooksFolder $armTemplate
        New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $filePath -workbookSourceId $workbookSourceId 
}