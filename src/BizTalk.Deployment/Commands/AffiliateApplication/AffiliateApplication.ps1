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

<#
.SYNOPSIS
   Gets the affiliate applications defined in the Enterprise Single Sign-On (SSO) server database.
.DESCRIPTION
   Gets the affiliate applications defined in the Enterprise Single Sign-On (SSO) server database. If no name is given, then this command gets the SSO affiliate
   applications that have been created thanks to BizTalk.Factory's Settings API, i.e. Be.Stateless.BizTalk.Settings.Sso.AffiliateApplication class contained in the
   Be.Stateless.BizTalk.Settings assembly. If the '*' wildcard is given, then this command returns all the SSO affiliate applications defined in the Enterprise Single
   Sign-On (SSO) server database, regardless of whether the affiliate application has been defined thanks to BizTalk.Factory API.
.PARAMETER AffiliateApplicationName
   The optional name of the affiliate application to return. The wildcard '*' can be passed to return all the affiliate applications defined in the Enterprise
   Single Sign-On (SSO) server database.
.OUTPUTS
   The created affiliate applications.
.EXAMPLE
   PS> Get-AffiliateApplication

   Returns all the affiliate applications that have been created by the BizTalk.Factory's Settings API.
.EXAMPLE
   PS> Get-AffiliateApplication -Name *

   Returns all the affiliate applications regardless of whether they have been created by the BizTalk.Factory's Settings API.
.EXAMPLE
   PS> Get-AffiliateApplication -Name BizTalk.Factory, BizTalk.Factory.Batching

   Returns the affiliate applications that have the given names, regardless of whether they have been created by the BizTalk.Factory's Settings API.
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/AffiliateApplicationCommands.html
.NOTES
   © 2022 be.stateless.
#>
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

<#
.SYNOPSIS
   Gets the config stores associated to an affiliate application from the Enterprise Single Sign-On (SSO) server database.
.DESCRIPTION
   Gets either the default or any config stores associated to an affiliate application from the Enterprise Single Sign-On (SSO) server database.
.PARAMETER AffiliateApplicationName
   The name of the affiliate application.
.PARAMETER Any
   Whether to return any config store associated to an affiliate application; only the default one otherwise.
.OUTPUTS
   The config store associated to an affiliate application.
.EXAMPLE
   PS> Get-AffiliateApplicationStore -Name 'BizTalk.Factory'
.EXAMPLE
   PS> Get-AffiliateApplicationStore -Name 'BizTalk.Factory' -Any
.EXAMPLE
   PS> New-AffiliateApplication -Name Test
   PS> $s = Get-AffiliateApplicationStore -Name Test
   PS> $s.Properties['Name'] = 'Value'
   PS> $s.Save()
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/AffiliateApplicationCommands.html
.NOTES
   © 2022 be.stateless.
#>
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

<#
.SYNOPSIS
   Creates a new affiliate application in the Enterprise Single Sign-On (SSO) server database.
.DESCRIPTION
   Creates a new affiliate application in the Enterprise Single Sign-On (SSO) server database and configure its administrator and user privileges.
.PARAMETER AffiliateApplicationName
   The name of the affiliate application to create. The name cannot contain any space.
.PARAMETER AdministratorGroup
   The optional name of the group that has administrator privilege on the affiliate application. It defaults to the local group 'BizTalk Server Administrators'.
.PARAMETER UserGroup
   The optional name of the group that has user privilege on the affiliate application. It defaults to the local groups 'BizTalk Application Users' and 'BizTalk
   Isolated Host Users'.
.OUTPUTS
   The newly created affiliate application.
.EXAMPLE
   PS> New-AffiliateApplication -Name 'BizTalk.Factory'
.EXAMPLE
   PS> New-AffiliateApplication -Name 'BizTalk.Factory' -AdministratorGroup 'BizTalk Server Administrators' -UserGroup 'BizTalk Application Users', 'BizTalk Isolated Host Users'
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/AffiliateApplicationCommands.html
.NOTES
   © 2022 be.stateless.
#>
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

<#
.SYNOPSIS
   Deletes an affiliate application from the Enterprise Single Sign-On (SSO) server database.
.DESCRIPTION
   Deletes an affiliate application from the Enterprise Single Sign-On (SSO) server database.
.PARAMETER AffiliateApplicationName
   The name of the affiliate application to delete.
.EXAMPLE
   PS> Remove-AffiliateApplication -Name 'BizTalk.Factory'
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/AffiliateApplicationCommands.html
.NOTES
   © 2022 be.stateless.
#>
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

<#
.SYNOPSIS
   Updates the properties and their values stored in the default config store of an affiliate application from the Enterprise Single Sign-On (SSO) server database.
.DESCRIPTION
   Updates the properties and values with the [SsoSetting] attribute qualified properties and values that are defined by the IEnvironmentSettings-derived type contained
   in the .NET assembly located at EnvironmentSettingsAssemblyFilePath for a given TargetEnvironment. The primary intended use of this command is by the deployment
   tasks coming with the BizTalk.Deployment module.
.PARAMETER AffiliateApplicationName
   The name of the affiliate application.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET assembly containing the Code-First Microsoft BizTalk Server
   Application Bindings.
.PARAMETER EnvironmentSettingsAssemblyFilePath
   The path to the .NET assembly containing the IEnvironmentSettings-derived type that defines the properties and their values to update the default config store
   of the affiliate application with.
.PARAMETER EnvironmentSettingOverridesTypeName
   Optional full name of the type overriding the default settings upon which the application binding assembly depends.
.PARAMETER Isolated
   Whether to load the .NET assembly containing the IEnvironmentSettings-derived type in a separate process so as not to lock it.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones suggested in accordance to BizTalk.Factory
   Conventions are accepted.
.OUTPUTS
   The config store that has been updated.
.EXAMPLE
   PS> Update-AffiliateApplicationStore -Name 'BizTalk.Factory'
.EXAMPLE
   PS> Update-AffiliateApplicationStore -Name 'BizTalk.Factory' -EnvironmentSettingsAssemblyFilePath .\Be.Stateless.BizTalk.Factory.Application.Deployment\Be.Stateless.BizTalk.Factory.Settings.dll -TargetEnvironment ACC
.LINK
   https://www.stateless.be/PowerShell/Module/BizTalk/Deployment/AffiliateApplicationCommands.html
.NOTES
   © 2022 be.stateless.
#>
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
