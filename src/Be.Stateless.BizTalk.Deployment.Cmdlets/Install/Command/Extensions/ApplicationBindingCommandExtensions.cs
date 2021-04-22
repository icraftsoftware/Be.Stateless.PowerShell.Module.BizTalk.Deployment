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

using System.Linq;
using Be.Stateless.BizTalk.Deployment.Cmdlet;
using Be.Stateless.BizTalk.Deployment.Cmdlet.Application;
using Be.Stateless.BizTalk.Deployment.Cmdlet.Binding;

namespace Be.Stateless.BizTalk.Install.Command.Extensions
{
	internal static class ApplicationBindingCommandExtensions
	{
		internal static ICommand Initialize(this IApplicationBindingGenerationCommand cmd, ConvertApplicationBinding cmdlet)
		{
			((IApplicationBindingCommand) cmd).Initialize(cmdlet);
			cmd.OutputFilePath = cmdlet.ResolvedOutputFilePath;
			return (ICommand) cmd;
		}

		internal static ICommand Initialize(this IApplicationFileAdapterFolderSetupCommand cmd, InstallApplicationFileAdapterFolders cmdlet)
		{
			((IApplicationBindingCommand) cmd).Initialize(cmdlet);
			if (cmdlet.Users != null && cmdlet.Users.Any()) cmd.Users = cmdlet.Users;
			return (ICommand) cmd;
		}

		internal static ICommand Initialize(this IApplicationHostEnumerationCommand cmd, ApplicationBindingBasedCmdlet cmdlet)
		{
			return ((IApplicationBindingCommand) cmd).Initialize(cmdlet);
		}

		internal static ICommand Initialize(this IApplicationBindingCommand cmd, ApplicationBindingBasedCmdlet cmdlet)
		{
			cmd.AssemblyProbingFolderPaths = cmdlet.ResolvedAssemblyProbingFolderPaths;
			cmd.EnvironmentSettingOverridesType = cmdlet.EnvironmentSettingOverridesType;
			cmd.ExcelSettingOverridesFolderPath = cmdlet.ResolvedExcelSettingOverridesFolderPath;
			cmd.TargetEnvironment = cmdlet.TargetEnvironment;
			return (ICommand) cmd;
		}
	}
}
