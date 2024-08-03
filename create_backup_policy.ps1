# Set your Azure details
$subscriptionId = "214erfdsg5e6ue56"
$resourceGroupName = "resource_group_name"
$vaultName = "vault_name"
$vmName = "vm_name"
$policyName = "DailyBackupPolicy"


Connect-AzAccount

Select-AzSubscription -SubscriptionId $subscriptionId

# Get the Recovery Services Vault
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName

# Set the vault context
Set-AzRecoveryServicesVaultContext -Vault $vault

# Define the backup policy
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name $policyName

if (-not $policy) {
    $policy = New-AzRecoveryServicesBackupProtectionPolicy `
        -Name $policyName `
        -BackupManagementType AzureVM `
        -WorkloadType AzureVM `
        -RetentionPolicy (New-AzRecoveryServicesBackupRetentionPolicyObject `
            -RetentionPolicyType LongTerm `
            -DailyRetention (New-AzRecoveryServicesBackupRetentionPolicyObject -RetentionDurationInDays 30)) `
        -SchedulePolicy (New-AzRecoveryServicesBackupSchedulePolicyObject `
            -ScheduleRunFrequency Daily `
            -ScheduleRunTimes ([DateTime]::ParseExact("03:00", "HH:mm", $null)))
}

# Get the VM backup item
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
$container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -FriendlyName $vmName -VaultId $vault.ID
$item = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM

# Enable backup
Enable-AzRecoveryServicesBackupProtection -Policy $policy -Item $item
