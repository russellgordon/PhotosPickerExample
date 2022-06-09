//
//  ContentView.swift
//  PhotosPickerExample
//
//  Created by Russell Gordon on 2022-06-09.
//

import PhotosUI
import SwiftUI

enum ImageState {
    
    // No image selected yet
    case empty
    
    // Loading the selected image
    case loading(Progress)
    
    // Image has been loaded
    case success(Image)
    
    // Image could not be loaded
    case failure(Error)
}

struct ContentView: View {
    
    // MARK: Stored properties
    
    // Where are we in the image selection process?
    @State private var imageState: ImageState = .empty

    // What was selected?
    @State var imageSelection: PhotosPickerItem? {
        didSet {
            
            if let imageSelection {
                
                // An image was selected
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
                
            } else {
                
                // No image was selected
                imageState = .empty
                
            }
        }
    }

    // MARK: Computed properties
    var body: some View {
        
        VStack {
            
            // Allow an image to be selected
            PhotosPicker(selection: $imageSelection, matching: .images) {
                Label("Pick a photo", systemImage: "plus")
            }
            .padding(.bottom)
                        
            // The image...
            switch imageState {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .loading:
                ProgressView()
            case .empty:
                Image(systemName: "photo")
                    .font(.system(size: 40))
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
            }
            
        }
        
        
    }
    
    // MARK: Functions
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        
        return imageSelection.loadTransferable(type: Image.self) { result in
            
            DispatchQueue.main.async {
                
                guard imageSelection == self.imageSelection else { return }
                
                switch result {
                case .success(let image?):
                    imageState = .success(image)
                case .success(nil):
                    imageState = .empty
                case .failure(let error):
                    imageState = .failure(error)
                }
                
            }
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

