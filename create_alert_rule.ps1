# Set your Azure details
$subscriptionId = "dwerbny879n8jodn"
$resourceGroupName = "resource_group_name"
$vmName = "vm_name"
$actionGroupName = "CPUAlertActionGroup"
$actionGroupShortName = "CPUAlert"
$alertRuleName = "HighCPUAlert"
$email = "ankitkumar578@gmail.com"

Connect-AzAccount

# Set the subscription
Select-AzSubscription -SubscriptionId $subscriptionId

# Get the VM resource ID
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
$resourceId = $vm.Id

# Create an Action Group
$actionGroup = New-AzActionGroup -ResourceGroupName $resourceGroupName -Name $actionGroupName -ShortName $actionGroupShortName -ReceiverEmail $email

# Create the alert rule
$metricAlertCriteria = New-AzMetricAlertRuleV2Criteria -MetricName "Percentage CPU" -TimeAggregation Average -Operator GreaterThan -Threshold 80
$metricAlertRule = New-AzMetricAlertRuleV2 -ResourceGroupName $resourceGroupName -Name $alertRuleName -TargetResourceId $resourceId -WindowSize 00:05:00 -Frequency 00:01:00 -ActionGroupId $actionGroup.Id -Criteria $metricAlertCriteria -Severity 3
