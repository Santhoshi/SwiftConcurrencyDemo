//
//  DownloadImageWithAsync.swift
//  SwiftConcurrency
//
//  Created by Santhoshi Guduru 
//

import SwiftUI
import Combine

class DownloadImageWithAsyncImageLoader {

    let url = URL(string: "https://picsum.photos/200")!
    // Function to handle response
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage?{
        guard let data = data,
              let imageFromData = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else{
            return nil
        }
        return imageFromData
    }
    //Download With @escaping
    func downloadWithEscaping(completionHandler: @escaping(_ image: UIImage?, _ error: Error?) -> ()){
        URLSession.shared.dataTask(with: url) {[weak self] data, response, error in
            let imageFromData = self?.handleResponse(data: data, response: response)
            completionHandler(imageFromData,nil)
        }
        .resume()
    }
    //Download with Combine
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    // Download with Async/Await
    func downloadWithAsync() async throws -> UIImage? {
        do{
            let (data, response) = try await (URLSession.shared.data(from: url, delegate: nil))
            return handleResponse(data: data, response: response)
        }catch{
            throw error
        }
    }
}


class DownloadImageWithAsyncViewModel: ObservableObject{
    @Published var image: UIImage? = nil
    let loader = DownloadImageWithAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
    
    //Fetch Image from the Image Loader
    func fetchImage() async{
        /*
//        loader.downloadWithEscaping {[weak self] image, error in
//            DispatchQueue.main.async {
//                self?.image = image
//            }
//        }
        //fetch download with Combine
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main) // receive on main thread
            .sink { _ in
                
                } receiveValue: { [weak self] image in
                    self?.image = image
            }
            .store(in: &cancellables)
         */
        
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
     
}

struct DownloadImageWithAsync: View {
    @StateObject var viewModel = DownloadImageWithAsyncViewModel()
    var body: some View {
        ZStack{
            if let image = viewModel.image{
                Image(uiImage:image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250,height: 250)
            }
        }
        .onAppear{
            Task{
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageWithAsync()
}
