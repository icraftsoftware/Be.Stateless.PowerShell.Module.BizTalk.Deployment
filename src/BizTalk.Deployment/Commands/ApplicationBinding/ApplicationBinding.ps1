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
   Converts Code-First BizTalk Application Bindings to XML.
.DESCRIPTION
   Loads an .NET assembly containing the BizTalk Application Bindings written in BizTalk.Factory's C#-embedded Domain
   Specific Languages (DSL) and converts them to XML.
.PARAMETER ApplicationBindingAssemblyFilePath
   The path of the .NET assembly containing the Code-First BizTalk Application Bindings.
.PARAMETER AssemblyProbingFolderPath
   Optional list of folders where to look into for .NET assemblies required to load the .NET application binding
   assembly and output the XML BizTalk Application Bindings.
.PARAMETER EnvironmentSettingOverridesTypeName
.PARAMETER Isolated
   Whether to load the .NET application binding assembly in a separate process in order not to lock the .NET
   application binding assembly.
.PARAMETER OutputFilePath
   Path of the generated file that will contain the XML BizTalk Application Bindings.
.PARAMETER TargetEnvironment
   The target environment for which to produce the XML BizTalk Application Bindings. Other values than the ones
   suggested in accordance to BizTalk Factory Conventions are accepted.
.EXAMPLE
   PS> Convert-ApplicationBinding -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Batching.Binding.dll -OutputFilePath Bindings.xml -TargetEnvironment DEV

   Silently converts the .NET application binding assembly to XML.
.EXAMPLE
   PS> Convert-ApplicationBinding -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -OutputFilePath Bindings.xml -TargetEnvironment DEV -InformationAction Continue -Verbose

   Converts the .NET application binding assembly to XML and provides detailed information during the process.
.EXAMPLE
   PS> Convert-ApplicationBinding -ApplicationBindingAssemblyFilePath Be.Stateless.BizTalk.Factory.Activity.Tracking.Binding.dll -OutputFilePath Bindings.xml -TargetEnvironment DEV -Isolated -InformationAction Continue -Verbose

   Converts the .NET application binding assembly to XML in a separate process and provides detailed information
   during the process.
.NOTES
   © 2022 be.stateless.
#>
function Convert-ApplicationBinding {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Alias('Destination')]
      [Parameter(Position = 1, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $OutputFilePath,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Conversion of Code-First BizTalk Application Bindings to XML to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Convert-CoreApplicationBinding @using:arguments
      }
   } else {
      Convert-CoreApplicationBinding @arguments
   }
}

function Expand-ApplicationBinding {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $InputFilePath,

      [Alias('Destination')]
      [Parameter(Position = 1, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $OutputFilePath,

      [Parameter(Mandatory = $false)]
      [switch]
      $Trim
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   Expand-CoreApplicationBinding @PSBoundParameters
}

function Get-ApplicationHosts {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

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
      Write-Information 'Dispatching Enumeration of BizTalk Hosts Bound by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Get-CoreApplicationHosts @using:arguments
      }
   } else {
      Get-CoreApplicationHosts @arguments
   }
}

function Initialize-ApplicationState {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Alias('Options')]
      [Parameter(Mandatory = $false)]
      [Be.Stateless.BizTalk.Dsl.Binding.Visitor.BizTalkServiceInitializationOptions]
      $InitializationOption = @('All'),

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
      Write-Information 'Dispatching Initialization of BizTalk Services'' State to that Defined by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Initialize-CoreApplicationState @using:arguments
      }
   } else {
      Initialize-CoreApplicationState @arguments
   }
}

function Install-ApplicationFileAdapterFolders {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

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
      $TargetEnvironment,

      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $User
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Creation of Folders for File Adapters Defined by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Install-CoreApplicationFileAdapterFolders @using:arguments
      }
   } else {
      Install-CoreApplicationFileAdapterFolders @arguments
   }
}

function Test-ApplicationBinding {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

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
      Write-Information 'Dispatching Code-First BizTalk Application Bindings Validity Test to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Test-CoreApplicationBinding @using:arguments
      }
   } else {
      Test-CoreApplicationBinding @arguments
   }
}

function Test-ApplicationState {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

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
      Write-Information 'Dispatching Correspondence Test of BizTalk Services'' State to that Defined by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Test-CoreApplicationState @using:arguments
      }
   } else {
      Test-CoreApplicationState @arguments
   }
}

function Uninstall-ApplicationFileAdapterFolders {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Alias('Path')]
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
      [string]
      $ApplicationBindingAssemblyFilePath,

      [Alias('ProbingPath')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({ $_ | Test-Path -PathType Container })]
      [string[]]
      $AssemblyProbingFolderPath,

      [Alias('SettingsTypeName')]
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $EnvironmentSettingOverridesTypeName,

      [Parameter(Mandatory = $false)]
      [switch]
      $Isolated,

      [Parameter(Mandatory = $false)]
      [switch]
      $Recurse,

      [Alias('Environment')]
      [Parameter(Position = 2, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $TargetEnvironment
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

   $arguments = Get-CoreCommandArguments $PSBoundParameters
   if ($Isolated) {
      Write-Information 'Dispatching Deletion of Folders for File Adapters Defined by Code-First BizTalk Application Bindings to Isolated Process...'
      Invoke-Command -ComputerName $env:COMPUTERNAME -UseSSL -ScriptBlock {
         Import-Module $using:coreModulePath
         Uninstall-CoreApplicationFileAdapterFolders @using:arguments
      }
   } else {
      Uninstall-CoreApplicationFileAdapterFolders @arguments
   }
}

<#
 # Argument Completers
 #>

Register-ArgumentCompleter -ParameterName TargetEnvironment -ScriptBlock {
   param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
   @('DEV', 'BLD', 'INT', 'ACC', 'PRE', 'PRD') | Where-Object -FilterScript { $_ -like "$wordToComplete*" }
}
