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

# Synopsis: Deploy Microsoft BizTalk Server Application Bindings
task Deploy-Bindings -If { -not $SkipSharedResources } `
   Convert-Bindings, `
   Import-Bindings

# Synopsis: Convert Fluent Application Bindings to XML Application Bindings
task Convert-Bindings {
   $Resources | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      $arguments = ConvertTo-ApplicationBindingCmdletArguments -Binding $_
      Convert-ApplicationBinding @arguments -OutputFilePath "$($_.Path).xml"
   }
}

# Synopsis: Import Microsoft BizTalk Server Application Bindings
task Import-Bindings {
   $Resources | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      Invoke-Tool -Command { BTSTask AddResource -ApplicationName:`"$ApplicationName`" -Type:BizTalkBinding -Overwrite -Source:`"$($_.Path).xml`" }
      Invoke-Tool -Command { BTSTask ImportBindings -ApplicationName:`"$ApplicationName`" -Source:`"$($_.Path).xml`" }
   }
}

# Synopsis: Create FILE Adapter-based Receive Locations' and Send Ports' Folders
task Deploy-FileAdapterFolders {
   Get-ResourceGroup -Name Bindings | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      $arguments = ConvertTo-ApplicationBindingCmdletArguments -Binding $_
      Install-ApplicationFileAdapterFolders @arguments -User $FileUser
   }
}
# Synopsis: Remove FILE Adapter-based Receive Locations' and Send Ports' Folders
task Undeploy-FileAdapterFolders -If { -not $SkipUninstall } {
   Get-ResourceGroup -Name Bindings | ForEach-Object -Process {
      Write-Build DarkGreen $_.Path
      $arguments = ConvertTo-ApplicationBindingCmdletArguments -Binding $_
      Uninstall-ApplicationFileAdapterFolders @arguments -Recurse
   }
}
