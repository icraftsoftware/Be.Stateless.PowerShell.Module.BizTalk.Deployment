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
using System.Linq;
using System.Management.Automation;
using Be.Stateless.Extensions;
using Be.Stateless.Linq.Extensions;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet
{
	public abstract class ProviderPathResolvingCmdlet : PSCmdlet
	{
		protected string[] ResolvePowerShellPaths(string[] psPaths, string propertyName)
		{
			if (psPaths == null) return Array.Empty<string>();
			if (propertyName == null) throw new ArgumentNullException(nameof(propertyName));
			var paths = psPaths
				// see https://stackoverflow.com/questions/8505294/how-do-i-deal-with-paths-when-writing-a-powershell-cmdlet
				.SelectMany(p => SessionState.Path.GetResolvedProviderPathFromPSPath(p, out _))
				.ToArray();
			WriteDebug($"Resolved {propertyName}:");
			paths.ForEach(p => WriteDebug($"  '{p}'"));
			return paths;
		}

		protected string ResolvePowerShellPath(string psPath, string propertyName)
		{
			if (psPath.IsNullOrWhiteSpace()) return null;
			if (propertyName == null) throw new ArgumentNullException(nameof(propertyName));
			// see https://stackoverflow.com/questions/8505294/how-do-i-deal-with-paths-when-writing-a-powershell-cmdlet
			var path = SessionState.Path.GetUnresolvedProviderPathFromPSPath(psPath);
			WriteDebug($"Resolved {propertyName}: '{path}'.");
			return path;
		}
	}
}
