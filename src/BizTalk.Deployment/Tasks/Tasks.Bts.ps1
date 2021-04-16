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

. $PSScriptRoot\..\BtsResource\BtsResource.ps1

. $PSScriptRoot\Tasks.BtsApplication.ps1
. $PSScriptRoot\Tasks.BtsBindings.ps1
. $PSScriptRoot\Tasks.BtsComponents.ps1
. $PSScriptRoot\Tasks.BtsMaps.ps1
. $PSScriptRoot\Tasks.BtsOrchestrations.ps1
. $PSScriptRoot\Tasks.BtsPipelineComponents.ps1
. $PSScriptRoot\Tasks.BtsPipelines.ps1
. $PSScriptRoot\Tasks.BtsSchemas.ps1

# Synopsis: Deploy a Microsoft BizTalk Server Application
task Deploy-BizTalkApplication `
    Undeploy-BizTalkApplication, `
    Add-BizTalkApplication, `
    Deploy-BizTalkArtifacts, `
    Start-Application

# Synopsis: Patch a Microsoft BizTalk Server Application's Binaries
task Patch-BizTalkApplication Deploy-BizTalkArtifacts, `
    Start-Application, `
    Restart-BizTalkGroupHostInstances

# Synopsis: Undeploy a Microsoft BizTalk Server Application
task Undeploy-BizTalkApplication -If { -not $SkipUndeploy } `
    Stop-Application, `
    Undeploy-BizTalkArtifacts, `
    Remove-BizTalkApplication, `
    Restart-BizTalkGroupHostInstances

# Synopsis: Deploy all Microsoft BizTalk Server Artifacts
task Deploy-BizTalkArtifacts `
    Deploy-Schemas, `
    Deploy-Maps, `
    Deploy-Components, `
    Deploy-PipelineComponents, `
    Deploy-Pipelines, `
    Deploy-Orchestrations, `
    Deploy-Bindings, `
    Deploy-FileAdapterPaths

# Synopsis: Undeploy all Microsoft BizTalk Server Artifacts
task Undeploy-BizTalkArtifacts -If { -not $SkipUndeploy } `
    Undeploy-FileAdapterPaths, `
    Undeploy-Orchestrations, `
    Undeploy-Pipelines, `
    Undeploy-PipelineComponents, `
    Undeploy-Components, `
    Undeploy-Maps, `
    Undeploy-Schemas

task Restart-BizTalkGroupHostInstances {
    # TODO restart only the host instances concerning the application being deployed and those depending upon
    Get-BizTalkHost | Where-Object -FilterScript { Test-BizTalkHost -Host $_ -Type InProcess } | Get-BizTalkHostInstance | ForEach-Object -Process {
        Write-Build DarkGreen $_.HostName
        Restart-BizTalkHostInstance -HostInstance $_
    }
}
