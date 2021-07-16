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

@{
   RootModule            = 'BizTalk.Deployment.psm1'
   ModuleVersion         = '1.0.0.0'
   GUID                  = '533b5f59-49ce-4f51-a293-cb78f5cf81b5'
   Author                = 'François Chabot'
   CompanyName           = 'be.stateless'
   Copyright             = '(c) 2021 be.stateless. All rights reserved.'
   Description           = 'Commands to deploy Microsoft BizTalk Server Applications supported by a deployment framework featuring a declarative task model.'
   ProcessorArchitecture = 'None'
   PowerShellVersion     = '5.0'
   NestedModules         = @('.\bin\Be.Stateless.BizTalk.Deployment.Cmdlets.dll')
   RequiredAssemblies    = @(
      '.\bin\Be.Stateless.BizTalk.Dsl.Abstractions.dll',
      '.\bin\Be.Stateless.BizTalk.Dsl.Binding.Conventions.dll',
      '.\bin\Be.Stateless.BizTalk.Dsl.Binding.dll',
      '.\bin\Be.Stateless.BizTalk.Dsl.Environment.Settings.dll',
      '.\bin\Be.Stateless.BizTalk.Dsl.Pipeline.dll',
      '.\bin\Be.Stateless.BizTalk.Explorer.dll'
   )
   RequiredModules       = @('BizTalk.Administration', 'Dsl.Configuration', 'Exec', 'Gac', 'InvokeBuild', 'Resource.Manifest', 'Psx', 'SqlServer')

   AliasesToExport       = @(
      'BizTalk.Deployment.Tasks',
      'Install-BizTalkApplication',
      'Install-BizTalkLibrary',
      'Uninstall-BizTalkApplication',
      'Uninstall-BizTalkLibrary'
   )
   CmdletsToExport       = @(
      # Application
      'Get-ApplicationHosts',
      'Initialize-ApplicationState',
      'Install-ApplicationFileAdapterFolders',
      'Test-ApplicationState',
      'Uninstall-ApplicationFileAdapterFolders',
      # Binding
      'Convert-ApplicationBinding',
      'Expand-ApplicationBinding',
      'Test-ApplicationBinding',
      # Settings
      'Get-EnvironmentSettings',
      # Sso
      'Get-AffiliateApplication',
      'Get-AffiliateApplicationStore',
      'New-AffiliateApplication',
      'Remove-AffiliateApplication',
      'Update-AffiliateApplicationStore'
   )
   FunctionsToExport     = @()
   VariablesToExport     = @()
   PrivateData           = @{
      PSData = @{
         Tags                       = @('Application', 'BizTalk', 'Deployment', 'Declarative', 'SQL')
         LicenseUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment/blob/master/LICENSE'
         ProjectUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment'
         ExternalModuleDependencies = @('BizTalk.Administration', 'Dsl.Configuration', 'Exec', 'Gac', 'InvokeBuild', 'Resource.Manifest', 'Psx', 'SqlServer')
      }
   }
}
