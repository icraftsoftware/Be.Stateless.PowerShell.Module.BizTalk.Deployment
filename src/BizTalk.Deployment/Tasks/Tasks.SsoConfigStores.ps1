#region Copyright & License

# Copyright © 2012 - 2022 François Chabot
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

# Synopsis: Deploy application's SSO config stores
task Deploy-SsoConfigStores -If { -not $SkipSharedResources } `
   Undeploy-SsoConfigStores, `
   Add-SsoConfigStores, `
   Update-SsoConfigStores

# Synopsis: Add application's SSO config stores
task Add-SsoConfigStores {
   $Resources | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      $arguments = @{ AffiliateApplicationName = $ApplicationName }
      if ($_.AdministratorGroup | Test-Any) { $arguments.AdministratorGroup = $_.AdministratorGroup }
      if ($_.UserGroup | Test-Any ) { $arguments.UserGroup = $_.UserGroup }
      New-AffiliateApplication @arguments
   }
}

# Synopsis: Update application's SSO config stores
task Update-SsoConfigStores {
   $Resources | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      $arguments = @{
         AffiliateApplicationName            = $ApplicationName
         EnvironmentSettingsAssemblyFilePath = $_.Path
         TargetEnvironment                   = $TargetEnvironment
         Isolated                            = $Isolated
      }
      if ($_.AssemblyProbingFolderPath | Test-Any) { $arguments.AssemblyProbingFolderPath = $_.AssemblyProbingFolderPath }
      if (Test-Resource -InputObject $_ -Member EnvironmentSettingOverridesTypeName) { $arguments.EnvironmentSettingOverridesTypeName = $_.EnvironmentSettingOverridesTypeName }
      Update-AffiliateApplicationStore @arguments
   }
}

# Synopsis: Undeploy application's SSO config stores
task Undeploy-SsoConfigStores -If { (-not $SkipUninstall) -and (-not $SkipSharedResources) } `
   Remove-SsoConfigStores

# Synopsis: Remove application's SSO config stores
task Remove-SsoConfigStores {
   $Resources | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      Remove-AffiliateApplication -AffiliateApplicationName $ApplicationName
   }
}
