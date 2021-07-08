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

# Synopsis: Deploy a Runtime Solution
task Deploy Undeploy, `
    Deploy-EventLogSources, `
    Deploy-Assemblies, `
    Deploy-SqlDatabases, `
    Deploy-WindowsServices, `
    Deploy-XmlConfigurations, `
    Invoke-Installers, `
    Start-WindowsServices

# Synopsis: Undeploy a Runtime Solution
task Undeploy -If { -not $SkipUndeploy } `
    Stop-WindowsServices, `
    Revoke-Installers, `
    Undeploy-XmlConfigurations, `
    Undeploy-WindowsServices, `
    Undeploy-SqlDatabases, `
    Undeploy-Assemblies, `
    Undeploy-EventLogSources

# Synopsis: Deploy a Whole Microsoft BizTalk Server Solution
task DeployBizTalk UndeployBizTalk, `
    Deploy-EventLogSources, `
    Deploy-Assemblies, `
    Deploy-BamConfiguration, `
    Deploy-SqlDatabases, `
    Deploy-WindowsServices, `
    Deploy-XmlConfigurations, `
    Deploy-SsoConfigStores, `
    Deploy-BizTalkApplication, `
    Invoke-Installers, `
    Start-WindowsServices

# Synopsis: Patch a Whole Microsoft BizTalk Server Solution
task PatchBizTalk { $Script:SkipMgmtDbDeployment = $true }, `
    Patch-BizTalkApplication

# Synopsis: Undeploy a Whole Microsoft BizTalk Server Solution
task UndeployBizTalk -If { -not $SkipUndeploy } `
    Stop-WindowsServices, `
    Revoke-Installers, `
    Undeploy-BizTalkApplication, `
    Undeploy-SsoConfigStores, `
    Undeploy-XmlConfigurations, `
    Undeploy-WindowsServices, `
    Undeploy-SqlDatabases, `
    Undeploy-BamConfiguration, `
    Undeploy-Assemblies, `
    Undeploy-EventLogSources
