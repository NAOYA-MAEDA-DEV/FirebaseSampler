//
//  ContentView.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/11.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var vm: SignInViewModel
    
    init() {
        let vm = SignInViewModel()
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
                    emailVerifiedErrorText()
                    authTextFields()
                    Text(vm.errorMessage)
                        .padding(.horizontal, 30)
                    Spacer()
                }
                VStack {
                    Spacer()
                    authButtons()
                    Spacer()
                        .frame(height: 20)
                }
                if vm.isProcessing {
                    IndicatorView()
                }
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
            vm.checkEmailVerification()
        }
    }
    
    @ViewBuilder
    private func topImage() -> some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
        Text("\(AuthManager.shared.user?.displayName ?? "")")
    }
    
    @ViewBuilder
    private func emailVerifiedErrorText() -> some View {
        if vm.isVerified || AuthManager.shared.user == nil {
            Spacer()
                .frame(height: 50)
        } else {
            VStack(spacing: 10) {
                Text("Email verification not completed.")
                    .frame(height: 50)
                Button {
                    vm.sendEmailVerification()
                } label: {
                    Text("Resend confirmation email")
                        .font(.system(size: 12))
                }
                Text("or")
                    .font(.system(size: 12))
                Button {
                    vm.checkEmailVerification()
                } label: {
                    Text("Reload State?")
                        .font(.system(size: 12))
                }
            }
        }
    }
    
    @ViewBuilder
    private func authTextFields() -> some View {
        if authManager.user == nil {
            VStack(spacing: 20) {
                TextField("Email address", text: $vm.emailStr)
                    .padding(.horizontal,30)
                    .textFieldStyle(.roundedBorder)
                SecureField("Password", text: $vm.passwordStr)
                    .padding(.horizontal,30)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    @ViewBuilder
    private func authButtons() -> some View {
        VStack {
            if let _ = authManager.user {
                VStack(spacing: 15) {
                    FillButton(label: "SignOut") {
                        vm.signOut()
                    }
                    FillButton(label: "Delete Account", fillColor: .pink) {
                        vm.deleteAccount()
                    }
                }
            } else {
                FillButton(label: "SignIn") {
                    vm.signIn()
                }
                Spacer()
                    .frame(height: 15)
                FillButton(label: "SignIn with Google") {
                    vm.signInwtihGoogle()
                }
                Spacer()
                    .frame(height: 15)
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("SignUp")
                }
                Spacer()
                    .frame(height: 15)
                NavigationLink {
                    ResetPasswordView()
                } label: {
                    Text("Forgot your password?")
                        .font(.system(size: 13))
                }
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthManager.shared)
    }
}
