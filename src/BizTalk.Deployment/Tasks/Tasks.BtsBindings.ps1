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

# Synopsis: Deploy Microsoft BizTalk Server Application Bindings if on the Management Server
task Deploy-Bindings -If { -not $SkipMgmtDbDeployment } `
    Deploy-BindingsOnManagementServer

# Synopsis: Deploy Microsoft BizTalk Server Application Bindings
task Deploy-BindingsOnManagementServer `
    Convert-Bindings, `
    Import-Bindings

# Synopsis: Convert Fluent Application Bindings to XML Application Bindings
task Convert-Bindings {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        $arguments = @{
            ApplicationBindingAssemblyFilePath = $_.Path
            OutputFilePath                     = "$($_.Path).xml"
            TargetEnvironment                  = $TargetEnvironment
        }
        if ($_.AssemblyProbingFolderPaths | Test-Any) { $arguments.AssemblyProbingFolderPaths = $_.AssemblyProbingFolderPaths }
        if (Test-Member -InputObject $_ -Name EnvironmentSettingOverridesType) { $arguments.EnvironmentSettingOverridesType = $_.EnvironmentSettingOverridesType }
        if (Test-Member -InputObject $_ -Name ExcelSettingOverridesFolderPath) { $arguments.ExcelSettingOverridesFolderPath = $_.ExcelSettingOverridesFolderPath }
        Convert-ApplicationBinding @arguments
    }
}

# Synopsis: Import Microsoft BizTalk Server Application Bindings
task Import-Bindings {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        Invoke-Tool -Command { BTSTask AddResource -ApplicationName:`"$ApplicationName`" -Type:BizTalkBinding -Overwrite -Source:`"$($_.Path).xml`" }
        Invoke-Tool -Command { BTSTask ImportBindings -ApplicationName:`"$ApplicationName`" -Source:`"$($_.Path).xml`" }
    }
}

# Synopsis: Create FILE Adapter-based Receive Locations' and Send Ports' Folders
task Deploy-FileAdapterPaths {
    Get-TaskResourceGroup -Name Bindings | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        $arguments = @{
            ApplicationBindingAssemblyFilePath = $_.Path
            TargetEnvironment                  = $TargetEnvironment
            # TODO $FileAdapterFolderUsers is a global variable ; it should be bound to some resource
            # Users                              = if ($FileAdapterFolderUsers | Test-Any) { $FileAdapterFolderUsers } else { @("$($Env:COMPUTERNAME)\BizTalk Application Users", 'BUILTIN\Users') }
            Users                              = @("$($Env:COMPUTERNAME)\BizTalk Application Users", 'BUILTIN\Users')
        }
        if ($_.AssemblyProbingFolderPaths | Test-Any) { $arguments.AssemblyProbingFolderPaths = $_.AssemblyProbingFolderPaths }
        if (Test-Member -InputObject $_ -Name EnvironmentSettingOverridesType) { $arguments.EnvironmentSettingOverridesType = $_.EnvironmentSettingOverridesType }
        if (Test-Member -InputObject $_ -Name ExcelSettingOverridesFolderPath) { $arguments.ExcelSettingOverridesFolderPath = $_.ExcelSettingOverridesFolderPath }
        Install-ApplicationFileAdapterFolders @arguments
    }
}
# Synopsis: Remove FILE Adapter-based Receive Locations' and Send Ports' Folders
task Undeploy-FileAdapterPaths -If { -not $SkipUndeploy } {
    Get-TaskResourceGroup -Name Bindings | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        $arguments = @{
            ApplicationBindingAssemblyFilePath = $_.Path
            TargetEnvironment                  = $TargetEnvironment
        }
        if ($_.AssemblyProbingFolderPaths | Test-Any) { $arguments.AssemblyProbingFolderPaths = $_.AssemblyProbingFolderPaths }
        if (Test-Member -InputObject $_ -Name EnvironmentSettingOverridesType) { $arguments.EnvironmentSettingOverridesType = $_.EnvironmentSettingOverridesType }
        if (Test-Member -InputObject $_ -Name ExcelSettingOverridesFolderPath) { $arguments.ExcelSettingOverridesFolderPath = $_.ExcelSettingOverridesFolderPath }
        Uninstall-ApplicationFileAdapterFolders @arguments
    }
}
