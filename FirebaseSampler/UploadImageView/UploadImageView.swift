//
//  ChangeProfileIconView.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/15.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct UploadImageView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var vm: UploadImageViewModel
    
    init() {
        let vm = UploadImageViewModel()
        vm.inject(api: StorageClientAPI())
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    profileIconImage()
                    photoPickerButton()
                }
                VStack {
                    Spacer()
                    saveIconButton()
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
                if vm.alertTitle == "Success" {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(vm.alertMessage)
        }
        .onAppear {
            vm.downloadProfileIconImage()
        }
    }
    
    @ViewBuilder
    private func profileIconImage() -> some View {
        if let _ = vm.profileIconImage {
            Image(uiImage: vm.profileIconImage!)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
        }
    }
    
    
    @ViewBuilder
    private func photoPickerButton() -> some View {
        PhotosPicker(
            selection: $vm.selectedPhoto,
            label: {
                Text("Change Profile Icon")
            }
        )
    }
    
    @ViewBuilder
    func saveIconButton() -> some View {
        FillButton(label: "Save") {
            vm.uploadProfileIconImage()
        }
    }
}

struct UploadImageView_Previews: PreviewProvider {
    static var previews: some View {
        UploadImageView()
    }
}
