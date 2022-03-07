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

@{
   RootModule            = 'BizTalk.Deployment.psm1'
   ModuleVersion         = '2.1.1.1'
   GUID                  = '533b5f59-49ce-4f51-a293-cb78f5cf81b5'
   Author                = 'François Chabot'
   CompanyName           = 'be.stateless'
   Copyright             = '(c) 2020 - 2022 be.stateless. All rights reserved.'
   Description           = 'Commands to deploy Microsoft BizTalk Server Applications supported by a deployment framework featuring a declarative task model.'
   ProcessorArchitecture = 'None'
   PowerShellVersion     = '5.0'
   NestedModules         = @('.\bin\BizTalk.Deployment.Core.psd1')
   RequiredAssemblies    = @(
      '.\bin\Be.Stateless.BizTalk.Settings.dll',
      '.\bin\Be.Stateless.Dsl.Configuration.dll'
   )
   RequiredModules       = @(
      @{ ModuleName = 'Dsl.Configuration' ; ModuleVersion = '2.1.0.0' ; GUID = '99128609-dd5b-43d7-b834-6bc0ca537f02' }
      @{ ModuleName = 'Gac' ; ModuleVersion = '1.0.1' ; GUID = '2f3a501f-882b-43c4-aaeb-3ffc9fea932c' }
      @{ ModuleName = 'InvokeBuild' ; ModuleVersion = '5.8.6' ; GUID = 'a0319025-5f1f-47f0-ae8d-9c7e151a5aae' }
      @{ ModuleName = 'Resource.Manifest' ; ModuleVersion = '2.1.0.0' ; GUID = '07e35b0e-3441-46b4-82e6-d8daafb837bd' }
      @{ ModuleName = 'SqlServer' ; ModuleVersion = '21.1.18256' ; GUID = '97c3b589-6545-4107-a061-3fe23a4e9195' }
   )
   AliasesToExport       = @(
      'BizTalk.Deployment.Tasks',
      'Install-BizTalkApplication',
      'Install-BizTalkLibrary',
      'Uninstall-BizTalkApplication',
      'Uninstall-BizTalkLibrary'
   )
   CmdletsToExport       = @()
   FunctionsToExport     = @(
      # AffiliateApplication
      'Get-AffiliateApplication',
      'Get-AffiliateApplicationStore',
      'New-AffiliateApplication',
      'Remove-AffiliateApplication',
      'Update-AffiliateApplicationStore',
      # ApplicationBinding
      'Convert-ApplicationBinding',
      'Expand-ApplicationBinding',
      'Get-ApplicationHosts',
      'Initialize-ApplicationState',
      'Install-ApplicationFileAdapterFolders',
      'Test-ApplicationBinding',
      'Test-ApplicationState',
      'Uninstall-ApplicationFileAdapterFolders'
   )
   VariablesToExport     = @()
   PrivateData           = @{
      PSData = @{
         Tags                       = @('be.stateless.be', 'icraftsoftware', 'Application', 'BizTalk', 'Deployment', 'Declarative', 'SQL')
         LicenseUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment/blob/master/LICENSE'
         ProjectUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment'
         ExternalModuleDependencies = @('BizTalk.Administration', 'Dsl.Configuration', 'Exec', 'Gac', 'InvokeBuild', 'Resource.Manifest', 'Psx', 'SqlServer')
         Prerelease                 = 'preview'
      }
   }
}
