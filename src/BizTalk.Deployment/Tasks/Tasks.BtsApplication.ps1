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

# Synopsis: Create a Microsoft BizTalk Server Application if on the Management Server
task Add-BizTalkApplication -If { -not $SkipMgmtDbDeployment } `
    Remove-BizTalkApplication, `
    Add-BizTalkApplicationOnManagementServer

# Synopsis: Create a Microsoft BizTalk Server Application with References to Its Dependant Microsoft BizTalk Server Applications
task Add-BizTalkApplicationOnManagementServer -If { Test-ManifestApplication -Absent } {
    $arguments = @{ Name = $ApplicationName }
    if (![string]::IsNullOrWhiteSpace($Manifest.Properties.Description)) {
        $arguments.Description = $Manifest.Properties.Description
    }
    if ($Manifest.Properties.References | Test-Any) {
        Write-Build DarkGreen "Adding Microsoft BizTalk Server Application '$ApplicationName' with References to Microsoft BizTalk Server Applications '$($Manifest.Properties.References -join ''', ''')'"
        $arguments.References = $Manifest.Properties.References
    } else {
        Write-Build DarkGreen "Adding Microsoft BizTalk Server Application '$ApplicationName'"
    }
    New-BizTalkApplication @arguments | Out-Null
}

# Synopsis: Delete a Microsoft BizTalk Server Application if on the Management Server
task Remove-BizTalkApplication -If { -not $SkipMgmtDbDeployment } `
    Remove-BizTalkApplicationOnManagementServer

# Synopsis: Delete a Microsoft BizTalk Server Application
task Remove-BizTalkApplicationOnManagementServer -If { Test-ManifestApplication } {
    Write-Build DarkGreen "Removing Microsoft BizTalk Server Application '$ApplicationName'"
    Remove-BizTalkApplication -Name $ApplicationName
}

# Synopsis: Start Microsoft BizTalk Server Application if on the Management Server
task Start-Application -If { -not $SkipMgmtDbDeployment } `
    Start-ApplicationOnManagementServer

# Synopsis: Start Microsoft BizTalk Server Application
task Start-ApplicationOnManagementServer -If { Test-ManifestApplication } {
    Write-Build DarkGreen "Starting Microsoft BizTalk Server Application '$ApplicationName'"
    Get-TaskResourceGroup -Name Bindings | ForEach-Object -Process {
        $arguments = @{
            ApplicationBindingAssemblyFilePath = $_.Path
            TargetEnvironment                  = $TargetEnvironment
        }
        if ($_.AssemblyProbingFolderPaths | Test-Any) { $arguments.AssemblyProbingFolderPaths = $_.AssemblyProbingFolderPaths }
        if (Test-Member -InputObject $_ -Name EnvironmentSettingOverridesType) { $arguments.EnvironmentSettingOverridesType = $_.EnvironmentSettingOverridesType }
        if (Test-Member -InputObject $_ -Name ExcelSettingOverridesFolderPath) { $arguments.ExcelSettingOverridesFolderPath = $_.ExcelSettingOverridesFolderPath }
        Initialize-ApplicationState @arguments
    }
}

# Synopsis: Stop a Microsoft BizTalk Server Application if on the Management Server
task Stop-Application -If { -not $SkipMgmtDbDeployment } `
    Stop-ApplicationOnManagementServer

# Synopsis: Stop a Microsoft BizTalk Server Application
task Stop-ApplicationOnManagementServer -If { Test-ManifestApplication } {
    Write-Build DarkGreen "Stopping Microsoft BizTalk Server Application '$ApplicationName'"
    Stop-BizTalkApplication -Name $ApplicationName -TerminateServiceInstances:$TerminateServiceInstances
}

function Test-ManifestApplication {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [switch]
        $Absent
    )
    $Manifest.Properties.Type -eq 'Application' -and $Absent.IsPresent -eq -not(Test-BizTalkApplication -Name $ApplicationName)
}
