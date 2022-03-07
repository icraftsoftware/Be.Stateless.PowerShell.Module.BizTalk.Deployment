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

# Synopsis: Restart the Microsoft BizTalk Server Host Instances of either a BizTalk Application or the BizTalk Group
task Restart-BizTalkHostInstances -If { (-not $SkipHostInstanceRestart) -and (-not $SkipSharedResources) -and (Test-PseudoResourceGroup -Name BizTalkHostInstances) } `
   Restart-BizTalkHostInstancesForApplication, `
   Restart-BizTalkHostInstancesForGroup

# Synopsis: Restart the Microsoft BizTalk Server Host Instances of a BizTalk Application
task Restart-BizTalkHostInstancesForApplication -If { Test-ResourceGroup -Name Bindings } {
   Get-ResourceGroup -Name Bindings -PseudoName BizTalkHostInstances | ForEach-Object -Process {
      $arguments = ConvertTo-ApplicationBindingCmdletArguments -Binding $_
      Get-ApplicationHosts @arguments | ForEach-Object -Process {
         Get-BizTalkHost -Name $_ | Where-Object -FilterScript { Test-BizTalkHost -Host $_ -Type InProcess } | Get-BizTalkHostInstance | ForEach-Object -Process {
            Write-Build DarkGreen "Host Instance '$($_.HostName)' on '$($_.RunningServer)'"
            Restart-BizTalkHostInstance -HostInstance $_
         }
      }
   }
}

# Synopsis: Restart the Microsoft BizTalk Server Host Instances of the BizTalk Group
task Restart-BizTalkHostInstancesForGroup -If { -not(Test-ResourceGroup -Name Bindings) } {
   Get-BizTalkHost | Where-Object -FilterScript { Test-BizTalkHost -Host $_ -Type InProcess } | Get-BizTalkHostInstance | ForEach-Object -Process {
      Write-Build DarkGreen "Host Instance '$($_.HostName)' on '$($_.RunningServer)'"
      Restart-BizTalkHostInstance -HostInstance $_
   }
}
