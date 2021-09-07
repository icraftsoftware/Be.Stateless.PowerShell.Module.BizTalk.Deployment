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
using Be.Stateless.BizTalk.Dsl.Binding.Extensions;
using Be.Stateless.BizTalk.Reflection;
using Be.Stateless.Extensions;

namespace Be.Stateless.BizTalk.Install.Command.Binding
{
	internal abstract class DispatchedApplicationBindingBasedCommand : DispatchedCommand, ISupplyApplicationBindingBasedCommandArguments
	{
		#region ISupplyApplicationBindingBasedCommandArguments Members

		public string ExcelSettingOverridesFolderPath { get; set; }

		public string TargetEnvironment { get; set; }

		public Type EnvironmentSettingOverridesType { get; private set; }

		#endregion

		#region Base Class Member Overrides

		[SuppressMessage("Usage", "CA2208:Instantiate argument exceptions correctly")]
		protected sealed override void BeforeExecute(IOutputAppender outputAppender)
		{
			if (ApplicationBindingAssemblyFilePath.IsNullOrEmpty()) throw new ArgumentNullException(nameof(ApplicationBindingAssemblyFilePath));
			ResolveApplicationBindingType(outputAppender);
			if (!EnvironmentSettingOverridesTypeName.IsNullOrEmpty()) ResolveEnvironmentSettingOverridesType(outputAppender);
		}

		#endregion

		public string ApplicationBindingAssemblyFilePath { private get; set; }

		public string EnvironmentSettingOverridesTypeName { private get; set; }

		protected Type ApplicationBindingType { get; private set; }

		private void ResolveApplicationBindingType(IOutputAppender outputAppender)
		{
			outputAppender.WriteInformation($"Resolving ApplicationBindingType in assembly '{ApplicationBindingAssemblyFilePath}'...");
			ApplicationBindingType = AssemblyLoader.Load(ApplicationBindingAssemblyFilePath).GetApplicationBindingType(true);
			outputAppender.WriteInformation($"Resolved ApplicationBindingType: '{ApplicationBindingType.AssemblyQualifiedName}'.");
		}

		private void ResolveEnvironmentSettingOverridesType(IOutputAppender outputAppender)
		{
			outputAppender.WriteInformation($"Resolving EnvironmentSettingOverridesType '{EnvironmentSettingOverridesTypeName}'...");
			EnvironmentSettingOverridesType = Type.GetType(EnvironmentSettingOverridesTypeName, true);
			outputAppender.WriteInformation($"Resolved EnvironmentSettingOverridesType in assembly '{EnvironmentSettingOverridesType.Assembly.Location}'.");
		}
	}
}
