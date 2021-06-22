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
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using Be.Stateless.BizTalk.Management;
using Be.Stateless.BizTalk.Text.RegularExpressions.Extensions;
using Be.Stateless.Dsl.Configuration;
using Be.Stateless.Dsl.Configuration.Resolver;

namespace Be.Stateless.BizTalk.Dsl.Configuration.Resolvers
{
	public class BizTalkConfigurationFileResolverStrategy : IConfigurationFileResolverStrategy
	{
		[SuppressMessage("ReSharper", "StringLiteralTypo")]
		private static string GetBizTalkConfigurationFile(ClrBitness bitness)
		{
			var fileName = bitness switch {
				ClrBitness.Bitness32 => "BTSNTSvc.exe.config",
				ClrBitness.Bitness64 => "BTSNTSvc64.exe.config",
				_ => throw new ArgumentOutOfRangeException(nameof(bitness), bitness, "Unexpected CLR bitness value.")
			};
			return Path.Combine(BizTalkInstallation.InstallationPath, fileName);
		}

		private static bool TryResolve(string moniker, out Match match)
		{
			match = _globalPattern.Match(moniker);
			return match.Success;
		}

		#region IConfigurationFileResolverStrategy Members

		public bool CanResolve(string moniker)
		{
			return TryResolve(moniker, out _);
		}

		public IEnumerable<string> Resolve(string moniker)
		{
			if (!TryResolve(moniker, out var match)) throw new ArgumentException($"The BizTalk moniker '{moniker}' cannot be resolved.", nameof(moniker));
			var bitness = match.Groups["bitness"].AsClrBitness();
			return bitness.Select(GetBizTalkConfigurationFile).Distinct();
		}

		#endregion

		private static readonly Regex _globalPattern = new(@"^global(?::(?<bitness>(?:32|64)bits))?:(?:biztalk\.config)$");
	}
}
