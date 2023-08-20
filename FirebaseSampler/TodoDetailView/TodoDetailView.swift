//
//  TodoDetailView.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/13.
//

import SwiftUI

struct TodoDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm: TodoDetailViewModel = TodoDetailViewModel()
    @Binding var todo: TodoModel
    
    init(todo: Binding<TodoModel>) {
        self._todo = todo
        let vm = TodoDetailViewModel()
        self._vm = StateObject(wrappedValue: vm)
        vm.inject(todo: todo.wrappedValue, api: CloudFireStoreClientAPI())
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: 50)
                toDoTextFields()
                Spacer()
            }
            VStack {
                Spacer()
                saveTaskButtons()
                Spacer()
                    .frame(height: 20)
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
            if vm.isProcessing {
                IndicatorView()
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    @ViewBuilder
    func toDoTextFields() -> some View {
        VStack(spacing: 30) {
            TextField("Title", text: $vm.title)
                .padding(.horizontal,30)
                .textFieldStyle(.roundedBorder)
            TextField("Detail", text: $vm.detail)
                .padding(.horizontal,30)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    @ViewBuilder
    func saveTaskButtons() -> some View {
        VStack(spacing: 15) {
            FillButton(label: "Save") {
                vm.save()
            }
            FillButton(label: "Delete", fillColor: .pink) {
                vm.delete()
            }
        }
    }
}

struct TodoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TodoDetailView(todo: .constant(TodoModel()))
    }
}
