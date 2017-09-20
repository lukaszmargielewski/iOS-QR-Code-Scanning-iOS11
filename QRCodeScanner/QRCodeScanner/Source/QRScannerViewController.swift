//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Lukasz Marcin Margielewski on 20/09/2017.
//  Copyright © 2017 Unwire ApS. All rights reserved.
//

import UIKit
import AVFoundation


class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private lazy var captureSession: AVCaptureSession =  { AVCaptureSession() }()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = { AVCaptureVideoPreviewLayer(session: captureSession) } ()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - View life-cycle

    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRCapture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartQRScanner()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }


    // MARK: - QR Capture

    private func setupQRCapture() {

        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if authStatus == .restricted || authStatus == .denied {
            fatalError("Not authorized")
        } else if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                if !granted {
                    fatalError("Not granted")
                }
            })
        }

        let metadataOutput = AVCaptureMetadataOutput()

        guard
            let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
            captureSession.canAddOutput(metadataOutput),
            captureSession.canAddInput(videoInput) else {
                fatalError("Not available")
        }

        captureSession.addOutput(metadataOutput)
        captureSession.addInput(videoInput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        let availableTypes = metadataOutput.availableMetadataObjectTypes
        print("available types: \(availableTypes)")
        availableTypes.forEach { type in
            print(" \(type)")
        }
        let qrType = AVMetadataObject.ObjectType.qr
        metadataOutput.metadataObjectTypes = [qrType]

        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }

    private func restartQRScanner() {
        captureSession.stopRunning()
        captureSession.startRunning()
    }


    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(captureOutput: AVCaptureMetadataOutput,
                                 didOutput metadataObjects: [AVMetadataObject],
                                 from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        guard let qrCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            print("Unexpected metadata object in objects: \(metadataObjects)")
            return
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        guard let successString = qrCode.stringValue else { return }
        print("Recognized QR code: \(successString)")
    }
}
