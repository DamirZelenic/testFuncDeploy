[cmdletbinding()]
param(
    [parameter()]
    [string]$FunctionName,
    [parameter()]
    [string]$FunctionResourceGroup,
    [parameter()]
    [string]$Location,
    [string]$AppSettingsJSON
)

$Function = Get-AzFunctionApp -Name $FunctionName -ResourceGroupName $FunctionResourceGroup
if ($Function)
{
    Write-Host "FunctionApp $Function already exists"
}
else
{
    Write-Host "Resource does not exist, creating"
    if ($null -eq (Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq "$FunctionResourceGroup" } ) )
    {
        Write-Host "Resourcegroup does not exist yet, creating"
        New-AzResourceGroup -Name $FunctionResourceGroup -Location $Location
    }
    $StorageAccountName = "sa$FunctionName".ToLower()
    if ($null -eq (Get-AzStorageAccount | Where-Object { $_.Name -eq $StorageAccountName } ))
    {
        Write-Host "Storageaccount does not exist yet, creating"
        $SAParameters = @{
            Name              = $StorageAccountName
            ResourceGroupName = $FunctionResourceGroup
            SkuName           = "Standard_LRS"
            Location          = $Location
        }
        New-AzStorageAccount @SAParameters
    }
    $appSettings = $appSettingsJSON | ConvertFrom-Json -AsHashtable

    if (!$appSettings -or $AppSettings -eq "")
    {
        $FAParameters = @{
            Name               = $FunctionName
            ResourceGroupName  = $FunctionResourceGroup
            StorageAccountName = $StorageAccountName
            Location           = $location
            Runtime            = "PowerShell"
            IdentityType       = "SystemAssigned"
        }
    }
    else
    {
        $FAParameters = @{
            Name               = $FunctionName
            ResourceGroupName  = $FunctionResourceGroup
            StorageAccountName = $StorageAccountName
            Location           = $location
            Runtime            = "PowerShell"
            IdentityType       = "SystemAssigned"
            AppSettings        = $appSettings
        }
    }
    $Function = New-AzFunctionApp @FAParameters
}
