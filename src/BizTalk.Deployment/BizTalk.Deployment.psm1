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

<#
 # Main
 #>

# https://github.com/nightroman/Invoke-Build/tree/master/Tasks
# https://github.com/nightroman/Invoke-Build/tree/master/Tasks/Import
# https://github.com/nightroman/Invoke-Build/issues/73, Importing Tasks
Set-Alias -Name BizTalk.Deployment.Tasks -Value $PSScriptRoot/Tasks/Tasks.ps1
Set-Alias -Name Install-BizTalkApplication $PSScriptRoot/Scripts/Install-BizTalkApplication.ps1
Set-Alias -Name Install-BizTalkLibrary $PSScriptRoot/Scripts/Install-BizTalkLibrary.ps1
Set-Alias -Name Uninstall-BizTalkApplication $PSScriptRoot/Scripts/Uninstall-BizTalkApplication.ps1
Set-Alias -Name Uninstall-BizTalkLibrary $PSScriptRoot/Scripts/Uninstall-BizTalkLibrary.ps1

Add-ToolAlias -Path (Join-Path -Path ($env:BTSINSTALLPATH) -ChildPath Tracking) -Tool BM -Scope Global
# https://docs.microsoft.com/en-us/biztalk/core/btstask-command-line-reference
# https://docs.microsoft.com/en-us/biztalk/core/managing-resources
Add-ToolAlias -Path ($env:BTSINSTALLPATH) -Tool BTSTask -Scope Global
Add-ToolAlias -Path 'Framework\v4.0.30319' -Tool InstallUtil -Scope Global
Add-ToolAlias -Path 'Framework64\v4.0.30319' -Tool RegSvcs -Scope Global
