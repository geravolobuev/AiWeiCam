//
//  ViewController.swift
//  AiWeiCam
//
//  Created by MAC on 04.06.2020.
//  Copyright © 2020 Gera Volobuev. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let finger = UIImage(named: "finger")
        let fingerView = UIImageView(image: finger)
        fingerView.frame = CGRect(x: 0, y: self.view.bounds.height / 2, width: self.view.bounds.width, height: self.view.bounds.height / 2)
        self.view.addSubview(fingerView)
        
        let button = UIButton(frame: CGRect(x: self.view.frame.width - 100, y: 50, width: 100, height: 50))
        button.setTitle("?", for: .normal)
        button.addTarget(self, action: #selector(QuestionButtonTapped), for: .touchUpInside)
        self.view.addSubview(button)
        
        startCamera()
    }
    

    
    func startCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        cameraOutput = AVCapturePhotoOutput()
        
        if let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.frame = self.view.frame
                    previewLayer.bounds = self.view.layer.bounds
                    self.view.layer.addSublayer(previewLayer)
                    
                    captureSession.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
        self.shutter()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let error = error {
            print("error occured : \(error.localizedDescription)")
        }
        
        if let dataImage = photo.fileDataRepresentation() {
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            
            let fingerImgage = UIImage(named: "finger")!
            let compositeImage = UIImage.imageByMergingImages(topImage: fingerImgage, bottomImage: image, scaleForTop: 2)
            let withGrayscale = compositeImage.withGrayscale
            
            UIImageWriteToSavedPhotosAlbum(withGrayscale, nil, nil, nil)
            
        } else {
            print("some error here")
        }
    }
    
    func shutter() {
        let flashView = UIView(frame: self.view.frame)
        flashView.alpha = 0
        flashView.backgroundColor = .black
        self.view.addSubview(flashView)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: { () -> Void in
                flashView.alpha = 1
            }, completion: {(finished: Bool) -> Void in
                UIView.animate(withDuration: 0.1, delay: 0.0, animations: {() -> Void in
                    flashView.alpha = 0.0
                })
            })
        }
    }
    
    @IBAction func tapScreenForPicture(_ sender: UIButton) {
        takePhoto()
    }
    
    
    
    @IBAction func QuestionButtonTapped(_ sender: UIButton) {
        let infoText = String("""
This app is based on the famous
“Study of Perspective” series
by Ai Weiwei
""")
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 2 ))
        label.textAlignment = .center
        label.textColor = .white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 3
        label.text = infoText
        
        let infoScreen = UIView(frame: self.view.frame)
        infoScreen.backgroundColor = .black
        infoScreen.tag = 100
        infoScreen.isUserInteractionEnabled = true
        
        infoScreen.addSubview(label)
        self.view.addSubview(infoScreen)
        
        let aSelector : Selector = #selector(removeSubview)
        let tapGesture = UITapGestureRecognizer(target:self, action: aSelector)
        infoScreen.addGestureRecognizer(tapGesture)
    }
    
    @objc func removeSubview(){
        print("Start remove sibview")
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }else{
            print("No!")
        }
    }
    
}

