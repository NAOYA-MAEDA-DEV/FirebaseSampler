//
//  FireBaseSampleListView.swift
//  FireBaseSample2
//
//  Created by N. M on 2023/08/12.
//

import SwiftUI

struct FireBaseSampleListView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    SignInView()
                } label: {
                    Text("Authentication")
                }
                NavigationLink {
                    TodoListView()
                } label: {
                    Text("Cloud Firestore")
                }
                NavigationLink {
                    UploadImageView()
                } label: {
                    Text("Cloud Storage")
                }
                NavigationLink {
                    ServerInfomationView()
                } label: {
                    Text("Remote Config")
                }
            }
        }
    }
}

struct FireBaseSampleListView_Previews: PreviewProvider {
    static var previews: some View {
        FireBaseSampleListView()
    }
}
