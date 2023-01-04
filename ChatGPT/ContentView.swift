//
//  ContentView.swift
//  ChatGPT
//
//  Created by aB on 1/3/23.
//

import SwiftUI
import OpenAISwift

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: HiddenAPIKey.APIKey)
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text, maxTokens: 2048 ) { result in
            switch result {
                case .success(let model):
                    let output = model.choices.first?.text ?? ""
                    completion(output)
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State private var questionText = ""
    @State private var conversations = [""]
    
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ForEach(conversations, id: \.self) { conversation in
                    Text(conversation)
                }
            }
            
            Spacer()
            
            HStack {
                TextField("Ask ChatGpt a question...", text: $questionText)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(Capsule())
                Button {
                    send()
                } label: {
                    Text("Send")
                        .padding()
                        .foregroundColor(.white)
                        .background(.blue)
                        .clipShape(Capsule())
                }
            }
            .padding([.bottom, .top])
            .onAppear(perform: viewModel.setup)
        }
        .padding()
    }
    
    func send() {
        guard !questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        conversations.append("Me: \(questionText)")
        
        viewModel.send(text: questionText) { response in
            DispatchQueue.main.async {
                self.conversations.append("ChatGPT: " + response)
                questionText = ""
            }
        }
        questionText = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
