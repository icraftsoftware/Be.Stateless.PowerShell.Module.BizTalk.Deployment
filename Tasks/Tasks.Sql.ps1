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

# Synopsis: Deploy SQL databases and execute SQL deployment scripts
task Deploy-SqlDatabases Invoke-SqlDeploymentScripts

# Synopsis: Undeploy SQL databases and execute SQL undeployment scripts
task Undeploy-SqlDatabases -If { -not $SkipUndeploy } Invoke-SqlUndeploymentScripts

# Synopsis: Execute SQL deployment scripts
task Invoke-SqlDeploymentScripts {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        $location = Get-Location
        $arguments = @{
            InputFile      = $_.Path
            ServerInstance = $_.Server
        }
        if ($_.Variables.Keys | Test-Any) { $arguments.Variable = $(Format-SqlVariable -Variable $_.Variables) }
        try {
            Invoke-Sqlcmd @arguments
        } finally {
            Set-Location $location
        }
    }
}

# Synopsis: Execute SQL undeployment scripts
task Invoke-SqlUndeploymentScripts -If { -not $SkipUndeploy } {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        $location = Get-Location
        $arguments = @{
            InputFile      = $_.Path
            ServerInstance = $_.Server
        }
        if ($_.Variables.Keys | Test-Any) { $arguments.Variable = $(Format-SqlVariable -Variable $_.Variables) }
        try {
            Invoke-Sqlcmd @arguments
        } finally {
            Set-Location $location
        }
    }
}

function Format-SqlVariable {
    [CmdletBinding()]
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Variables
    )
    # see https://stackoverflow.com/a/16656788/1789441
    @($Variables.Keys | ForEach-Object -Process { "$_=$($Variables.$_)" })
}
