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

namespace Be.Stateless.BizTalk.Deployment.Cmdlet
{
	[SuppressMessage("ReSharper", "InconsistentNaming")]
	internal static class Nouns
	{
		public const string AffiliateApplication = nameof(AffiliateApplication);
		public const string AffiliateApplicationStore = nameof(AffiliateApplicationStore);
		public const string ApplicationBinding = nameof(ApplicationBinding);
		public const string ApplicationFileAdapterFolders = nameof(ApplicationFileAdapterFolders);
		public const string ApplicationHosts = nameof(ApplicationHosts);
		public const string ApplicationState = nameof(ApplicationState);
	}
}
