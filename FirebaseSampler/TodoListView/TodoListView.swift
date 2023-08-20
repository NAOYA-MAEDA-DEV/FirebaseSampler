//
//  TodoListView.swift
//  FirebaseSampler
//
//  Created by N. M on 2023/08/13.
//

import SwiftUI

struct TodoListView: View {
    @StateObject var vm: TodoListViewModel
    
    init() {
        let vm = TodoListViewModel()
        vm.inject(api: CloudFireStoreClientAPI())
        self._vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                todoList()
                    .navigationBarItems(
                        trailing: navigationbarButtons()
                    )
                if vm.isProcessing {
                    IndicatorView()
                }
            }
        }
        .navigationDestination(isPresented: $vm.isShowSignInView, destination: {
            SignInView()
        })
        .alert(vm.alertTitle, isPresented: $vm.isShowingAlert) {
            Button("OK") {
            }
        } message: {
            Text(vm.alertMessage)
        }
        .onAppear {
            vm.getTodoList()
        }
    }
    
    @ViewBuilder
    private func todoList() -> some View {
        if vm.todoList.isEmpty {
            Text("No Todo")
        } else {
            List(vm.todoList.indices, id: \.self) { index in
                NavigationLink(destination: TodoDetailView(todo: $vm.todoList[index])) {
                    Text(vm.todoList[index].title)
                }
            }
        }
    }
    
    @ViewBuilder
    private func navigationbarButtons() -> some View {
        HStack {
            Button(action: {
                vm.addTodo()
            }) {
                Image(systemName: "plus")
            }
            if let _ = AuthManager.shared.user {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.blue)
            } else {
                Button(action: {
                    vm.isShowSignInView = true
                }) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
            }
        }
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView()
    }
}
