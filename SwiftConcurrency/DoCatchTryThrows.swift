//
//  DoCatchTryThrows.swift
//  SwiftConcurrency
//
//  Created by Santhoshi Guduru on 11/18/24.
//

import SwiftUI

class DoCatchTryThrowsDataManager {
    
    let isActive: Bool = true
    
    func getTitle() throws-> String {
        if isActive{
            return "New title!!"
        }else {
            throw URLError(.badURL)
        }
    }
    func getDifferentTitle() throws -> String{
        if isActive{
            return "Different title"
        }else {
            throw URLError(.badServerResponse)
        }
    }
}
class DoCatchTryThrowsViewModel: ObservableObject{
    @Published var text: String = "Start"
    let manager = DoCatchTryThrowsDataManager()
    func fetchTitle(){
        do {
            //optional try
            let result = try? manager.getTitle()
            if let newTitle = result{
                self.text = newTitle

            }
            
            let differentResult = try manager.getDifferentTitle()
            self.text = differentResult
        }catch {
            self.text = error.localizedDescription
        }
    }
}
struct DoCatchTryThrows: View {
    @StateObject var viewModel = DoCatchTryThrowsViewModel()
    var body: some View {
        Text(viewModel.text)
            .frame(width:300, height: 300)
            .background(Color.yellow)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTryThrows()
}
