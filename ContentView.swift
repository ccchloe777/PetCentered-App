//
//  ContentView.swift
//  PetConnect
//
//  Created by x7 on 2023/8/7.
//
import SwiftUI
import FirebaseCore
import FirebaseAuth

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        NavigationView {
            RootView()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
