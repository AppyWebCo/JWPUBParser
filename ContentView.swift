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
    //@State var progress: Progress = .init(totalUnitCount: 1)
    @State var progress: Double = 0
    @State var total: Double = 0
    @State var parentProgress = Progress(totalUnitCount: 100)
    @State var observation: NSKeyValueObservation?
    
    func test() async {
        do {
            let client = JWPubMedia()
            try await client.fetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
 
    var body: some View {
    
        VStack {
            
            ZStack {
                CircularProgressView(progress: progress)
                Text(Int(progress * 100), format: .percent)
            }
            .frame(width: 100, height: 100)
            
           
            
        
            Button("UNZIP") {
                present.toggle()
            }
            .padding(.top)
            
            Button("TEST") {
                Task {
                    await test()
                }
            }

        }
    
        .padding()
        .fileImporter(isPresented: $present, allowedContentTypes: [.jwpub]) { result in
            do {
                let url = try result.get()
                Task {
                    await unzip(url)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        .onAppear {
            self.observation = self.parentProgress.observe(\.fractionCompleted) {  _progress, number in
                if (_progress.fractionCompleted <= 1) {
                    self.progress = _progress.fractionCompleted
                }
            }
        }
       
        
    }
    
    
    
    func unzip(_ file: URL) async {
    
        let parser = JWPUBParser.shared
        do {
            if let publication = try await parser.read(at: file, progress: parentProgress) {
                
                if let bible = publication as? JWPBible {
                    print(bible.books.first?.chapters.first?.content ?? "")
                }
                
                if let mwp = publication as? JWPMeetingWorkBook {
                    print(mwp.weeks.first?.subtitle ?? "")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        if let observation {
            observation.invalidate()
        }
    }

}



struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.pink.opacity(0.5),
                    lineWidth: 15
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.pink,
                    style: StrokeStyle(
                        lineWidth: 15,
                        lineCap: .butt
                    )
                )
                .rotationEffect(.degrees(-90))
                // 1
                .animation(.easeOut, value: progress)

        }
    }
}
