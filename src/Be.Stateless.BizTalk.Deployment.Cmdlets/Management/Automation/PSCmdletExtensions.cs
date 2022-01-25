#region Copyright & License

// Copyright © 2012 - 2021 François Chabot
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#endregion

using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Management.Automation
{
	internal static class PSCmdletExtensions
	{
		internal static string ResolvePath(this PSCmdlet cmdlet, string psPath)
		{
			// see https://stackoverflow.com/questions/8505294/how-do-i-deal-with-paths-when-writing-a-powershell-cmdlet
			return psPath.IsNullOrEmpty()
				? null
				: cmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath(psPath);
		}

		internal static IEnumerable<string> ResolvePaths(this PSCmdlet cmdlet, string[] psPaths)
		{
			// see https://stackoverflow.com/questions/8505294/how-do-i-deal-with-paths-when-writing-a-powershell-cmdlet
			return psPaths == null
				? Array.Empty<string>()
				: psPaths.SelectMany(p => cmdlet.SessionState.Path.GetResolvedProviderPathFromPSPath(p, out _))
					.Distinct()
					.ToArray();
		}
	}
}
