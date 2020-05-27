#region Copyright & License

# Copyright © 2012 - 2020 François Chabot
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

function Expand-Bindings {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $TargetEnvironment,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BindingFilePath,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [string]
        $EnvironmentSettingOverridesRootPath,

        [Parameter(Mandatory = $false)]
        [AllowEmptyCollection()]
        [string[]]
        $AssemblyProbingPaths
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    Write-Information $Path
    Invoke-Tool -Command { InstallUtil /ShowCallStack /TargetEnvironment=$TargetEnvironment /BindingFilePath="$BindingFilePath" /EnvironmentSettingOverridesRootPath="$EnvironmentSettingOverridesRootPath" /AssemblyProbingPaths="$($AssemblyProbingPaths -join ';')" "$Path" }
}

function Import-Bindings {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ApplicationName
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    Write-Information $Path
    Invoke-Tool -Command { BTSTask AddResource -ApplicationName:"$ApplicationName" -Type:BizTalkBinding -Overwrite -Source:"$Path" }
    Invoke-Tool -Command { BTSTask ImportBindings -ApplicationName:"$ApplicationName" -Source:"$Path" }
}

# https://docs.microsoft.com/en-us/biztalk/core/btstask-command-line-reference
Add-ToolAlias -Path ($env:BTSINSTALLPATH) -Tool BTSTask
Add-ToolAlias -Path 'Framework\v4.0.30319' -Tool InstallUtil
