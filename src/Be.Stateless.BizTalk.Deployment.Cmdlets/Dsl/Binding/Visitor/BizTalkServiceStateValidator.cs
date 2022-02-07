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
	/// <see cref="IApplicationBindingVisitor"/> implementation that validates BizTalk Server services' state.
	/// </summary>
	/// <remarks>
	/// <see cref="IApplicationBindingVisitor"/> implementation that validates either
	/// <list type="bullet">
	/// <item>
	/// Receive locations' state according to its DSL-based binding;
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
	public sealed class BizTalkServiceStateValidator : IApplicationBindingVisitor, IDisposable
	{
		#region IApplicationBindingVisitor Members

		void IApplicationBindingVisitor.VisitApplicationBinding<TNamingConvention>(IApplicationBinding<TNamingConvention> applicationBinding)
			where TNamingConvention : class
		{
			if (applicationBinding == null) throw new ArgumentNullException(nameof(applicationBinding));
			var name = applicationBinding.ResolveName();
			_application = BizTalkServerGroup.Applications[name];
		}

		void IApplicationBindingVisitor.VisitReferencedApplicationBinding(IVisitable<IApplicationBindingVisitor> referencedApplicationBinding) { }

		void IApplicationBindingVisitor.VisitOrchestration(IOrchestrationBinding orchestrationBinding)
		{
			if (orchestrationBinding == null) throw new ArgumentNullException(nameof(orchestrationBinding));
			var name = orchestrationBinding.Type.FullName;
			var orchestration = _application.Orchestrations[name];
			if (orchestration.Status != (OrchestrationStatus) orchestrationBinding.State)
				throw new InvalidOperationException($"Orchestration '{name}' is not in the expected {orchestrationBinding.State} state, but in the {orchestration.Status} state.");
		}

		void IApplicationBindingVisitor.VisitReceiveLocation<TNamingConvention>(IReceiveLocation<TNamingConvention> receiveLocation)
			where TNamingConvention : class
		{
			if (receiveLocation == null) throw new ArgumentNullException(nameof(receiveLocation));
			var name = receiveLocation.ResolveName();
			var rl = _receivePort.ReceiveLocations[name];
			if (rl.Enabled != receiveLocation.Enabled)
				throw new InvalidOperationException($"Receive location '{name}' is not {(receiveLocation.Enabled ? "enabled" : "disabled")} as expected.");
		}

		void IApplicationBindingVisitor.VisitReceivePort<TNamingConvention>(IReceivePort<TNamingConvention> receivePort)
			where TNamingConvention : class
		{
			if (receivePort == null) throw new ArgumentNullException(nameof(receivePort));
			var name = receivePort.ResolveName();
			_receivePort = _application.ReceivePorts[name];
		}

		void IApplicationBindingVisitor.VisitSendPort<TNamingConvention>(ISendPort<TNamingConvention> sendPort)
			where TNamingConvention : class
		{
			if (sendPort == null) throw new ArgumentNullException(nameof(sendPort));
			var name = sendPort.ResolveName();
			var sp = _application.SendPorts[name];
			if (sp.Status != (PortStatus) sendPort.State)
				throw new InvalidOperationException($"Send port '{name}' is not in the expected {sendPort.State} state, but in the {sp.Status} state.");
		}

		#endregion

		#region IDisposable Members

		public void Dispose()
		{
			_application?.Dispose();
		}

		#endregion

		private Application _application;
		private Explorer.ReceivePort _receivePort;
	}
}
