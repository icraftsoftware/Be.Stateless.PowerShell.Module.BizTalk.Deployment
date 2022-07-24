#region Copyright & License

# Copyright © 2020 - 2022 François Chabot
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
   RootModule            = 'Be.Stateless.BizTalk.Deployment.Cmdlets.dll'
   ModuleVersion         = '2.1.0.0'
   GUID                  = '8b15c2dc-4161-4c09-8409-2789beb0299b'
   Author                = 'François Chabot'
   CompanyName           = 'be.stateless'
   Copyright             = '(c) 2020 - 2022 be.stateless. All rights reserved.'
   Description           = 'PowerShell commands assisting BizTalk.Deployment module in operating SSO Stores and BizTalk.Factory C#-embedded Domain Specific Languages (DSL) dedicated to Microsoft BizTalk Server.'
   ProcessorArchitecture = 'None'
   PowerShellVersion     = '5.0'
   NestedModules         = @()
   RequiredAssemblies    = @(
      '.\Be.Stateless.BizTalk.Dsl.Abstractions.dll',
      '.\Be.Stateless.BizTalk.Dsl.Binding.Conventions.dll',
      '.\Be.Stateless.BizTalk.Dsl.Binding.dll',
      '.\Be.Stateless.BizTalk.Dsl.Environment.Settings.dll',
      '.\Be.Stateless.BizTalk.Dsl.Pipeline.dll',
      '.\Be.Stateless.BizTalk.Explorer.dll',
      '.\Be.Stateless.BizTalk.Settings.dll',
      '.\Be.Stateless.Dsl.Configuration.dll'
   )
   RequiredModules       = @()
   AliasesToExport       = @()
   CmdletsToExport       = @(
      # AffiliateApplication
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
   FunctionsToExport     = @()
   VariablesToExport     = @()
   PrivateData           = @{
      PSData = @{
         Tags       = @('be.stateless', 'icraftsoftware', 'Application', 'BizTalk', 'Deployment', 'DSL', 'Bindings', 'SSO')
         LicenseUri = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment/blob/master/LICENSE'
         ProjectUri = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Deployment'
         IconUri    = 'https://github.com/icraftsoftware/Be.Stateless.Build.Scripts/raw/master/nuget.png'
         Prerelease = 'preview'
      }
   }
   DefaultCommandPrefix  = 'Core'
}
