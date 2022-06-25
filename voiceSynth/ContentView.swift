//
//  ContentView.swift
//  voiceSynth
//
//  Created by Sabato Francesco Longobardi on 25/06/22.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
  var viewModel = SynthViewModel()
    

    @State var directions : String = "Gira a sinistra su Via Garibaldi, e prosegui dritto"
    @State var pitch : Float = 1
    @State var playbackRate : Float = 0.5
    @State var selectedSample : LanguageSample = LanguageSample.all.first(where: {$0.languageCode == "it"})!
    @State var selectedVoice: AVSpeechSynthesisVoice = AVSpeechSynthesisVoice(language: "it")!
  
    var body: some View {
        VStack{
            HStack{
                Stepper("Pitch: \(pitch.formatted())", value: $pitch, in: 0...4, step: 0.10)
                Stepper("Rate: \(playbackRate.formatted())", value: $playbackRate, in: 0...1, step: 0.02)
            }.padding(.all)
            Spacer().fixedSize().padding()
            Picker("Lingua", selection: $selectedSample) {
                ForEach(LanguageSample.all, id: \.self) {
                    Text("Lingua: " + $0.languageCode.uppercased())
                }
                
            }
            .pickerStyle(.menu)
            .onChange(of: selectedSample){
                value in
                directions = value.text
            }.fixedSize()
            Picker("Voce", selection: $selectedVoice) {
                ForEach(AVSpeechSynthesisVoice.speechVoices().filter({
                    $0.language.contains(selectedSample.languageCode)
                }), id: \.self) {
                    Text("Voce: \($0.language) - \($0.name)")
                }
                
            }
            .onChange(of: selectedSample, perform: {newValue in self.selectedVoice = AVSpeechSynthesisVoice(language: selectedSample.languageCode)!})
            .pickerStyle(.menu)
            .onChange(of: selectedVoice){
                value in
                print(value)
            }.fixedSize()
            TextEditor(text: $directions ).frame(height: 50.0).padding(.all)
            
            Button(action: {
                let utterance = AVSpeechUtterance(string: directions)
                utterance.pitchMultiplier = pitch
                utterance.rate = playbackRate
                //utterance.voice = AVSpeechSynthesisVoice(language: selectedSample.languageCode)
                utterance.voice = selectedVoice
                self.viewModel.speak(utterance: utterance)
                print("************\(utterance.pitchMultiplier) - \(utterance.rate)")
            }) {
                Label("Play", systemImage: "play.fill").frame(width: 75, height: 75, alignment: .center)
            }.frame(width: 100, height: 100, alignment: .center)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



class SynthViewModel: NSObject {
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        self.speechSynthesizer.delegate = self
    }
    
    func speak(utterance: AVSpeechUtterance) {
        if speechSynthesizer.isSpeaking{
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        speechSynthesizer.speak(utterance)
    }
}

extension SynthViewModel: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Inizio")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("Pausa")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
      
  }
    
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
      
  }
    
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    print("Frase finita")
  }
    
}
