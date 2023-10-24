//
//  ViewModel.swift
//  SupaFeatures
//
//  Created by Mikaela Caron on 7/23/23.
//

import Foundation
import Supabase

enum Table {
    static let features = "Features"
}

enum AuthAction: String, CaseIterable {
    case signIn = "Sign In"
    case signUp = "Sign Up"
}

@MainActor
final class ViewModel: ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var authAction: AuthAction = .signUp
    
    @Published var features = [Feature]()
//    @Published var actUser = ""
    
    @Published var showingAuthView = false
    @Published var email = ""
    @Published var password = ""
    
    let supabase = SupabaseClient(supabaseURL: Secrets.projectURL, supabaseKey: Secrets.apiKey)
    
    // MARK: - Database
    func getUser()->String {
//        return try await supabase.auth.session.user.id
        return "my user"
    }
    
    func createFeatureRequest(text: String) async throws {
        let user  = try await supabase.auth.session.user
        
        let feature = Feature(createdAt: Date(), text: text, isComplete: false, userID:  user.id)
        
        try await supabase.database
            .from(Table.features)
            .insert(values: feature)
            .execute()
    }
    
    func fetchFeatureRequests() async throws {
        let features: [Feature] = try await supabase.database
            .from(Table.features)
            .select()
            .order(column: "created_at", ascending: false)
            .execute()
            .value
        DispatchQueue.main.async {
            self.features = features
        }
    }
    
    func update(_ feature: Feature, with text: String) async {
        
        guard let id = feature.id else {
            print("Can't update feature \(String(describing: feature.id))")
            return
        }
        
        var toUpdate = feature
        toUpdate.text = text
        
        do {
            try await supabase.database
                .from(Table.features)
                .update(values: toUpdate)
                .eq(column: "id", value: id)
                .execute()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func deleteFeature(at id: Int) async throws {
        try await supabase.database
            .from(Table.features)
            .delete()
            .eq(column: "id", value: id)
            .execute()
    }
    
    // MARK: - Authentication
    
    func signUp() async throws {
        _ = try await supabase.auth.signUp(email: email, password: password)
    }
    
    func signIn() async throws {
        //??check i email or password is not empty
        _ = try await supabase.auth.signIn(email: email, password: password)
    }
    
    func isUserAuthenticated() async {
        do {
            _ = try await supabase.auth.session.user
            isAuthenticated = true
        } catch {
            isAuthenticated = false
        }
    }
       
    func signOut() async throws {
        try await supabase.auth.signOut()
        isAuthenticated = false
    }
    
    func authorize() async throws {
        switch authAction {
        case .signUp:
            try await signUp()
        case .signIn:
            try await signIn()
        }
    }
}
