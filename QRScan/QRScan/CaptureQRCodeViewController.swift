//
//  CaptureQRCodeViewController.swift
//  QRScan
//
//  Created by SwiftMan on 2020/06/08.
//  Copyright © 2020 com.swiftman.qrscan. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

// https://developer.apple.com/documentation/avfoundation/avcapturemetadataoutputobjectsdelegate
final class CaptureQRCodeViewController: UIViewController {
    private var _captureSession: AVCaptureSession?
    private var _videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var _qrCodeFrameView: UIView?
    private var _qrCodeLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _captureQRCode()
    }
}

extension CaptureQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    private func _captureQRCode() {
        // Create an instance of the AVCaptureDevice and provide the video as the media type parameter.
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
         
        do {
            // Create an instance of the AVCaptureDeviceInput class using the device object and intialise capture session
            let input = try AVCaptureDeviceInput(device: captureDevice)
            _captureSession = AVCaptureSession()
            _captureSession?.addInput(input)
            
            // Create a instance of AVCaptureMetadataOutput object and set it as the output device the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            _captureSession?.addOutput(captureMetadataOutput)
            // Set delegate with a default dispatch queue
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //set meta data object type as QR code, here we can add more then one type as well
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]


            guard let captureSession = _captureSession else { return }
            // Initialize the video preview layer and add it as a sublayer to the viewcontroller view's layer.
            _videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            _videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            _videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(_videoPreviewLayer!)

            // Start capture session.
            _captureSession?.startRunning()
            
            _qrCodeFrameView = UIView()
            _qrCodeFrameView?.backgroundColor = .clear
            _qrCodeFrameView?.layer.borderColor = UIColor.yellow.cgColor
            _qrCodeFrameView?.layer.borderWidth = 5.0
            self.view.addSubview(_qrCodeFrameView!)
            
            _qrCodeLabel = UILabel()
            _qrCodeLabel?.frame = CGRect(x: 100, y: 100, width: 300, height: 50)
            self.view.addSubview(_qrCodeLabel!)
        } catch {
            // If any error occurs, let the user know. For the example purpose just print out the error
            print(error)
            return
        }
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array contains at least one object. If not no QR code is in our video capture
        if metadataObjects.isEmpty {
            // NO QR code is being detected.
            return
        }
        
        // Get the metadata object and cast it to `AVMetadataMachineReadableCodeObject`
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then get the string value from meta data
            let barCodeObject = _videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            _qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let qrCode = metadataObj.stringValue{
               // metadataObj.stringValue is our QR code
                print("qrCode: \(qrCode)")
                _qrCodeLabel?.text = qrCode
            }
        }
    }
}
