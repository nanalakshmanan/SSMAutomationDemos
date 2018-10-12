[CmdletBinding()]
param(
)
. "./Settings.ps1"

$AllStacks = @($EmailLambdaStack, $LinuxInstanceStack, $WindowsInstanceStack, $SNSStack, $UnmanagedInstanceStack)
$AllDocs = @($BounceHostName, $RestartNodeWithApprovalDoc, $StartEC2InstanceDoc, $StartEC2WaitForRunningDoc, $CheckCTLoggingStatusDoc, $AuditCTLoggingDoc)
function Wait-Stack
{
	param(
		[string]
		$StackName
	)
	while(Test-CFNStack -StackName $StackName){
		Write-Verbose "Waiting for Stack $StackName to be deleted"
		Start-Sleep -Seconds 3
	}
}
$AllStacks | % {
	if (Test-CFNStack -StackName $_){
		Remove-CFNStack -StackName $_ -Force
	}
}

$AllStacks | % {
	Wait-Stack -StackName $_
}

$AllDocs | % {
	Remove-SSMDocument -Name $_ -Force
}

Get-SSMAssociationList | foreach AssociationId | %{Remove-SSMAssociation -AssociationId $_ -Force}