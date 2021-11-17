﻿#region Copyright & License

# Copyright © 2012 - 2021 François Chabot
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

# Synopsis: Register Microsoft BizTalk Server Process Descriptors
task Register-ProcessDescriptors -If { -not $SkipSharedResources } {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        Invoke-Tool -Command { InstallUtil /ShowCallStack /DataSource=`"$((Get-BizTalkGroupSettings).MgmtDbServerName)`" `"$($_.Path)`" }
    }
}

# Synopsis: Unregister Microsoft BizTalk Server Process Descriptors
task Unregister-ProcessDescriptors -If { (-not $SkipUninstall) -and (-not $SkipSharedResources) } {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        Invoke-Tool -Command { InstallUtil /uninstall /ShowCallStack /DataSource=`"$((Get-BizTalkGroupSettings).MgmtDbServerName)`" `"$($_.Path)`" }
    }
}
