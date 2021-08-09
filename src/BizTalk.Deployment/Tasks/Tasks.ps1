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

# TODO option switches to skip tasks (e.g. SkipBamDeployment)

Set-StrictMode -Version Latest

. $PSScriptRoot\Tasks.Shim.ps1

. $PSScriptRoot\Tasks.Assemblies.ps1
. $PSScriptRoot\Tasks.Bam.ps1
. $PSScriptRoot\Tasks.Bts.ps1
. $PSScriptRoot\Tasks.EventLogSources.ps1
. $PSScriptRoot\Tasks.Iis.ps1
. $PSScriptRoot\Tasks.Installers.ps1
. $PSScriptRoot\Tasks.Sql.ps1
. $PSScriptRoot\Tasks.SsoConfigStores.ps1
. $PSScriptRoot\Tasks.WindowsServices.ps1
. $PSScriptRoot\Tasks.XmlConfigurations.ps1

# Synopsis: Deploy a Whole Microsoft BizTalk Server Application or Library Solution
task Deploy Undeploy, `
    Deploy-EventLogSources, `
    Deploy-Assemblies, `
    Deploy-WindowsServices, `
    Deploy-XmlConfigurations, `
    Deploy-SsoConfigStores, `
    Add-DatabaseDeploymentTasks, `
    Add-BtsDeploymentTasks, `
    Deploy-Installers, `
    Start-WindowsServices

# Synopsis: Patch a Whole Microsoft BizTalk Server Application or Library Solution
task Patch { $Script:SkipMgmtDbDeployment = $true }, `
    Patch-BizTalkApplication

# Synopsis: Undeploy a Whole Microsoft BizTalk Server Application or Library Solution
task Undeploy -If { -not $SkipUndeploy } `
    Stop-WindowsServices, `
    Undeploy-Installers, `
    Add-BtsUndeploymentTasks, `
    Add-DatabaseUndeploymentTasks, `
    Undeploy-SsoConfigStores, `
    Undeploy-XmlConfigurations, `
    Undeploy-WindowsServices, `
    Undeploy-Assemblies, `
    Undeploy-EventLogSources

task Add-DatabaseDeploymentTasks `
    Enter-DatabaseDeployment, `
    Deploy-SqlDatabases, `
    Exit-DatabaseDeployment
task Enter-DatabaseDeployment
task Exit-DatabaseDeployment

task Add-DatabaseUndeploymentTasks `
    Enter-DatabaseUndeployment, `
    Undeploy-SqlDatabases, `
    Exit-DatabaseUndeployment
task Enter-DatabaseUndeployment
task Exit-DatabaseUndeployment

task Add-BtsDeploymentTasks -If ($Manifest.Properties.Type -eq 'Application') `
    Enter-BtsDeployment, `
    Deploy-BizTalkApplication, `
    Exit-BtsDeployment
task Enter-BtsDeployment
task Exit-BtsDeployment

task Add-BtsUndeploymentTasks -If ($Manifest.Properties.Type -eq 'Application') `
    Enter-BtsUndeployment, `
    Undeploy-BizTalkApplication, `
    Exit-BtsUndeployment
task Enter-BtsUndeployment
task Exit-BtsUndeployment
