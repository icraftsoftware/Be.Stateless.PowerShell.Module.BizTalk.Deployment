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

# Synopsis: Deploy a Microsoft BizTalk Server Application
task Deploy-BizTalkApplication Add-BizTalkApplication, Deploy-BizTalkArtifacts

# Synopsis: Patch a Microsoft BizTalk Server Application's Binaries
task Patch-BizTalkApplication Deploy-BizTalkArtifacts

# Synopsis: Undeploy a Microsoft BizTalk Server Application
task Undeploy-BizTalkApplication -If { -not $SkipUndeploy } Undeploy-BizTalkArtifacts, Remove-BizTalkApplication

# Synopsis: Deploy all Microsoft BizTalk Server Artifacts
task Deploy-BizTalkArtifacts `
    Deploy-Schemas, `
    Deploy-Transforms, `
    Deploy-Assemblies, `
    Deploy-Components, `
    Deploy-PipelineComponents, `
    Deploy-Pipelines, `
    Deploy-Orchestrations, `
    Deploy-Bindings

# Synopsis: Undeploy all Microsoft BizTalk Server Artifacts
task Undeploy-BizTalkArtifacts `
    Undeploy-Orchestrations, `
    Undeploy-Pipelines, `
    Undeploy-PipelineComponents, `
    Undeploy-Components, `
    Undeploy-Assemblies, `
    Undeploy-Transforms, `
    Undeploy-Schemas

# Synopsis: Create a Microsoft BizTalk Server Application with References to Its Dependant Microsoft BizTalk Server Applications
task Add-BizTalkApplication -If { ($Manifest.Properties.Type -eq 'Application') -and -not (Test-BizTalkApplication $ApplicationName) } {
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
    New-BizTalkApplication @arguments
}
# Synopsis: Delete a Microsoft BizTalk Server Application
task Remove-BizTalkApplication -If { ($Manifest.Properties.Type -eq 'Application') -and (Test-BizTalkApplication -Name $ApplicationName) } Stop-Application, {
    Write-Build DarkGreen "Removing Microsoft BizTalk Server Application '$ApplicationName'"
    Remove-BizTalkApplication -Name $ApplicationName
}
# Synopsis: Stop a Microsoft BizTalk Server Application
task Stop-Application {
    Write-Build DarkGreen "Stopping Microsoft BizTalk Server Application '$ApplicationName'"
    Stop-BizTalkApplication -Name $ApplicationName -TerminateServiceInstances:$TerminateServiceInstances
}

# Synopsis: Add Assemblies to the GAC
task Deploy-Assemblies {
    $Resources | ForEach-Object -Process {
        Install-GacAssembly -Path $_.Path
    }
}
# Synopsis: Remove Assemblies from the GAC
task Undeploy-Assemblies {
    $Resources | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Deploy Microsoft BizTalk Server Application Bindings and Enforce Artifacts' Expected States
task Deploy-Bindings Import-Bindings, Install-FileAdapterPaths, Initialize-BizTalkServices

# Synopsis: Import Microsoft BizTalk Server Application Bindings
task Import-Bindings Expand-Bindings, {
    $Resources | ForEach-Object -Process {
        Import-Bindings -Path "$($_.Path).xml" -ApplicationName $ApplicationName
    }
}
# Synopsis: Generate Microsoft BizTalk Server Application Bindings
task Expand-Bindings {
    $Resources | ForEach-Object -Process {
        $arguments = @{
            Path              = $_.Path
            OutputFilePath    = "$($_.Path).xml"
            TargetEnvironment = $TargetEnvironment
        }
        if (![string]::IsNullOrEmpty($_.ExcelSettingOverridesFolderPath)) {
            $arguments.ExcelSettingOverridesFolderPath = $_.ExcelSettingOverridesFolderPath
        }
        if ($_.AssemblyProbingFolderPaths | Test-Any) {
            $arguments.AssemblyProbingFolderPaths = $_.AssemblyProbingFolderPaths
        }
        Expand-Bindings @arguments
    }
}
# Synopsis: Create FILE Adapter-based Receive Locations' and Send Ports' Folders
task Install-FileAdapterPaths -If { $Manifest.Properties.Type -eq 'Application' } {
    Write-Build DarkGreen "Creating '$ApplicationName' file-based receive locations and send ports' folders"
    Get-TaskResourceGroup -Name Bindings | ForEach-Object -Process {
        #TODO support another user account than BUILTIN\Users, see BTDF
        Invoke-Tool -Command { InstallUtil /ShowCallStack /TargetEnvironment=$TargetEnvironment /SetupFileAdapterPaths /Users='BUILTIN\Users' /ExcelSettingOverridesFolderPath="$($_.ExcelSettingOverridesFolderPath)" /AssemblyProbingFolderPaths="$($_.AssemblyProbingFolderPaths -join ';')" "$($_.Path)" }
    }
    # TODO corresponding undeploy task
}
# Synopsis: Start Microsoft BizTalk Server Application Services
task Initialize-BizTalkServices -If { $Manifest.Properties.Type -eq 'Application' } {
    Write-Build DarkGreen "Initializing '$ApplicationName' services"
    Get-TaskResourceGroup -Name Bindings | ForEach-Object -Process {
        Invoke-Tool -Command { InstallUtil /ShowCallStack /TargetEnvironment=$TargetEnvironment /InitializeServices /ExcelSettingOverridesFolderPath="$($_.ExcelSettingOverridesFolderPath)" /AssemblyProbingFolderPaths="$($_.AssemblyProbingFolderPaths -join ';')" "$($_.Path)" }
    }
}

# Synopsis: Add Components to the GAC and Run Their Installer
task Deploy-Components Undeploy-Components, {
    $Resources | ForEach-Object -Process {
        Install-Component -Path $_.Path -SkipInstallUtil:$SkipInstallUtil
    }
}
# Synopsis: Run Components Uninstaller and Remove Them from the GAC
task Undeploy-Components {
    $Resources | ForEach-Object -Process {
        Uninstall-Component -Path $_.Path -SkipInstallUtil:$SkipInstallUtil
    }
}

# Synopsis: Install Microsoft BizTalk Server Pipelines and Add Their Containing Assemblies to the GAC
task Deploy-Pipelines -If { $Manifest.Properties.Type -eq 'Application' } {
    $Resources | ForEach-Object -Process {
        if ($SkipMgmtDbDeployment) {
            Install-GacAssembly -Path $_.Path
        } else {
            Add-BizTalkResource -Path $_.Path -ApplicationName $ApplicationName
        }
    }
}
# Synopsis: Remove Microsoft BizTalk Server Pipelines' Containing Assemblies from the GAC
task Undeploy-Pipelines -If { $Manifest.Properties.Type -eq 'Application' } {
    $Resources | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Deploy Microsoft BizTalk Server Pipeline Components and Add Them to the GAC
task Deploy-PipelineComponents {
    $Resources | ForEach-Object -Process {
        Copy-Item -Path $_.Path -Destination "$(Join-Path -Path $env:BTSINSTALLPATH -ChildPath 'Pipeline Components')" -Force
        Install-GacAssembly -Path $_.Path
    }
}
# Synopsis: Undeploy Microsoft BizTalk Server Pipeline Components and Remove Them from the GAC
task Undeploy-PipelineComponents Recycle-AppPool, {
    $Resources | ForEach-Object -Process {
        $pc = [System.IO.Path]::Combine($env:BTSINSTALLPATH, 'Pipeline Components', [System.IO.Path]::GetFileName($_.Path))
        if (Test-Path -Path $pc) {
            Remove-Item -Path $pc -Force
        }
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Install Microsoft BizTalk Server Orchestrations and Add Their Containing Assemblies to the GAC
task Deploy-Orchestrations -If { $Manifest.Properties.Type -eq 'Application' } {
    $Resources | ForEach-Object -Process {
        if ($SkipMgmtDbDeployment) {
            Install-GacAssembly -Path $_.Path
        } else {
            Add-BizTalkResource -Path $_.Path -ApplicationName $ApplicationName
        }
    }
}
# Synopsis: Remove Microsoft BizTalk Server Orchestrations' Containing Assemblies from the GAC
task Undeploy-Orchestrations -If { $Manifest.Properties.Type -eq 'Application' } {
    $Resources | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Install Microsoft BizTalk Server Schemas and Add Their Containing Assemblies to the GAC
task Deploy-Schemas -If { $Manifest.Properties.Type -eq 'Application' } {
    $Resources | ForEach-Object -Process {
        if ($SkipMgmtDbDeployment) {
            Install-GacAssembly -Path $_.Path
        } else {
            Add-BizTalkResource -Path $_.Path -ApplicationName $ApplicationName
        }
    }
}
# Synopsis: Remove Microsoft BizTalk Server Schemas' Containing Assemblies from the GAC
task Undeploy-Schemas -If { $Manifest.Properties.Type -eq 'Application' } {
    $Resources | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Install Microsoft BizTalk Server Transforms and Add Their Containing Assemblies to the GAC
task Deploy-Transforms -If { $Manifest.Properties.Type -eq 'Application' } {
    $Resources | ForEach-Object -Process {
        if ($SkipMgmtDbDeployment) {
            Install-GacAssembly -Path $_.Path
        } else {
            Add-BizTalkResource -Path $_.Path -ApplicationName $ApplicationName
        }
    }
}
# Synopsis: Remove Microsoft BizTalk Server Transforms' Containing Assemblies from the GAC
task Undeploy-Transforms -If { $Manifest.Properties.Type -eq 'Application' } {
    $Resources | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}
