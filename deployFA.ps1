[cmdletbinding()]
param(
    [parameter()]
    [string]$FunctionName,
    [parameter()]
    [string]$FunctionResourceGroup,
    [parameter()]
    [string]$Location,
    [parameter()]
    [string]$AppSettingsJSON,
    [parameter()]
    [string]$IdentityType
)

<#
Write-Host "$($AppSettingsJSON.GetType().FullName)"
Write-Host "App Settings pre $($AppSettingsJSON)"
$AppSettingsJSON = $AppSettingsJSON.Replace('***','')
Write-Host "App Settings replace $($AppSettingsJSON)"
#>


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
    try
    {
        $sa = Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $FunctionResourceGroup -ErrorAction stop
    }
    catch
    {
        Write-Host "$_"
    }

    if ($null -eq $sa)
    {
        while(-not(Get-AzStorageAccountNameAvailability -Name $StorageAccountName).NameAvailable)
        {
            $i++
            $StorageAccountName = "$($StorageAccountName)$i"

        }
        Write-Host "Storageaccount does not exist yet, creating"
        $SAParameters = @{
            Name              = $StorageAccountName
            ResourceGroupName = $FunctionResourceGroup
            SkuName           = "Standard_LRS"
            Location          = $Location
        }
        New-AzStorageAccount @SAParameters
    }
    $appSettings = $AppSettingsJSON | ConvertFrom-Json -AsHashtable

    Write-Host "App Settings post $($appSettings)"

    if (!$appSettings -or $appSettings -eq "")
    {
        $FAParameters = @{
            Name               = $FunctionName
            ResourceGroupName  = $FunctionResourceGroup
            StorageAccountName = $StorageAccountName
            Location           = $location
            Runtime            = "PowerShell"
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
            AppSetting        = $appSettings
        }
    }
    $Function = New-AzFunctionApp @FAParameters

    Write-Host $Function

    Update-AzFunctionApp -Name $FunctionName -ResourceGroupName $FunctionResourceGroup -IdentityType $IdentityType
}
