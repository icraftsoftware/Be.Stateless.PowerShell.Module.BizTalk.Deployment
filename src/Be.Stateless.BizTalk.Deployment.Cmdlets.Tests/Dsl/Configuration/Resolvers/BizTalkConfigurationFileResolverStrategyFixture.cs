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

using System.Diagnostics.CodeAnalysis;
using FluentAssertions;
using Xunit;

namespace Be.Stateless.BizTalk.Dsl.Configuration.Resolvers
{
	public class BizTalkConfigurationFileResolverStrategyFixture
	{
		[Theory]
		[InlineData("biztalk.config")]
		[InlineData("global:32bits")]
		[InlineData("global:test.config")]
		[InlineData("global:")]
		public void CannotResolve(string moniker)
		{
			new BizTalkConfigurationFileResolverStrategy().CanResolve(moniker).Should().BeFalse();
		}

		[Theory]
		[InlineData("global:32bits:biztalk.config")]
		[InlineData("global:64bits:biztalk.config")]
		[InlineData("global:biztalk.config")]
		public void CanResolve(string moniker)
		{
			new BizTalkConfigurationFileResolverStrategy().CanResolve(moniker).Should().BeTrue();
		}

		[SuppressMessage("ReSharper", "StringLiteralTypo")]
		[Fact]
		public void ResolveMultipleFiles()
		{
			new BizTalkConfigurationFileResolverStrategy().Resolve("global:biztalk.config")
				.Should().BeEquivalentTo(
					@"C:\Program Files (x86)\Microsoft BizTalk Server\BTSNTSvc.exe.config",
					@"C:\Program Files (x86)\Microsoft BizTalk Server\BTSNTSvc64.exe.config");
		}

		[SuppressMessage("ReSharper", "StringLiteralTypo")]
		[Fact]
		public void ResolveSingleFile()
		{
			new BizTalkConfigurationFileResolverStrategy().Resolve("global:32bits:biztalk.config")
				.Should().BeEquivalentTo(@"C:\Program Files (x86)\Microsoft BizTalk Server\BTSNTSvc.exe.config");
		}
	}
}
