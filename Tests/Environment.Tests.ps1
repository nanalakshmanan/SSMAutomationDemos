$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Environment" {

    . "../Setup/Settings.ps1"
    $AllStacks = @($EmailLambdaStack, $LinuxInstanceStack, $WindowsInstanceStack, $SNSStack)

    $AllStacks  | % {
        $StackName = $_
        It "$StackName stack exists" {
            (Get-CFNStack -StackName $StackName | Foreach StackStatus).Value | Should be 'CREATE_COMPLETE' 
        }
    }

    It "There are 10 running EC2 instances" {
        (Get-EC2Instance | foreach Instances | foreach State | where code -eq 16).Count | Should Be 10
    }

    $AllDocs = @($BounceHostName, $RestartNodeWithApprovalDoc)

    $AllDocs | % {
        $DocName = $_
        It "$DocName document exists" {
            {Get-SSMDocument -Name $DocName} | Should -Not -Throw
        }
    }
}
