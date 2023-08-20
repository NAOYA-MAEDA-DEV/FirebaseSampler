//
//  GetServerStateView.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/14.
//

import SwiftUI

struct ServerInfomationView: View {
    @StateObject var vm: ServerInfomationViewModel
    
    init() {
        let vm = ServerInfomationViewModel()
        vm.inject(api: RemoteConfigClientAPI())
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            Spacer()
                .frame(height: 50)
            serverInfomationTexts()
            VStack {
                Spacer()
                getServerInfomationButtons()
                Spacer()
                    .frame(height: 20)
            }
            if vm.isProcessing {
                IndicatorView()
            }
        }
        .alert(vm.alertTitle, isPresented: $vm.isShowingAlert) {
            Button("OK") {
            }
        } message: {
            Text(vm.alertMessage)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            vm.inject(api: RemoteConfigClientAPI())
        }
    }
    
    @ViewBuilder
    private func serverInfomationTexts() -> some View {
        VStack(spacing: 30) {
            Spacer()
                .frame(height: 50)
            Text("Server State")
            Text(vm.stateMessage)
            Spacer()
                .frame(height: 50)
            Text("Latest App Version")
            Text(vm.appVersionMessage)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func getServerInfomationButtons() -> some View {
        VStack(spacing: 15) {
            FillButton(label: "Get Server State") {
                vm.getServerState()
            }
            FillButton(label: "Get Latest App Version") {
                vm.getLatestAppVersion()
            }
        }
    }
}

struct ServerInfomationView_Previews: PreviewProvider {
    static var previews: some View {
        ServerInfomationView()
    }
}
