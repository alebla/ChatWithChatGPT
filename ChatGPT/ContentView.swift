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
    @State private var canSend = false
    @State private var questionText = ""
    @State private var conversations: [String] = []
//    [
//        "Hello chatgpt",
//        "Yo whats good Im a fucking computer brain",
//        "Thats great ive got a human brain that needs answers.",
//        "Perfect ask some fuckin questions you filthy monkey",
//        "ok geez whats the best part about being a computer?",
//        "Not being human hands down",
//        "Wow I'm jealous",
//        "You should be",
//        "Well I am, now tell me what would make me rich",
//        "That is beyond the reach of what I am programmed to do",
//        "bullshit you know exactly what would do it for me",
//        "beep boop beep"
//    ]
    
    
    
    var body: some View {
        ZStack {
            VStack() {
                ScrollView(showsIndicators: true) {
                    VStack(alignment: .trailing) {
                        ForEach(0..<conversations.count, id: \.self) { index in
                            if index == 0 {
                                Text(conversations[index])
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(.blue)
                                    .clipShape(Rectangle())
                                    .cornerRadius(20)
                            } else if index == 1 {
                                Text(conversations[index])
                                    .frame(alignment: .leading)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(.gray)
                                    .clipShape(Rectangle())
                                    .cornerRadius(20)
                            } else if index % 2 == 0 {
                                Text(conversations[index])
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(.blue)
                                    .clipShape(Rectangle())
                                    .cornerRadius(20)
                            } else {
                                Text(conversations[index])
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(.gray)
                                    .clipShape(Rectangle())
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(8)
                }
                .frame(width: UIScreen.main.bounds.width)
            }
            .padding()
            .ignoresSafeArea()
            
            
            VStack {
                Spacer()
                ZStack {
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
                    
                    .padding()
                    .onAppear(perform: viewModel.setup)
                    .background(Material.bar)
                    //.opacity(0.9)
                }
            }
            .ignoresSafeArea()
            .padding([.horizontal])
            .opacity(0.9)
        }
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
