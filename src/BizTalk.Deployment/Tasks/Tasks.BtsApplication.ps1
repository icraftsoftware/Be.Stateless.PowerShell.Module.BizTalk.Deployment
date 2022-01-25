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

# Synopsis: Create a Microsoft BizTalk Server Application
task Add-BizTalkApplication -If { -not $SkipSharedResources } `
   Remove-BizTalkApplication, `
   Add-BizTalkApplicationIfNonExistent

# Synopsis: Create a Microsoft BizTalk Server Application with References to Its Dependant Microsoft BizTalk Server Applications if It Does Not Already Exist
task Add-BizTalkApplicationIfNonExistent -If { Test-ManifestApplication -Absent } {
   $Manifest.Properties.WeakReference | ForEach-Object -Process { Assert-BizTalkApplication -Name $_ }
   $arguments = @{ Name = $ApplicationName }
   if (![string]::IsNullOrWhiteSpace($Manifest.Properties.Description)) {
      $arguments.Description = $Manifest.Properties.Description
   }
   if ($Manifest.Properties.Reference | Test-Any) {
      Write-Build DarkGreen "Adding Microsoft BizTalk Server Application '$ApplicationName' with References to Microsoft BizTalk Server Applications '$($Manifest.Properties.Reference -join ''', ''')'"
      $arguments.Reference = $Manifest.Properties.Reference
   } else {
      Write-Build DarkGreen "Adding Microsoft BizTalk Server Application '$ApplicationName'"
   }
   New-BizTalkApplication @arguments | Out-Null
}

# Synopsis: Delete a Microsoft BizTalk Server Application
task Remove-BizTalkApplication -If { (-not $SkipSharedResources) -and (Test-ManifestApplication) } {
   Write-Build DarkGreen "Removing Microsoft BizTalk Server Application '$ApplicationName'"
   Remove-BizTalkApplication -Name $ApplicationName
}

# Synopsis: Start a Microsoft BizTalk Server Application
# the task is not named Start-BizTalkApplication to avoid a clash with the eponymous function is BizTalk.Administration module
task Start-Application -If { (-not $SkipSharedResources) -and (Test-ManifestApplication) } {
   Write-Build DarkGreen "Starting Microsoft BizTalk Server Application '$ApplicationName'"
   Get-ResourceGroup -Name Bindings | ForEach-Object -Process {
      $arguments = ConvertTo-ApplicationBindingCmdletArguments -Binding $_
      $arguments.InitializationOption = $InitializationOption
      Initialize-ApplicationState @arguments
   }
}

# Synopsis: Stop a Microsoft BizTalk Server Application
# the task is not named Stop-BizTalkApplication to avoid a clash with the eponymous function is BizTalk.Administration module
task Stop-Application -If { (-not $SkipSharedResources) -and (Test-ManifestApplication) } {
   Write-Build DarkGreen "Stopping Microsoft BizTalk Server Application '$ApplicationName'"
   Stop-BizTalkApplication -Name $ApplicationName -TerminateServiceInstances:$TerminateServiceInstances
}

function Test-ManifestApplication {
   [CmdletBinding()]
   [OutputType([bool])]
   param(
      [Parameter(Mandatory = $false)]
      [switch]
      $Absent
   )
   $Manifest.Properties.Type -eq 'Application' -and $Absent.IsPresent -eq -not(Test-BizTalkApplication -Name $ApplicationName)
}
