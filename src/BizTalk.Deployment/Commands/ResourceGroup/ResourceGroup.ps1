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

function Get-ResourceGroup {
   [CmdletBinding()]
   [OutputType([PSCustomObject[]])]
   param(
      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Mandatory = $false)]
      [switch]
      $ThrowOnError
   )
   if ($Manifest.ContainsKey($Name)) {
      if ($ExcludeResourceGroup -contains $Name) {
         Write-Verbose -Message "Exclude ResourceGroup '$Name' from Manifest."
         @()
      } else {
         Write-Verbose -Message "Get ResourceGroup '$Name' from Manifest."
         @($Manifest.$Name | Where-Object { -not(Get-Member -InputObject $_ -Name Condition) -or $_.Condition() })
      }
   } elseif ($ThrowOnError) {
      throw "ResourceGroup '$Name' not found in Manifest."
   } else {
      Write-Verbose -Message "No ResourceGroup '$Name' found in Manifest."
      @()
   }
}
