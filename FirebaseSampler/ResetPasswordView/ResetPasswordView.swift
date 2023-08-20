//
//  ResetPasswordView.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import SwiftUI

struct ResetPasswordView: View {
    @StateObject var vm: ResetPasswordViewModel
    
    init() {
        let vm = ResetPasswordViewModel()
        vm.inject(api: AuthenticationClientAPI())
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                        .frame(height: 50)
                    topImage()
                    Spacer()
                        .frame(height: 50)
                    authTextFields()
                    Text(vm.errorMessage)
                        .padding(.horizontal, 30)
                    Spacer()
                }
                VStack {
                    Spacer()
                    FillButton(label: "Reset Password") {
                        vm.resetPassword()
                    }
                    Spacer()
                        .frame(height: 20)
                }
                if vm.isProcessing {
                    IndicatorView()
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .alert(vm.alertTitle, isPresented: $vm.isShowingAlert) {
            Button("OK") {
            }
        } message: {
            Text(vm.alertMessage)
        }
    }
    
    @ViewBuilder
    private func topImage() -> some View {
        Image(systemName: "person.crop.circle.badge.questionmark")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
    }
    
    @ViewBuilder
    private func authTextFields() -> some View {
        TextField("Email adress", text: $vm.emailStr)
            .padding(.horizontal,30)
            .textFieldStyle(.roundedBorder)
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
