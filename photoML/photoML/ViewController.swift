//
//  ViewController.swift
//  photoML
//
//  Created by pensopha kamolnawin on 11/2/2561 BE.
//  Copyright © 2561 P&J Mobile Development. All rights reserved.
//

import UIKit
import AVKit
import Vision
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var model: Inceptionv3!
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var strBtn: UIButton!
    @IBOutlet weak var txtSpeak: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice)  else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
      
        
        
    }
    @IBAction func spkBtn(_ sender: Any) {
        let toSay = AVSpeechUtterance(string: txtSpeak.text!)
        toSay.voice = AVSpeechSynthesisVoice(language: "en-US")
        toSay.rate = 0.5;
        let sythesizer = AVSpeechSynthesizer()
        sythesizer.speak(toSay);
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    @IBAction func readBtn(_ sender: Any) {
       
        let toSay = AVSpeechUtterance(string: txtLabel.text!)
        toSay.voice = AVSpeechSynthesisVoice(language: "en-US")
        toSay.rate = 0.5;
        let sythesizer = AVSpeechSynthesizer()
        sythesizer.speak(toSay);
        
        
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("Camera was able to capture a frame", Date())
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else { return }
       /* guard let pb = pixelBuffer, let output = try? model.prediction(image: pb) else {
            
            fatalError("Unexpected runtime error.")
        }*/
        let request = VNCoreMLRequest(model: model) {
            (finishedReq, err) in
            
          //  print(finishedReq.results)
            
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
          //  guard let lastresult = results.f else { return }
            
            guard let firstObservation = results.first else { return }
        
            DispatchQueue.main.async { // Correct
                 self.txtLabel.text = "\(firstObservation.identifier)"
                
                // \(firstObservation.confidence)
            }
           
                print(firstObservation)
            print(firstObservation.identifier, firstObservation.confidence)
        }
      
       try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

