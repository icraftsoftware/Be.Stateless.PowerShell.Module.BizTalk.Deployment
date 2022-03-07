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

# Synopsis: Create FILE Adapter-based Receive Locations' and Send Ports' Folders
task Deploy-FileAdapterFolders -If { -not $SkipFileAdapterFolders -and (Test-PseudoResourceGroup -Name FileAdapterFolders) } {
   Get-ResourceGroup -Name Bindings -PseudoName FileAdapterFolders | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      $arguments = ConvertTo-ApplicationBindingCmdletArguments -Binding $_
      Install-ApplicationFileAdapterFolders @arguments -User $FileUser
   }
}
# Synopsis: Remove FILE Adapter-based Receive Locations' and Send Ports' Folders
task Undeploy-FileAdapterFolders -If { -not $SkipFileAdapterFolders -and -not $SkipUninstall -and (Test-PseudoResourceGroup -Name FileAdapterFolders) } {
   Get-ResourceGroup -Name Bindings -PseudoName FileAdapterFolders | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      $arguments = ConvertTo-ApplicationBindingCmdletArguments -Binding $_
      Uninstall-ApplicationFileAdapterFolders @arguments -Recurse
   }
}
