//
//  ContentView.swift
//  JWPUBParser
//
//  Created by Manuel De Freitas on 4/17/23.
//

import SwiftUI
import ZIPFoundation
import UniformTypeIdentifiers


extension UTType {
    static var jwpub: UTType {
        // Look up the type from the file extension
        UTType.types(tag: "jwpub", tagClass: .filenameExtension, conformingTo: nil).first!
    }
}

struct BackupFile: FileDocument {
    static var readableContentTypes = [UTType.jwpub]
    var url: URL

    init(url: URL) {
        self.url = url
    }

    init(configuration: ReadConfiguration) {
        url = URL(string: "")!
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let file = try FileWrapper(url: url, options: .immediate)

        return file
    }
}

struct ContentView: View {
    
    @State var present: Bool = false
    @State var progress: Double = 0
    private let total: Double = 1
 
    
    var body: some View {
    
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("UNZIP") {
                present.toggle()
            }
            ProgressView(value: progress, total: total) {
                Text("Downloading")
            }
        }
    
        .padding()
        .fileImporter(isPresented: $present, allowedContentTypes: [.jwpub]) { result in
            do {
                let url = try result.get()
                unzip(url)
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    
    func unzip(_ file: URL) {

        let fileManager = FileManager()
        let dbService = DBService.shared
        let unzipProgress = Progress()
        let currentWorkingPath = fileManager.currentDirectoryPath
        let folderName = UUID().uuidString
        var destinationURL = URL(fileURLWithPath: currentWorkingPath)
        destinationURL.append(path: folderName, directoryHint: .isDirectory)
        
        let observation = unzipProgress.observe(\.fractionCompleted) { progress, _ in
             //  print(progress.fractionCompleted)
            DispatchQueue.main.async {
                self.progress = progress.fractionCompleted
            }
        }
        
        
        do {
            
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: file, to: destinationURL, progress: unzipProgress)
            let urls = try fileManager.contentsOfDirectory(atPath: destinationURL.relativePath)
            
            var fileName: String = ""
            
            guard let manifestPath = urls.first(where: { $0.contains("manifest") }) else { return }
            guard let manifestURL = URL(string: manifestPath) else { return }
            let fullManifestPath = destinationURL.appending(path: manifestURL.lastPathComponent)
            guard let manifest = readJSON(fileUrl:fullManifestPath) else { return }
            guard let contentString = urls.first(where: { $0.contains("contents") }) else { return }
            guard let contentsURL = URL(string: contentString) else { return }
            fileName = manifest.publication?.fileName ?? ""
            
            let contentFullPath = destinationURL.appending(path: contentsURL.lastPathComponent)
            
            let assetsPath = destinationURL.appending(path: "assets")
            try fileManager.unzipItem(at: contentFullPath, to: assetsPath)
            let dbPath = assetsPath.appending(component: fileName)
            if let publication = manifest.publication {
                dbService.read(url: dbPath, manifest: publication, fileName: fileName)
            }
           
  
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
        observation.invalidate()
    }
    
    func readJSON(fileUrl: URL) -> Manifest? {
        do {
            let jsonData = try Data(contentsOf: fileUrl)
            let decoder = JSONDecoder()
            
            // Decode JSON data into your struct
            let myData = try decoder.decode(Manifest.self, from: jsonData)
            
            return myData

        } catch {
            print("Error reading JSON file: \(error.localizedDescription)")
        }
        return nil
    }
}

