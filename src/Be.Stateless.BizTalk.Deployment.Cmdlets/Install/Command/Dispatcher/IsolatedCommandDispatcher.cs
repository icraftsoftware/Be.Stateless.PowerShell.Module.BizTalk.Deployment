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
using System.IO;
using System.Management.Automation;
using System.Reflection;
using Be.Stateless.BizTalk.Deployment.Cmdlet;

namespace Be.Stateless.BizTalk.Install.Command.Dispatcher
{
	internal class IsolatedCommandDispatcher<T> : IDisposable
		where T : DispatchedCommand, IDispatchedCommand
	{
		internal static IsolatedCommandDispatcher<T> Create<TS>(TS cmdlet)
			where TS : PSCmdlet, IProvideAssemblyResolutionProbingPaths, ISetupDispatchedCommand<T>
		{
			return Create(new CmdletOutputProxy(cmdlet), cmdlet, cmdlet.AssemblyResolutionProbingPaths);
		}

		internal static IsolatedCommandDispatcher<T> Create(
			IOutputAppender outputAppender,
			ISetupDispatchedCommand<T> dispatchedCommandSetupper,
			string[] assemblyResolutionProbingPaths)
		{
			if (dispatchedCommandSetupper == null) throw new ArgumentNullException(nameof(dispatchedCommandSetupper));
			if (outputAppender == null) throw new ArgumentNullException(nameof(outputAppender));

			var dispatcher = new IsolatedCommandDispatcher<T>(outputAppender, assemblyResolutionProbingPaths);
			dispatchedCommandSetupper.Setup(dispatcher._dispatchedCommand);
			return dispatcher;
		}

		private IsolatedCommandDispatcher(IOutputAppender outputAppender, string[] assemblyResolutionProbingPaths)
		{
			var setupInformation = AppDomain.CurrentDomain.SetupInformation;
			setupInformation.ApplicationBase = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
			_appDomain = AppDomain.CreateDomain($"Isolated {typeof(T).Name}", null, setupInformation);
			_dispatchedCommand = (T) _appDomain.CreateInstanceAndUnwrap(typeof(T).Assembly.FullName, typeof(T).FullName!);
			_assemblyResolutionProbingPaths = assemblyResolutionProbingPaths;
			_outputAppender = outputAppender;
		}

		#region IDisposable Members

		public void Dispose()
		{
			if (_appDomain != null) AppDomain.Unload(_appDomain);
		}

		#endregion

		public void Run()
		{
			_dispatchedCommand.Execute(_outputAppender, _assemblyResolutionProbingPaths);
		}

		private readonly AppDomain _appDomain;
		private readonly string[] _assemblyResolutionProbingPaths;
		private readonly T _dispatchedCommand;
		private readonly IOutputAppender _outputAppender;
	}
}
