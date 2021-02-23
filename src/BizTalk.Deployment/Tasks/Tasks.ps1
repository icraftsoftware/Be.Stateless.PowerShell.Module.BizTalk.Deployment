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

. $PSScriptRoot\Tasks.Assembly.ps1
. $PSScriptRoot\Tasks.Bam.ps1
. $PSScriptRoot\Tasks.Bts.ps1
. $PSScriptRoot\Tasks.Iis.ps1
. $PSScriptRoot\Tasks.Sql.ps1
. $PSScriptRoot\Tasks.SsoConfigStores.ps1
. $PSScriptRoot\Tasks.XmlConfigurations.ps1

# Synopsis: Deploy a Whole Microsoft BizTalk Server Solution
task Deploy Undeploy, `
    Deploy-Assemblies, `
    Apply-XmlConfigurations, `
    Deploy-BamConfiguration, `
    Deploy-SqlDatabases, `
    Deploy-SsoConfigStores, `
    Deploy-BizTalkApplication, `
    Restart-BizTalkGroupHostInstances

# Synopsis: Patch a Whole Microsoft BizTalk Server Solution
task Patch { $Script:SkipMgmtDbDeployment = $true }, `
    Patch-BizTalkApplication, `
    Restart-BizTalkGroupHostInstances

# Synopsis: Undeploy a Whole Microsoft BizTalk Server Solution
task Undeploy -If { -not $SkipUndeploy } `
    Undeploy-BizTalkApplication, `
    Undeploy-SsoConfigStores, `
    Undeploy-SqlDatabases, `
    Undeploy-BamConfiguration, `
    Revert-XmlConfigurations, `
    Undeploy-Assemblies, `
    Restart-BizTalkGroupHostInstances

task Restart-BizTalkGroupHostInstances {
    # TODO restart only the host instances concerning the application being deployed and those depending upon
    Get-BizTalkHost | Where-Object -FilterScript { Test-BizTalkHost -Host $_ -Type InProcess } | Get-BizTalkHostInstance | ForEach-Object -Process {
        Write-Build DarkGreen $_.HostName
        Restart-BizTalkHostInstance -HostInstance $_
    }
}
