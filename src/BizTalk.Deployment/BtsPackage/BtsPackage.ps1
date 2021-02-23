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

function Install-BizTalkPackage {
    # TODO https://stackoverflow.com/questions/26910789/is-it-possible-to-reuse-a-param-block-across-multiple-functions
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
        $SkipMgmtDbDeployment,

        [Parameter()]
        [switch]
        $SkipInstallUtil,

        [Parameter()]
        [switch]
        $SkipUndeploy,

        [Parameter()]
        [switch]
        $TerminateServiceInstances,

        [Parameter()]
        [scriptblock[]]
        $Tasks = ([scriptblock] { })

        # TODO re-expose manifests' param as dynamic params

        # TODO config store admins
        # TODO config store users
        # TODO file adapter users
    )
    begin {
        Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $script:Manifest = $Manifest
    }
    end {
        # https://github.com/nightroman/Invoke-Build/issues/78, Script block as `File`
        # https://github.com/nightroman/Invoke-Build/tree/master/Tasks/Inline
        Invoke-Build Deploy {
            . BizTalk.Deployment.Tasks
            foreach ($taskBlock in $Tasks) {
                . $taskBlock
            }
        }
    }
}

function Uninstall-BizTalkPackage {
    # TODO https://stackoverflow.com/questions/26910789/is-it-possible-to-reuse-a-param-block-across-multiple-functions
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
        $SkipMgmtDbDeployment,

        [Parameter()]
        [switch]
        $SkipInstallUtil,

        [Parameter()]
        [switch]
        $SkipUndeploy,

        [Parameter()]
        [switch]
        $TerminateServiceInstances,

        [Parameter()]
        [scriptblock[]]
        $Tasks = ([scriptblock] { })
    )
    begin {
        Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $script:Manifest = $Manifest
    }
    end {
        # https://github.com/nightroman/Invoke-Build/issues/78, Script block as `File`
        # https://github.com/nightroman/Invoke-Build/tree/master/Tasks/Inline
        Invoke-Build Undeploy {
            . BizTalk.Deployment.Tasks
            foreach ($taskBlock in $Tasks) {
                . $taskBlock
            }
        }
    }
}
