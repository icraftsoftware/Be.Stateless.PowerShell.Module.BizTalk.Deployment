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
using System.Diagnostics.CodeAnalysis;
using System.Management.Automation;
using Be.Stateless.BizTalk.Dsl.Environment.Settings;

namespace Be.Stateless.BizTalk.Deployment.Cmdlet.Sso
{
	[SuppressMessage("ReSharper", "MemberCanBePrivate.Global", Justification = "Cmdlet API.")]
	[SuppressMessage("ReSharper", "UnusedAutoPropertyAccessor.Global", Justification = "Cmdlet API.")]
	public abstract class AffiliateApplicationCmdlet : PSCmdlet
	{
		#region Base Class Member Overrides

		protected override void BeginProcessing()
		{
			ResolvedAffiliateApplicationName = ParameterSetName switch {
				BY_NAME_PARAMETER_SET_NAME => AffiliateApplicationName,
				BY_SETTINGS_PARAMETER_SET_NAME => EnvironmentSettings.ApplicationName,
				_ => throw new InvalidOperationException($"Unexpected parameter set name: {ParameterSetName}.")
			};
		}

		#endregion

		[Alias("Name")]
		[Parameter(Mandatory = true, ParameterSetName = BY_NAME_PARAMETER_SET_NAME)]
		[ValidateNotNullOrEmpty]
		public string AffiliateApplicationName { get; set; }

		[Alias("Settings")]
		[Parameter(Mandatory = true, ParameterSetName = BY_SETTINGS_PARAMETER_SET_NAME)]
		[ValidateNotNull]
		public IEnvironmentSettings EnvironmentSettings { get; set; }

		protected string ResolvedAffiliateApplicationName { get; set; }

		protected internal const string BY_NAME_PARAMETER_SET_NAME = "by-name";
		protected internal const string BY_SETTINGS_PARAMETER_SET_NAME = "by-settings";
	}
}
