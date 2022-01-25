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

. $PSScriptRoot\Commands\AffiliateApplication\AffiliateApplication.ps1
. $PSScriptRoot\Commands\ApplicationBinding\ApplicationBinding.ps1
. $PSScriptRoot\Commands\CoreCommandParameters.ps1

<#
 # Main
 #>

# https://github.com/nightroman/Invoke-Build/tree/master/Tasks
# https://github.com/nightroman/Invoke-Build/tree/master/Tasks/Import
# https://github.com/nightroman/Invoke-Build/issues/73, Importing Tasks
Set-Alias -Option ReadOnly -Name BizTalk.Deployment.Tasks -Value $PSScriptRoot/Tasks/Tasks.ps1
Set-Alias -Option ReadOnly -Name Install-BizTalkApplication -Value $PSScriptRoot/Scripts/Install-BizTalkApplication.ps1
Set-Alias -Option ReadOnly -Name Install-BizTalkLibrary -Value $PSScriptRoot/Scripts/Install-BizTalkLibrary.ps1
Set-Alias -Option ReadOnly -Name Uninstall-BizTalkApplication -Value $PSScriptRoot/Scripts/Uninstall-BizTalkApplication.ps1
Set-Alias -Option ReadOnly -Name Uninstall-BizTalkLibrary -Value $PSScriptRoot/Scripts/Uninstall-BizTalkLibrary.ps1

Add-ToolAlias -Path (Join-Path -Path ($env:BTSINSTALLPATH) -ChildPath Tracking) -Tool BM -Scope Global -Force
# https://docs.microsoft.com/en-us/biztalk/core/btstask-command-line-reference
# https://docs.microsoft.com/en-us/biztalk/core/managing-resources
Add-ToolAlias -Path ($env:BTSINSTALLPATH) -Tool BTSTask -Scope Global -Force
Add-ToolAlias -Path 'Framework\v4.0.30319' -Tool InstallUtil -Scope Global -Force
Add-ToolAlias -Path 'Framework64\v4.0.30319' -Tool RegSvcs -Scope Global -Force

Register-ArgumentCompleter -ParameterName ExcludeResourceGroup -ScriptBlock {
   param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
   if ($fakeBoundParameters.ContainsKey('Manifest')) {
      $index = 2..$commandAst.CommandElements.Count | Where-Object -FilterScript {
         $commandAst.CommandElements[$_ - 1] -is [System.Management.Automation.Language.CommandParameterAst] -and $commandAst.CommandElements[$_ - 1].ParameterName -EQ 'Manifest'
      }
      if ($index -lt $commandAst.CommandElements.Count -and $commandAst.CommandElements[$index] -is [System.Management.Automation.Language.VariableExpressionAst]) {
         $fakeManifest = Get-Variable -Name $commandAst.CommandElements[$index].VariablePath -ValueOnly
      }
   } elseif ($fakeBoundParameters.ContainsKey('Path') -and (Test-Path -Path $fakeBoundParameters.Path -PathType Leaf)) {
      $fakeManifest = & $fakeBoundParameters.Path
   }
   if ($null -ne $fakeManifest) {
      $ignoredResourceGroups = @('Properties')
      if ($commandName -match "\-BizTalk$($fakeManifest.Properties.Type)\.ps1$") {
         $index = 2..$commandAst.CommandElements.Count | Where-Object -FilterScript {
            $commandAst.CommandElements[$_ - 1] -is [System.Management.Automation.Language.CommandParameterAst] -and $commandAst.CommandElements[$_ - 1].ParameterName -EQ 'ExcludeResourceGroup'
         }
         if ($index -lt $commandAst.CommandElements.Count) {
            $ignoredResourceGroups += @($commandAst.CommandElements[$index].NestedAst.Value)
         }
         @($fakeManifest.Keys | Where-Object { $_ -NotIn $ignoredResourceGroups } | Sort-Object)
      } else {
         @('<bad_manifest_type>')
      }
   }
}
Register-ArgumentCompleter -ParameterName TargetEnvironment -ScriptBlock {
   @('DEV', 'BLD', 'INT', 'ACC', 'PRE', 'PRD')
}

$script:coreModulePath = Join-Path -Path (Get-Module BizTalk.Deployment.Core).ModuleBase -ChildPath BizTalk.Deployment.Core.psd1
