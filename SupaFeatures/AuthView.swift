//
//  AuthView.swift
//  SupaFeatures
//
//  Created by Mikaela Caron on 7/25/23.
//

import SwiftUI

struct AuthView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Sign In or Sign Up", selection: $viewModel.authAction) {
                    ForEach(AuthAction.allCases, id: \.rawValue) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .navigationBarTitle("Authentication") 
                .pickerStyle(.segmented)
                
                TextField("Email", text: $viewModel.email)
                    .autocapitalization(.none)
                SecureField("Password", text: $viewModel.password)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        Task {
                            try await viewModel.authorize()
                            dismiss()
                        }
                        
                    } label: {
                        Text(viewModel.authAction.rawValue)
                    }
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(viewModel: ViewModel())
    }
}
