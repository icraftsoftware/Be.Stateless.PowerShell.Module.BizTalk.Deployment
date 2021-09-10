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
using System.Reflection;

namespace Be.Stateless.BizTalk.Install.Command.Dispatcher
{
	internal class IsolatedCommandDispatcher<T> : CommandDispatcher<T>
		where T : MarshalByRefObject, IDispatchedCommand, new()
	{
		internal IsolatedCommandDispatcher(IOutputAppender outputAppender, ISetupDispatchedCommand<T> dispatchedCommandSetupper, string[] assemblyResolutionProbingPaths)
			: base(outputAppender, assemblyResolutionProbingPaths)
		{
			var setupInformation = AppDomain.CurrentDomain.SetupInformation;
			setupInformation.ApplicationBase = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
			_appDomain = AppDomain.CreateDomain($"Isolated {typeof(T).Name}", null, setupInformation);
			DispatchedCommand = (T) _appDomain.CreateInstanceAndUnwrap(typeof(T).Assembly.FullName, typeof(T).FullName!);
			dispatchedCommandSetupper.Setup(DispatchedCommand);
		}

		#region Base Class Member Overrides

		protected override void Dispose(bool disposing)
		{
			if (disposing)
			{
				if (_appDomain != null) AppDomain.Unload(_appDomain);
			}
		}

		#endregion

		private readonly AppDomain _appDomain;
	}
}
