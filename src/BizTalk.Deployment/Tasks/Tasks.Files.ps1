﻿#region Copyright & License

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

# Synopsis: Copy Files
task Deploy-Files {
   $Resources | ForEach-Object -Process {
      foreach ($destination in $_.Destination) {
         $arguments = @{
            LiteralPath = $_.Path
            Destination = Resolve-Destination -Source $_.Path -Destination $destination
         }
         Write-Build DarkGreen $arguments.Destination
         $directory = Split-Path -Path $arguments.Destination -Parent
         if (-not(Test-Path -LiteralPath $directory -PathType Container)) {
            New-Item -Path $directory -ItemType Directory -Force -Verbose:($VerbosePreference -eq 'Continue') | Out-Null
            if (-not(Test-Path -LiteralPath $directory -PathType Container)) {
               # https://github.com/PowerShell/PowerShell/issues/5290
               throw "Could not create directory '$directory' because a file at the same location already exists."
            }
         }
         Copy-Item @arguments -Force -Verbose:($VerbosePreference -eq 'Continue')
      }
   }
}

# Synopsis: Delete Files
task Undeploy-Files -If { -not $SkipUninstall } {
   $Resources | ForEach-Object -Process {
      foreach ($destination in $_.Destination) {
         $arguments = @{
            LiteralPath = Resolve-Destination -Source $_.Path -Destination $destination
         }
         Write-Build DarkGreen $arguments.LiteralPath
         if (Test-Path @arguments -PathType Container) {
            throw "Cannot undeploy a directory. '$($arguments.LiteralPath)' must be a file path."
         } elseif (Test-Path @arguments -PathType Leaf) {
            Remove-Item @arguments -Force -Verbose:($VerbosePreference -eq 'Continue')
         }
      }
   }
}

function Resolve-Destination {
   [CmdletBinding()]
   [OutputType([string])]
   param (
      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Source,

      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Destination
   )
   if ($Destination.EndsWith('\')) {
      Join-Path -Path $Destination -ChildPath (Split-Path -Path $Source -Leaf)
   } else {
      $Destination
   }
}
