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
using System.Management.Automation;
using Be.Stateless.BizTalk.Deployment.Cmdlet;

namespace Be.Stateless.BizTalk.Install.Command.Dispatcher
{
	internal static class CommandDispatcherFactory<T>
		where T : MarshalByRefObject, IDispatchedCommand, new()
	{
		internal static CommandDispatcher<T> Create<TS>(TS cmdlet, bool isolated = false)
			where TS : PSCmdlet, IProvideAssemblyResolutionProbingPaths, ISetupDispatchedCommand<T>
		{
			if (cmdlet == null) throw new ArgumentNullException(nameof(cmdlet));

			var assemblyResolutionProbingPaths = cmdlet.AssemblyResolutionProbingPaths;
			var dispatchedCommandSetupper = (ISetupDispatchedCommand<T>) cmdlet;
			var outputAppender = new PowerShellOutputAppender(cmdlet);
			return isolated
				? new IsolatedCommandDispatcher<T>(outputAppender, dispatchedCommandSetupper, assemblyResolutionProbingPaths)
				: new CommandDispatcher<T>(outputAppender, dispatchedCommandSetupper, assemblyResolutionProbingPaths);
		}
	}
}
