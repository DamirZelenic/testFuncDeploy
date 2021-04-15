[cmdletbinding()]
param(
    [parameter()]
    [string]$FunctionName,
    [parameter()]
    [string]$FunctionResourceGroup
)

$identityId = (Get-AzFunctionApp -Name $FunctionName -ResourceGroupName $FunctionResourceGroup).IdentityPrincipalId

switch ($FunctionName)
{
    "dumyFuncDZdev"{
        New-AzRoleAssignment -ObjectId $identityId -RoleDefinitionName Contributor -Scope "/subscriptions/c5afa33c-e037-4c9d-8b04-746ac7bd16c5"
        break
    }
}