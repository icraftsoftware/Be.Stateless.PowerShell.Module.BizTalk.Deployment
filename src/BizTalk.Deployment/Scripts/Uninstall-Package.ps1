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

[CmdletBinding()]
[OutputType([void])]
param(
    [Parameter(Mandatory = $true)]
    [hashtable[]]
    $Manifest,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $TargetEnvironment,

    [Parameter()]
    [switch]
    $SkipInstallUtil,

    [Parameter()]
    [scriptblock[]]
    $Tasks = ([scriptblock] { })
)
begin {
    Set-StrictMode -Version Latest
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $script:Manifest = $Manifest
    $script:SkipUndeploy = $false
    $script:SkipMgmtDbDeployment = $false
}
end {
    Invoke-Build Undeploy {
        . BizTalk.Deployment.Tasks
        foreach ($taskBlock in $Tasks) {
            . $taskBlock
        }
        . $canceledTasks
    }
}