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

# Synopsis: Deploy SQL databases and execute SQL deployment scripts if on the Management Server
task Deploy-SqlDatabases -If { -not $SkipMgmtDbDeployment } `
    Deploy-SqlDatabasesOnManagementServer

# Synopsis: Deploy SQL databases and execute SQL deployment scripts
task Deploy-SqlDatabasesOnManagementServer `
    Invoke-SqlDeploymentScripts

# Synopsis: Undeploy SQL databases and execute SQL undeployment scripts if on the Management Server
task Undeploy-SqlDatabases -If { -not $SkipMgmtDbDeployment } `
    Undeploy-SqlDatabasesOnManagementServer

# Synopsis: Undeploy SQL databases and execute SQL undeployment scripts
task Undeploy-SqlDatabasesOnManagementServer -If { -not $SkipUndeploy } `
    Invoke-SqlUndeploymentScripts

# Synopsis: Execute SQL deployment scripts
task Invoke-SqlDeploymentScripts {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        $location = Get-Location
        try {
            Invoke-SqlScript -Path $_.Path -Server $_.Server -Variables $_.Variables
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
        try {
            Invoke-SqlScript -Path $_.Path -Server $_.Server -Variables $_.Variables
        } finally {
            Set-Location $location
        }
    }
}

function Invoke-SqlScript {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [hashtable]
        $Variables
    )
    $arguments = @{
        InputFile      = $Path
        ServerInstance = $Server
    }
    # see https://stackoverflow.com/a/16656788/1789441
    if ($Variables.Keys | Test-Any) { $arguments.Variable = $( @($Variables.Keys | ForEach-Object -Process { "$_=$($Variables.$_)" }) ) }
    Invoke-Sqlcmd @arguments
}
