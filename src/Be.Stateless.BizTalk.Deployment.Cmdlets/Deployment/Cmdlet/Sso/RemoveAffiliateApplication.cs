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
using System.Management.Automation;
using Be.Stateless.BizTalk.Settings.Sso;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Sso
{
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Cmdlet.")]
	[Cmdlet(VerbsCommon.Remove, Nouns.AffiliateApplication)]
	[OutputType(typeof(void))]
	public class RemoveAffiliateApplication : AffiliateApplicationCmdlet
	{
		#region Base Class Member Overrides

		protected override void ProcessRecord()
		{
			var affiliateApplication = AffiliateApplication.FindByName(AffiliateApplicationName);
			if (affiliateApplication != null)
			{
				WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}' is being deleted...", null);
				affiliateApplication.Delete();
				WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}' has been deleted.", null);
			}
			else
			{
				WriteInformation($"SSO {nameof(AffiliateApplication)} '{AffiliateApplicationName}' was not found.", null);
			}
		}

		#endregion
	}
}
