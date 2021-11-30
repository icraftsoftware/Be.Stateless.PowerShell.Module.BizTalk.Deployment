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
   RequiredModules       = @(
      @{ ModuleName = 'BizTalk.Administration'; ModuleVersion = '1.0.21335.24644'; GUID = 'de802b43-c7a6-4580-a34b-ac805bbf813e' }
      @{ ModuleName = 'Dsl.Configuration'; ModuleVersion = '2.0.21333.44731'; GUID = '99128609-dd5b-43d7-b834-6bc0ca537f02' }
      @{ ModuleName = 'Exec'; ModuleVersion = '1.0.21335.23673'; GUID = '83f4143a-79ee-49ee-a510-7770a0fc1644' }
      @{ ModuleName = 'Gac'; ModuleVersion = '1.0.1'; GUID = '2f3a501f-882b-43c4-aaeb-3ffc9fea932c' }
      @{ ModuleName = 'InvokeBuild'; ModuleVersion = '5.8.6'; GUID = 'a0319025-5f1f-47f0-ae8d-9c7e151a5aae' }
      @{ ModuleName = 'Resource.Manifest'; ModuleVersion = '1.0.21335.24779'; GUID = '07e35b0e-3441-46b4-82e6-d8daafb837bd' }
      @{ ModuleName = 'Psx'; ModuleVersion = '1.0.21284.43438'; GUID = '217de01f-f2e1-460a-99a4-b8895d0dd071' }
      @{ ModuleName = 'SqlServer'; ModuleVersion = '21.1.18256'; GUID = '97c3b589-6545-4107-a061-3fe23a4e9195' }
   )

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
