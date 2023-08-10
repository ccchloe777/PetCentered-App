//
//  ToastView.swift
//  PetConnect
//
//  Created by x7 on 2023/8/8.
//

import SwiftUI

struct ToastView: View {
    let message: String
    @State private var isPresented = false // Initialize as false

    var body: some View {
        VStack {
            Spacer()
            if isPresented { // Show the view conditionally
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isPresented = false // Dismiss the toast after a delay
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3)) // Adjust animation duration as needed
        .onChange(of: message) { _ in
            isPresented = true // Show the toast when message changes
        }
    }
}


struct Previews_ToastView_Previews: PreviewProvider {
    static var previews: some View {
        Text("message")
            .font(.custom("MarkerFelt-Thin", size: 24))
            .foregroundColor(.orange)
            .padding()
            .padding()
    }
}
