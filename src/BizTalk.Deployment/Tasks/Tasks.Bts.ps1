#region Copyright & License

# Copyright © 2012 - 2021 François Chabot
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#endregion

Set-StrictMode -Version Latest

. $PSScriptRoot\..\BtsBinding\BtsBinding.functions.ps1
. $PSScriptRoot\..\BtsResource\BtsResource.functions.ps1

. $PSScriptRoot\Tasks.BtsApplication.ps1
. $PSScriptRoot\Tasks.BtsBindings.ps1
. $PSScriptRoot\Tasks.BtsMaps.ps1
. $PSScriptRoot\Tasks.BtsOrchestrations.ps1
. $PSScriptRoot\Tasks.BtsPipelineComponents.ps1
. $PSScriptRoot\Tasks.BtsPipelines.ps1
. $PSScriptRoot\Tasks.BtsProcessDescriptors.ps1
. $PSScriptRoot\Tasks.BtsSchemas.ps1

# Synopsis: Deploy a Microsoft BizTalk Server Application
task Deploy-BizTalkApplication `
    Undeploy-BizTalkApplication, `
    Add-BizTalkApplication, `
    Deploy-BizTalkArtifacts, `
    Start-Application

# Synopsis: Patch a Microsoft BizTalk Server Application's Binaries
task Patch-BizTalkApplication `
    Deploy-BizTalkArtifacts, `
    Start-Application, `
    Restart-BizTalkHostInstances

# Synopsis: Undeploy a Microsoft BizTalk Server Application
task Undeploy-BizTalkApplication -If { -not $SkipUninstall } `
    Stop-Application, `
    Undeploy-BizTalkArtifacts, `
    Remove-BizTalkApplication, `
    Restart-BizTalkHostInstances

# Synopsis: Deploy all Microsoft BizTalk Server Artifacts
task Deploy-BizTalkArtifacts `
    Deploy-Schemas, `
    Deploy-Maps, `
    Deploy-PipelineComponents, `
    Deploy-Pipelines, `
    Deploy-Orchestrations, `
    Deploy-Bindings, `
    Register-ProcessDescriptors, `
    Deploy-FileAdapterFolders

# Synopsis: Undeploy all Microsoft BizTalk Server Artifacts
task Undeploy-BizTalkArtifacts -If { -not $SkipUninstall } `
    Undeploy-FileAdapterFolders, `
    Unregister-ProcessDescriptors, `
    Undeploy-Orchestrations, `
    Undeploy-Pipelines, `
    Undeploy-PipelineComponents, `
    Undeploy-Maps, `
    Undeploy-Schemas

# Synopsis: Restart the Microsoft BizTalk Server Host Instances of either a BizTalk Application or the BizTalk Group
task Restart-BizTalkHostInstances -If { -not $SkipSharedResources } `
    Restart-BizTalkHostInstancesForApplication, `
    Restart-BizTalkHostInstancesForGroup

# Synopsis: Restart the Microsoft BizTalk Server Host Instances of a BizTalk Application
task Restart-BizTalkHostInstancesForApplication -If { Get-TaskResourceGroup -Name Bindings | Test-Any } {
    Get-TaskResourceGroup -Name Bindings | ForEach-Object -Process {
        $arguments = ConvertTo-BindingBasedCmdletArguments -Binding $_
        Get-ApplicationHosts @arguments | ForEach-Object -Process {
            Get-BizTalkHost -Name $_ | Where-Object -FilterScript { Test-BizTalkHost -Host $_ -Type InProcess } | Get-BizTalkHostInstance | ForEach-Object -Process {
                Write-Build DarkGreen $_.HostName on $_.RunningServer
                Restart-BizTalkHostInstance -HostInstance $_
            }
        }
    }
}

# Synopsis: Restart the Microsoft BizTalk Server Host Instances of the BizTalk Group
task Restart-BizTalkHostInstancesForGroup -If { Get-TaskResourceGroup -Name Bindings | Test-None } {
    Get-BizTalkHost | Where-Object -FilterScript { Test-BizTalkHost -Host $_ -Type InProcess } | Get-BizTalkHostInstance | ForEach-Object -Process {
        Write-Build DarkGreen $_.HostName on $_.RunningServer
        Restart-BizTalkHostInstance -HostInstance $_
    }
}
