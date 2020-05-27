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

Enter-Build {
    $script:ApplicationName = $ItemGroups.Application.Name
    $script:ApplicationDescription = $ItemGroups.Application.Description
}

task Deploy Undeploy, Deploy-BizTalkApplication, Deploy-BizTalkArtifacts

task Patch { $Script:SkipMgmtDbDeployment = $true }, Deploy-BizTalkArtifacts

task Undeploy -If { -not $SkipUndeploy } Undeploy-BizTalkArtifacts, Undeploy-BizTalkApplication

# Synopsis: Deploy a Whole Microsoft BizTalk Server Application
task Deploy-BizTalkArtifacts `
    Deploy-Schemas, `
    Deploy-Transforms, `
    Deploy-Assemblies, `
    Deploy-Components, `
    Deploy-PipelineComponents, `
    Deploy-Pipelines, `
    Deploy-Orchestrations, `
    Deploy-Bindings

# Synopsis: Undeploy a Whole Microsoft BizTalk Server Application
task Undeploy-BizTalkArtifacts `
    Undeploy-Orchestrations, `
    Undeploy-Pipelines, `
    Undeploy-PipelineComponents, `
    Undeploy-Components, `
    Undeploy-Assemblies, `
    Undeploy-Transforms, `
    Undeploy-Schemas

# Synopsis: Create a Microsoft BizTalk Server Application
task Deploy-BizTalkApplication -If { -not (Test-BizTalkApplication $ApplicationName) } {
    Write-Build DarkGreen "Adding Microsoft BizTalk Server Application '$ApplicationName'"
    New-BizTalkApplication -Name $ApplicationName -Description $ApplicationDescription
    # TODO add app references
    # <AddAppReference ApplicationName="$(BizTalkAppName)" AppsToReference="@(AppsToReference)" Condition="%(Identity) == %(Identity) and '@(AppsToReference)' != ''" />
}
# Synopsis: Delete a Microsoft BizTalk Server Application
task Undeploy-BizTalkApplication -If { Test-BizTalkApplication -Name $ApplicationName } Stop-Application, {
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
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Install-GacAssembly -Path $_.Path
    }
}
# Synopsis: Remove Assemblies from the GAC
task Undeploy-Assemblies {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Deploy Microsoft BizTalk Server Application Bindings and Enforce Artifacts' Expected States
task Deploy-Bindings Import-Bindings, Install-FileAdapterPaths, Initialize-BizTalkServices

# Synopsis: Import Microsoft BizTalk Server Application Bindings
task Import-Bindings Expand-Bindings, {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Import-Bindings -Path "$($_.Path).xml" -ApplicationName $ApplicationName
    }
}
# Synopsis: Generate Microsoft BizTalk Server Application Bindings
task Expand-Bindings {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        $arguments = @{
            Path              = $_.Path
            TargetEnvironment = $TargetEnvironment
            BindingFilePath   = "$($_.Path).xml"
        }
        if (Test-Item -Item $_ -Property 'EnvironmentSettingOverridesRootPath') {
            $arguments.Add('EnvironmentSettingOverridesRootPath', $_.EnvironmentSettingOverridesRootPath)
        }
        if (Test-Item -Item $_ -Property 'AssemblyProbingPaths') {
            $arguments.Add('AssemblyProbingPaths', $_.AssemblyProbingPaths)
        }
        Expand-Bindings @arguments
    }
}
# Synopsis: Create FILE Adapter-based Receive Locations' and Send Ports' Folders
task Install-FileAdapterPaths {
    # TODO
    Write-Build Yellow 'YET TO BE DONE'
}
# Synopsis: Start Microsoft BizTalk Server Application Services
task Initialize-BizTalkServices {
    # TODO
    Write-Build Yellow 'YET TO BE DONE'
}

# Synopsis: Add Components to the GAC and Run Their Installer
task Deploy-Components Undeploy-Components, {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Install-GacAssembly -Path $_.Path
        Install-Component -Path $_.Path -SkipInstallUtil:$SkipInstallUtil
    }
}
# Synopsis: Run Components Uninstaller and Remove Them from the GAC
task Undeploy-Components {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Uninstall-Component -Path $_.Path -SkipInstallUtil:$SkipInstallUtil
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Install Microsoft BizTalk Server Pipelines and Add Their Containing Assemblies to the GAC
task Deploy-Pipelines {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        if ($SkipMgmtDbDeployment) {
            Install-GacAssembly -Path $_.Path
        } else {
            Add-BizTalkResource -Path $_.Path -ApplicationName $ApplicationName
        }
    }
}
# Synopsis: Remove Microsoft BizTalk Server Pipelines' Containing Assemblies from the GAC
task Undeploy-Pipelines {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Deploy Microsoft BizTalk Server Pipeline Components and Add Them to the GAC
task Deploy-PipelineComponents {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Copy-Item -Path $_.Path -Destination "$(Join-Path -Path $env:BTSINSTALLPATH -ChildPath 'Pipeline Components')" -Force
        Install-GacAssembly -Path $_.Path
    }
}
# Synopsis: Undeploy Microsoft BizTalk Server Pipeline Components and Remove Them from the GAC
task Undeploy-PipelineComponents Recycle-AppPool, {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        $pc = [System.IO.Path]::Combine($env:BTSINSTALLPATH, 'Pipeline Components', [System.IO.Path]::GetFileName($_.Path))
        if (Test-Path -Path $pc) {
            Remove-Item -Path $pc -Force
        }
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Install Microsoft BizTalk Server Orchestrations and Add Their Containing Assemblies to the GAC
task Deploy-Orchestrations {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        if ($SkipMgmtDbDeployment) {
            Install-GacAssembly -Path $_.Path
        } else {
            Add-BizTalkResource -Path $_.Path -ApplicationName $ApplicationName
        }
    }
}
# Synopsis: Remove Microsoft BizTalk Server Orchestrations' Containing Assemblies from the GAC
task Undeploy-Orchestrations {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Install Microsoft BizTalk Server Schemas and Add Their Containing Assemblies to the GAC
task Deploy-Schemas {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        if ($SkipMgmtDbDeployment) {
            Install-GacAssembly -Path $_.Path
        } else {
            Add-BizTalkResource -Path $_.Path -ApplicationName $ApplicationName
        }
    }
}
# Synopsis: Remove Microsoft BizTalk Server Schemas' Containing Assemblies from the GAC
task Undeploy-Schemas {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Install Microsoft BizTalk Server Transforms and Add Their Containing Assemblies to the GAC
task Deploy-Transforms {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        if ($SkipMgmtDbDeployment) {
            Install-GacAssembly -Path $_.Path
        } else {
            Add-BizTalkResource -Path $_.Path -ApplicationName $ApplicationName
        }
    }
}
# Synopsis: Remove Microsoft BizTalk Server Transforms' Containing Assemblies from the GAC
task Undeploy-Transforms {
    Get-TaskItemGroup -Task $Task | ForEach-Object -Process {
        Uninstall-GacAssembly -Path $_.Path
    }
}

# Synopsis: Recycle an IIS AppPool
task Recycle-AppPool {
    # see cmdlet Restart-WebAppPool
    # <Exec Command="iisreset.exe /noforce /restart /timeout:$(IisResetTime)" Condition="'@(IISAppPool)' == ''" />
    # <RecycleAppPool Items="@(IISAppPool)" Condition="'@(IISAppPool)' != ''" />
}

function Get-TaskItemGroup {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [psobject]
        $Task
    )
    $taskObject = $Task.Name -split '-' | Select-Object -Skip 1
    if ($ItemGroups.ContainsKey($taskObject)) {
        @($ItemGroups.$taskObject)
    } else {
        @()
    }
}

Import-Module $PSScriptRoot\..\Application
Import-Module $PSScriptRoot\..\Assembly
Import-Module $PSScriptRoot\..\Bindings
Import-Module $PSScriptRoot\..\Component
Import-Module $PSScriptRoot\..\Resource
