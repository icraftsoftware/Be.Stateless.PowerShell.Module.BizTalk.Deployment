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

[CmdletBinding(DefaultParameterSetName = 'manifest-path')]
[OutputType([void])]
param(
   [Parameter(Mandatory = $true, ParameterSetName = 'manifest-object')]
   [ValidateNotNullOrEmpty()]
   [ValidateScript( { $_.Properties.Type -eq 'Application' } )]
   [HashTable[]]
   $Manifest,

   [Parameter(Mandatory = $true, ParameterSetName = 'manifest-path')]
   [ValidateNotNullOrEmpty()]
   [ValidateScript( { Test-Path -Path $_ -PathType Leaf } )]
   [string[]]
   $Path,

   [Parameter(Mandatory = $true, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $true, ParameterSetName = 'manifest-path')]
   [ValidateNotNullOrEmpty()]
   [string]
   $TargetEnvironment,

   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-path')]
   [scriptblock[]]
   $Task = ([scriptblock] { }),

   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-path')]
   [ValidateNotNullOrEmpty()]
   [string[]]
   $ExcludeResourceGroup = @(),

   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-path')]
   [ValidateNotNullOrEmpty()]
   [string[]]
   $ExcludeTask = @(),

   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-path')]
   [switch]
   $Isolated = ($TargetEnvironment -eq 'DEV'),

   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-path')]
   [switch]
   $SkipFileAdapterFolders,

   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-path')]
   [switch]
   $SkipHostInstanceRestart,

   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-path')]
   [switch]
   $SkipSharedResources,

   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-object')]
   [Parameter(Mandatory = $false, ParameterSetName = 'manifest-path')]
   [switch]
   $TerminateServiceInstances
)
begin {
   Set-StrictMode -Version Latest
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
}
process {
   $script:Manifest = switch ($PsCmdlet.ParameterSetName) {
      'manifest-object' { $Manifest }
      'manifest-path' { & $Path }
   }
   if ($script:Manifest.Properties.Type -ne 'Application') {
      throw "This command does not support this type of manifest '$($script:Manifest.Properties.Type)'."
   }

   $script:SkipUninstall = $false
   try {
      $taskBlockList = $Task # don't clash with InvokeBuild's $Task variable
      Invoke-Build Undeploy {
         . BizTalk.Deployment.Tasks
         foreach ($taskBlock in $taskBlockList) {
            . $taskBlock
         }
      }
   } catch {
      Write-Error $_.Exception.ToString()
      throw
   }
}
