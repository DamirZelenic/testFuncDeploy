[cmdletbinding()]
param(
    [parameter()]
    [string]$FunctionName,
    [parameter()]
    [string]$FunctionResourceGroup
)

# Set RBAC for Managed Identities
# SPN needs User Access Administrator and Directory.Read.All (on old Azure AD Graph) permissions
$identityId = (Get-AzFunctionApp -Name $FunctionName -ResourceGroupName $FunctionResourceGroup).IdentityPrincipalId

switch ($FunctionName)
{
    "dumyFuncDZdev"{
        try
        {
            New-AzRoleAssignment -ObjectId $identityId -RoleDefinitionName Contributor -Scope "/subscriptions/c5afa33c-e037-4c9d-8b04-746ac7bd16c5" -ErrorAction stop
        }
        catch
        {
            Write-Host "$_"
        }
        break
    }
}