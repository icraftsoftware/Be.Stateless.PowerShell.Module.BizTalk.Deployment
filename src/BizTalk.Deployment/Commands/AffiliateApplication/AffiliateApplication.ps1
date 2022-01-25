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

function Get-AffiliateApplication {
   [CmdletBinding()]
   [OutputType([AffiliateApplication[]])]
   param(
      [Alias('Name')]
      [Parameter(Position = 0, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $AffiliateApplicationName
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   if ([string]::IsNullOrEmpty($AffiliateApplicationName)) {
      [AffiliateApplication]::FindByContact()
   } elseif ($AffiliateApplicationName -eq [AffiliateApplication]::ANY_CONTACT_INFO) {
      [AffiliateApplication]::FindByContact([AffiliateApplication]::ANY_CONTACT_INFO)
   } else {
      [AffiliateApplication]::FindByName($AffiliateApplicationName)
   }
}

function Get-AffiliateApplicationStore {
   [CmdletBinding()]
   [OutputType([ConfigStore[]])]
   param(
      [Alias('Name')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $AffiliateApplicationName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Any
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   Get-AffiliateApplication -AffiliateApplicationName $AffiliateApplicationName | ForEach-Object -Process {
      if ($Any) {
         $_.ConfigStores
      } else {
         $_.ConfigStores.Default
      }
   }
}

function New-AffiliateApplication {
   [CmdletBinding()]
   [OutputType([AffiliateApplication])]
   param(
      [Alias('Name')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $AffiliateApplicationName,

      [Parameter(Position = 1, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $AdministratorGroup,

      [Parameter(Position = 1, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $UserGroup
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $affiliateApplication = [AffiliateApplication]::FindByName($AffiliateApplicationName)
   if ($null -eq $affiliateApplication) {
      $affiliateApplication = [AffiliateApplication]::Create($AffiliateApplicationName, $AdministratorGroup, $UserGroup)
   } else {
      Write-Warning "SSO Affiliate Application $AffiliateApplicationName already exists."
   }
   $affiliateApplication
}

function Remove-AffiliateApplication {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Name')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $AffiliateApplicationName
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $affiliateApplication = [AffiliateApplication]::FindByName($AffiliateApplicationName)
   if ($null -eq $affiliateApplication) {
      Write-Warning "SSO Affiliate Application $AffiliateApplicationName does not exist."
   } else {
      $affiliateApplication.Delete()
   }
}

function Update-AffiliateApplicationStore {
   [CmdletBinding()]
   [OutputType([ConfigStore])]
   param(
      [Alias('Name')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $AffiliateApplicationName,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('Path')]
      [Parameter(Position = 1, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $EnvironmentSettingsAssemblyFilePath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information "Dispatching Update of SSO AffiliateApplication '$AffiliateApplicationName''s ConfigStore to Isolated Process..."
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Update-CoreAffiliateApplicationStore @using:arguments
      }
   } else {
      Update-CoreAffiliateApplicationStore @arguments
   }
}

<#
 # Argument Completers
 #>

Register-ArgumentCompleter -CommandName Get-AffiliateApplication, Get-AffiliateApplicationStore -ParameterName AffiliateApplicationName -ScriptBlock {
   param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
   @('*') + $([AffiliateApplication]::FindByContact('*').Name) | Where-Object -FilterScript { $_ -match $wordToComplete } | ForEach-Object -Process { "'$_'" }
}

Register-ArgumentCompleter -CommandName Remove-AffiliateApplication, Update-AffiliateApplicationStore -ParameterName AffiliateApplicationName -ScriptBlock {
   param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
   # forbid to remove or update all AffiliateApplication, so don't return '*' as an argument candidate;
   # forbid to remove or update an AffiliateApplication that has not been created by Be.Stateless.BizTalk.Settings, so call FindByContact()
   # which uses the DEFAULT_CONTACT_INFO (i.e. "icraftsoftware@stateless.be") and do not call FindByContact('*')
   $([AffiliateApplication]::FindByContact().Name) | Where-Object -FilterScript { $_ -match $wordToComplete } | ForEach-Object -Process { "'$_'" }
}

<#
 # Type Accelerators
 #>

$Accelerators = [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
$Accelerators::Add('AffiliateApplication', 'Be.Stateless.BizTalk.Settings.Sso.AffiliateApplication')
$Accelerators::Add('ConfigStore', 'Be.Stateless.BizTalk.Settings.Sso.AffiliateApplication')
