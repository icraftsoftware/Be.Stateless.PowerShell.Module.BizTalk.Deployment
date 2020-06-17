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

@{
   RootModule            = 'BizTalk.Deployment.psm1'
   ModuleVersion         = '2.0.0.0'
   GUID                  = '533b5f59-49ce-4f51-a293-cb78f5cf81b5'
   Author                = 'François Chabot'
   CompanyName           = 'be.stateless'
   Copyright             = '(c) 2020 be.stateless. All rights reserved.'
   Description           = 'Commands to deploy Microsoft BizTalk Server Applications supported by a deployment framework featuring a declarative task model.'
   ProcessorArchitecture = 'None'
   PowerShellVersion     = '5.0'
   NestedModules         = @(
      'Application\Application.psm1',
      'Assembly\Assembly.psm1',
      'Bindings\Bindings.psm1',
      'Component\Component.psm1',
      'Resource\Resource.psm1'
   )
   RequiredAssemblies    = @()
   RequiredModules       = @('BizTalk.Administration', 'Exec', 'Gac', 'InvokeBuild', 'Resource.Manifest', 'SQLPS')

   AliasesToExport       = @('BizTalk.Deployment.Tasks')
   CmdletsToExport       = @()
   FunctionsToExport     = @('Install-BizTalkApplication', 'Uninstall-BizTalkApplication')
   VariablesToExport     = @()
}
