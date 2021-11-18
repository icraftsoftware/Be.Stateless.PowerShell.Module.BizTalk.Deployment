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

# Synopsis: Register and install .NET Service Components
task Deploy-ServiceComponents {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        Invoke-Tool -Command { RegSvcs `"$($_.Path)`" }
    }
}

# Synopsis: Uninstall and unregister .NET Service Components
task Undeploy-ServiceComponents {
    $Resources | ForEach-Object -Process {
        Write-Build DarkGreen $_.Path
        try {
            Invoke-Tool -Command { RegSvcs /exapp `"$($_.Path)`" }
        }
        catch {
            if( $LASTEXITCODE -eq 1 ){ return }
        }
        Invoke-Tool -Command { RegSvcs /u `"$($_.Path)`" }
    }
}
