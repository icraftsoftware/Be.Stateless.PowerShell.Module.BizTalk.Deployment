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

function ConvertTo-BindingBasedCmdletArguments {
    [CmdletBinding()]
    [OutputType([HashTable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [PSCustomObject]
        $Binding
    )
    $arguments = @{
        ApplicationBindingAssemblyFilePath = $Binding.Path
        TargetEnvironment                  = $TargetEnvironment
    }
    if ($Binding.AssemblyProbingFolderPaths | Test-Any) { $arguments.AssemblyProbingFolderPaths = $Binding.AssemblyProbingFolderPaths }
    if (Test-Member -InputObject $Binding -Name EnvironmentSettingOverridesTypeName) { $arguments.EnvironmentSettingOverridesTypeName = $Binding.EnvironmentSettingOverridesTypeName }
    if (Test-Member -InputObject $Binding -Name ExcelSettingOverridesFolderPath) { $arguments.ExcelSettingOverridesFolderPath = $Binding.ExcelSettingOverridesFolderPath }
    return $arguments
}
