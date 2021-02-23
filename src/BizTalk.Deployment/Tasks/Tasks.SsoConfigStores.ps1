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

# Synopsis: Deploy application's SSO config stores if on the Management Server
task Deploy-SsoConfigStores -If { -not $SkipMgmtDbDeployment } `
    Deploy-SsoConfigStoresOnManagementServer

# Synopsis: Deploy application's SSO config stores
task Deploy-SsoConfigStoresOnManagementServer `
    Update-SsoConfigStores

# Synopsis: Update application's SSO config stores
task Update-SsoConfigStores {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path

        $arguments = @{ AffiliateApplicationName = $ApplicationName }
        if ($_.AdministratorGroups | Test-Any) { $arguments.AdministratorGroups = $_.AdministratorGroups }
        if ($_.UserGroups | Test-Any ) { $arguments.UserGroups = $_.UserGroups }
        $application = New-AffiliateApplication @arguments

        $arguments = @{
            EnvironmentSettingsAssemblyFilePath = $_.Path
            TargetEnvironment                   = $TargetEnvironment
        }
        if (Test-Member -InputObject $_ -Name EnvironmentSettingOverridesType) { $arguments.EnvironmentSettingOverridesType = $_.EnvironmentSettingOverridesType }
        $settings = Get-EnvironmentSettings @arguments

        Update-AffiliateApplicationStore -AffiliateApplication $application -EnvironmentSettings $settings
    }
}

# Synopsis: Undeploy application's SSO config stores if on the Management Server
task Undeploy-SsoConfigStores -If { -not $SkipMgmtDbDeployment } `
    Undeploy-SsoConfigStoresOnManagementServer

# Synopsis: Undeploy application's SSO config stores
task Undeploy-SsoConfigStoresOnManagementServer -If { -not $SkipUndeploy } `
    Remove-SsoConfigStores

# Synopsis: Remove application's SSO config stores
task Remove-SsoConfigStores -If { -not $SkipUndeploy } {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        Remove-AffiliateApplication -AffiliateApplicationName $ApplicationName
    }
}
