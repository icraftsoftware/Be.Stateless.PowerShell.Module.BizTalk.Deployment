#region Copyright & License

// Copyright © 2012 - 2022 François Chabot
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
using Be.Stateless.BizTalk.Explorer;
using OrchestrationStatus = Microsoft.BizTalk.ExplorerOM.OrchestrationStatus;
using PortStatus = Microsoft.BizTalk.ExplorerOM.PortStatus;

namespace Be.Stateless.BizTalk.Dsl.Binding.Visitor
{
	/// <summary>
	/// <see cref="IApplicationBindingVisitor"/> implementation that manages BizTalk Server services' state.
	/// </summary>
	/// <remarks>
	/// <see cref="IApplicationBindingVisitor"/> implementation that either
	/// <list type="bullet">
	/// <item>
	/// Enable or disable a receive location according to its DSL-based binding;
	/// </item>
	/// <item>
	/// Start, stop, enlist or unenlist a send port according to its DSL-based binding;
	/// </item>
	/// <item>
	/// Start, stop, enlist or unenlist an orchestration according to its DSL-based binding.
	/// </item>
	/// </list>
	/// </remarks>
	[SuppressMessage("ReSharper", "UnusedType.Global", Justification = "Public API.")]
	public sealed class BizTalkServiceStateInitializer : ApplicationBindingVisitor, IDisposable
	{
		public BizTalkServiceStateInitializer(BizTalkServiceInitializationOptions options, Action<string> logAppender)
		{
			_options = options;
			_logAppender = logAppender;
		}

		#region IDisposable Members

		public void Dispose()
		{
			_application?.Dispose();
		}

		#endregion

		#region Base Class Member Overrides

		protected override void VisitApplicationBinding<TNamingConvention>(IApplicationBinding<TNamingConvention> applicationBinding)
			where TNamingConvention : class
		{
			if (applicationBinding == null) throw new ArgumentNullException(nameof(applicationBinding));
			var name = applicationBinding.ResolveName();
			_application = BizTalkServerGroup.Applications[name];
		}

		protected override void VisitOrchestration(IOrchestrationBinding orchestrationBinding)
		{
			if (orchestrationBinding == null) throw new ArgumentNullException(nameof(orchestrationBinding));
			if (!_options.RequireOrchestrationInitialization()) return;

			var name = orchestrationBinding.Type.FullName;
			var orchestration = _application.Orchestrations[name];
			if (orchestration.Status != (OrchestrationStatus) orchestrationBinding.State)
			{
				_logAppender?.Invoke(
					orchestrationBinding.State switch {
						ServiceState.Unenlisted => $"Unenlisting orchestration '{name}'.",
						ServiceState.Enlisted => $"Enlisting or stopping orchestration '{name}'.",
						_ => $"Starting orchestration '{name}'."
					});
				orchestration.Status = (OrchestrationStatus) orchestrationBinding.State;
			}
			else
			{
				_logAppender?.Invoke($"Orchestration '{name}' is already in the expected {orchestrationBinding.State} state.");
			}
		}

		protected override void VisitReceiveLocation<TNamingConvention>(IReceiveLocation<TNamingConvention> receiveLocation)
			where TNamingConvention : class
		{
			if (receiveLocation == null) throw new ArgumentNullException(nameof(receiveLocation));
			if (!_options.RequireReceiveLocationInitialization()) return;

			var name = receiveLocation.ResolveName();
			var rl = _receivePort.ReceiveLocations[name];
			if (rl.Enabled != receiveLocation.Enabled)
			{
				_logAppender?.Invoke($"{(receiveLocation.Enabled ? "Enabling" : "Disabling")} receive location '{name}'.");
				rl.Enabled = receiveLocation.Enabled;
			}
			else
			{
				_logAppender?.Invoke($"Receive location '{name}' is already in {(receiveLocation.Enabled ? "enabled" : "disabled")}.");
			}
		}

		protected override void VisitReceivePort<TNamingConvention>(IReceivePort<TNamingConvention> receivePort)
			where TNamingConvention : class
		{
			if (receivePort == null) throw new ArgumentNullException(nameof(receivePort));
			if (!_options.RequireReceiveLocationInitialization()) return;

			var name = receivePort.ResolveName();
			_receivePort = _application.ReceivePorts[name];
		}

		protected override void VisitSendPort<TNamingConvention>(ISendPort<TNamingConvention> sendPort)
			where TNamingConvention : class
		{
			if (sendPort == null) throw new ArgumentNullException(nameof(sendPort));
			if (!_options.RequireSendPortInitialization()) return;

			var name = sendPort.ResolveName();
			var sp = _application.SendPorts[name];
			if (sp.Status != (PortStatus) sendPort.State)
			{
				_logAppender?.Invoke(
					sendPort.State switch {
						ServiceState.Undefined => $"Leaving send port '{name}' in {ServiceState.Undefined} state.",
						ServiceState.Unenlisted => $"Unenlisting send port '{name}'.",
						ServiceState.Enlisted => $"Enlisting or stopping send port '{name}'.",
						_ => $"Starting send port '{name}'."
					});
				if (sendPort.State != ServiceState.Undefined) sp.Status = (PortStatus) sendPort.State;
			}
			else
			{
				_logAppender?.Invoke($"Send port '{name}' is already in the expected {sendPort.State} state.");
			}
		}

		#endregion

		[SuppressMessage("ReSharper", "UnusedMember.Global", Justification = "Public API.")]
		public void Commit()
		{
			_application.ApplyChanges();
		}

		private readonly Action<string> _logAppender;
		private readonly BizTalkServiceInitializationOptions _options;
		private Application _application;
		private Explorer.ReceivePort _receivePort;
	}
}
