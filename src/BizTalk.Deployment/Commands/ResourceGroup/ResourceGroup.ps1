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
      [ValidateNotNullOrEmpty()]
      [string]
      $PseudoName
   )
   if (-not [string]::IsNullOrWhiteSpace($PseudoName) -and -not (Test-PseudoResourceGroup -Name $PseudoName)) {
      @()
   } elseif (-not(Test-ResourceGroup -Name $Name)) {
      @()
   } else {
      if ([string]::IsNullOrWhiteSpace($PseudoName)) {
         Write-Verbose -Message "Processing ResourceGroup '$Name'."
      } else {
         Write-Verbose -Message "Processing Pseudo ResourceGroup '$PseudoName' Through ResourceGroup '$Name'."
      }
      @($Manifest.$Name | Where-Object { -not(Get-Member -InputObject $_ -Name Condition) -or $_.Condition() })
   }
}

function Test-ResourceGroup {
   [CmdletBinding()]
   [OutputType([bool])]
   param(
      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name
   )
   if (-not $Manifest.ContainsKey($Name)) {
      Write-Verbose -Message "No ResourceGroup '$Name' found."
      $false
   } elseif ($ExcludeResourceGroup | Where-Object -FilterScript { $Name -like $_ } | Test-Any) {
      Write-Verbose -Message "Excluding ResourceGroup '$Name'."
      $false
   } else {
      $true
   }
}

function Test-PseudoResourceGroup {
   [CmdletBinding()]
   [OutputType([bool])]
   param(
      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name
   )
   if ($ExcludeResourceGroup | Where-Object -FilterScript { $Name -like $_ } | Test-Any) {
      Write-Verbose -Message "Excluding Pseudo ResourceGroup '$Name'."
      $false
   } else {
      $true
   }
}
