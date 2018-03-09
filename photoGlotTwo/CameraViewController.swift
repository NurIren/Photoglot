//
//  ViewController.swift
//  SmartCameraLBTA
//
//  Created by Brian Voong on 7/12/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//
//live capture
//displays the objects identified on top
//once translate is selected, will translate the last word captured
//uses Apple vision Resnet50 model and Microsoft Azure Text Translate


import UIKit
import AVKit
import Vision
import Foundation


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var cameraHolder: UIView!
     var newResponseString = "";//temp variable, to get response from authorization
    var wordToTranslate = "";
    var translatedWord = "hello";
    var fromLanguage = "en";
    var toLanguage = "tr";
    var translateLanguageWord = String();
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    let identifierLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
   
    @IBOutlet weak var translatedWordLabel: UILabel!
    @IBOutlet weak var wordToBeTranslatedLabel: UILabel!
    @IBOutlet weak var identifiedObject: UILabel!
    //@IBOutlet weak var cameraLoc: UIView!
    @IBAction func translateButton(_ sender: Any) {
        self.wordToBeTranslatedLabel.text = wordToTranslate;
        
        translateWord()
       // print("hello-----------------------\(self.translatedWord)");
        
    }
    //translate the word
    func translateWord(){
        //let firstWord  = wordToTranslate.components(separatedBy: " ").first
        //print(firstWord);
        wordToTranslate = addUnderScores(XML: wordToTranslate);
        var urlString = "https://api.microsofttranslator.com/v2/Http.svc/Translate?text=" + wordToTranslate + "&from=" + fromLanguage + "&to=" + toLanguage;
        //print(urlString);
        let newurl = URL(string: urlString)!
        
        var newrequest = URLRequest(url: newurl)
        newrequest.addValue(newResponseString, forHTTPHeaderField: "Authorization ")
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        newrequest.httpMethod = "GET"
        let newpostString = ""
        newrequest.httpBody = newpostString.data(using: .utf8)
        let newtask = URLSession.shared.dataTask(with: newrequest) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            let xmlString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
            let responseString = String(data: data, encoding: .utf8)!
           self.translatedWord = self.translationFromXML(XML: xmlString!)
            print("responseString = \(responseString)")
            print(self.translatedWord);
            DispatchQueue.main.async {
            self.translatedWordLabel.text = self.translatedWord;
            }
            
        }
        newtask.resume()
        
    }
    //pick the language to translate to
    func passedLanguage(){
        //let languages = ["Spanish", "French", "German", "Turkish"]
        switch translateLanguageWord {
        case "Spanish":
            toLanguage = "es";
        case "French":
            toLanguage = "fr";
        case "German":
            toLanguage = "de";
        case "Turkish":
            toLanguage = "tr";
        default:
            print("Error passing in language of choice! ");
        }
        
    }
    //isolate the translated word
    private func translationFromXML(XML: String) -> String {
        let translation = XML.replacingOccurrences(of: "<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">", with: "")
        return translation.replacingOccurrences(of: "</string>", with: "")
    }
    private func addUnderScores(XML: String) -> String {
        var firstPart = XML;
        var fullWord = "";
        if XML.contains(","){
            if let range = XML.range(of: ",") {
                firstPart = XML.substring(to: range.lowerBound)
                //firstPart = XML.substringToIndex(range.startIndex)
                print(firstPart) // print Hello
            }
        }
        
        fullWord = firstPart.replacingOccurrences(of: " ", with: "+")
        return fullWord;
    }
    //get an authorization key
    //needs to be done every ten minutes
    func authorizationKey(){
        
        let url = URL(string: "https://api.cognitive.microsoft.com/sts/v1.0/issueToken")!
        
        var request = URLRequest(url: url)
        request.addValue("[INSERT_API_KEY]", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = ""
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            self.newResponseString = "Bearer " + responseString!;
            //print(self.newResponseString);
            //print("responseString = \(responseString)")
        }
        task.resume()
     
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        passedLanguage();
        // here is where we start up the camera
        // for more details visit: https://www.letsbuildthatapp.com/course_video?id=1252
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = cameraHolder.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
        //        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
       //setupIdentifierConfidenceLabel()
        authorizationKey();
       
    }
   
    
    fileprivate func setupIdentifierConfidenceLabel() {
        view.addSubview(identifierLabel)
        identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //        print("Camera was able to capture a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            //perhaps check the err
            
            //            print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.identifiedObject.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                
            }
            self.wordToTranslate = firstObservation.identifier;
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
}

