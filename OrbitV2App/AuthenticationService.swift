//
//  AuthenticationService.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 5/18/23.
//

//import Foundation
//import Firebase
//    
//    //Sing Up User
//    
//    class AuthenticationService {
//
//        // Conversion function
//        private func convertToAppUser(_ firebaseUser: FirebaseAuth.User) -> User {
//            return User(uid: firebaseUser.uid, email: firebaseUser.email ?? "")
//        }
//
//        func signUp(email: String, password: String) async throws -> User {
//            let firebaseUser = try await withCheckedThrowingContinuation { continuation in
//                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//                    if let error = error {
//                        continuation.resume(throwing: error)
//                    } else if let user = authResult?.user {
//                        continuation.resume(returning: user)
//                    } else {
//                        continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
//                    }
//                }
//            }
//            return convertToAppUser(firebaseUser)
//        }
//
//        func signIn(email: String, password: String) async throws -> User {
//            let firebaseUser = try await withCheckedThrowingContinuation { continuation in
//                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//                    if let error = error {
//                        continuation.resume(throwing: error)
//                    } else if let user = authResult?.user {
//                        continuation.resume(returning: user)
//                    } else {
//                        continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
//                    }
//                }
//            }
//            return convertToAppUser(firebaseUser)
//        }
//        
//        // 3. Sign Out User
//        func signOut() throws {
//            try Auth.auth().signOut()
//        }
//    }
