//
//  SignUpView.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/12.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var vm: SignUpViewModel
    
    init() {
        let vm = SignUpViewModel()
        vm.inject(api: AuthenticationClientAPI())
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            VStack() {
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
                FillButton(label: "Create Accounnt") {
                    vm.createAccount()
                }
                .disabled(!vm.isSignUpButtonEnabled)
                Spacer()
                    .frame(height: 20)
            }
            .alert(vm.alertTitle, isPresented: $vm.isShowingAlert) {
                Button("OK") {
                    if let _ = AuthManager.shared.user {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text(vm.alertMessage)
            }
            if vm.isProcessing {
                IndicatorView()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    private func topImage() -> some View {
        Image(systemName: "person.crop.circle.badge.plus")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
    }
    
    @ViewBuilder
    private func authTextFields() -> some View {
        VStack(spacing: 20) {
            TextField("Name", text: $vm.userNameStr)
                .padding(.horizontal,30)
                .textFieldStyle(.roundedBorder)
            TextField("Email address", text: $vm.emailStr)
                .padding(.horizontal,30)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $vm.passwordStr)
                .padding(.horizontal,30)
                .textFieldStyle(.roundedBorder)
            SecureField("Confirm password", text: $vm.confirmPasswordStr)
                .padding(.horizontal,30)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
