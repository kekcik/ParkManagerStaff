//
//  ViewController.swift
//  ParkManagerStaff
//
//  Created by Ivan Trofimov on 30/01/2018.
//  Copyright © 2018 Ivan Trofimov. All rights reserved.
//

import AVFoundation
import UIKit
import SwiftSpinner
import QRCode

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITableViewDelegate, UITableViewDataSource {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var deviceView: UIView!
    @IBOutlet weak var getDeviceButton: UIButton!
    @IBOutlet weak var putDeviceButton: UIButton!
    @IBOutlet weak var devicesTableView: UITableView!
    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var deviceButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    var users = [User]() {
        didSet {
            usersTableView.reloadData()
        }
    }
    
    var devices = [Device]() {
        didSet {
            devicesTableView.reloadData()
        }
    }
    
    var deviceId = "" {
        didSet {
            if deviceId == "" {
                deviceView.backgroundColor = UIColor.red
                deviceLabel.text = "Девайс"
            } else {
                deviceView.backgroundColor = UIColor.green
            }
            updateButton()
        }
    }
    
    var userId = "" {
        didSet {
            if userId == "" {
                userView.backgroundColor = UIColor.red
                userLabel.text = "Имя"
            } else {
                userView.backgroundColor = UIColor.green
            }
            updateButton()
        }
    }
    
    func updateButton() {
        if deviceId == "" {
            getDeviceButton.alpha = 0
            putDeviceButton.alpha = 0
        } else {
            if userId == "" {
                getDeviceButton.alpha = 0
                putDeviceButton.alpha = 1
            } else {
                getDeviceButton.alpha = 1
                putDeviceButton.alpha = 1
            }
        }
    }
    @IBAction func clearDeviceButtonAction(_ sender: Any) {
        deviceId = ""
    }
    
    @IBAction func clearNameButtonAction(_ sender: Any) {
        userId = ""
    }
    
    func fetchDevices() {
        ApiManager.shared.fetchDevices { self.devices = $0 }
    }
    
    func fetchDevicesInLoop() {
        fetchDevices()
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
            self.fetchDevicesInLoop()
        })
    }
    
    func fetchUsers() {
        ApiManager.shared.fetchUsers { self.users = $0 }
    }
    
    func fetchUsersInLoop() {
        fetchUsers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
            self.fetchUsersInLoop()
        })
    }
    
    @objc func longTapDevice(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            let data = "d|\(deviceLabel.text ?? "")|\(deviceId)".data(using: .utf8)!
            let qrCode = QRCode(data)
            share(shareImage: qrCode.image!)
        }
    }
    
    @objc func longTapUser(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            let data = "u|\(userLabel.text ?? "")|\(userId)".data(using: .utf8)!
            let qrCode = QRCode(data)
            share(shareImage: qrCode.image!)
        }
    }
    
    func share(shareImage: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [shareImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = userButton
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchUsersInLoop()
        fetchDevicesInLoop()
        
        let longGestureDevice = UILongPressGestureRecognizer(target: self, action: #selector(longTapDevice(_:)))
        deviceButton.addGestureRecognizer(longGestureDevice)

        let longGestureUser = UILongPressGestureRecognizer(target: self, action: #selector(longTapUser(_:)))
        userButton.addGestureRecognizer(longGestureUser)
        
        getDeviceButton.alpha = 0
        putDeviceButton.alpha = 0
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: nil, position: .front) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            found(code: stringValue)
        }
    }
    
    func found(code: String) {
        print(code)
        let codeArray = code.split{$0 == "|"}.map(String.init)
        if codeArray.count != 3 { return; }
        let type = codeArray[0]
        let name = codeArray[1]
        let codeId = codeArray[2]
        switch type {
        case "u":
            userLabel.text = "\(name)"
            userId = codeId
        case "d":
            deviceLabel.text = "\(name)"
            deviceId = codeId
        default:
            break
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    var invert = false
    @IBAction func cameraViewButtonAction(_ sender: Any) {
        cameraView.transform = CGAffineTransform(rotationAngle: invert ? 0 : CGFloat(Double.pi) )
        invert = !invert
    }
    
    @IBAction func getDeviceButtonAction(_ sender: Any) {
        if deviceId == "" || userId == "" { return }
        SwiftSpinner.show("Регистрируем девайс за вами")
        ApiManager.shared.getDevice(with: deviceId, userId: userId) {
            self.devices.first(where: { (device) -> Bool in
                device.uid == self.deviceId
            })?.userId = self.userId
            self.deviceId = ""
            self.userId = ""
            self.devicesTableView.reloadData()
            SwiftSpinner.hide()
        }
        fetchDevices()
    }
    
    @IBAction func putDeviceButtonAction(_ sender: Any) {
        if deviceId == "" { return }
        SwiftSpinner.show("Возвращаем девайс")
        ApiManager.shared.putDevice(with: deviceId) {
            self.devices.first(where: { (device) -> Bool in
                device.uid == self.deviceId
            })?.userId = nil
            self.userId = ""
            self.deviceId = ""
            self.devicesTableView.reloadData()
            SwiftSpinner.hide()
        }
        fetchDevices()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 0:
            return devices.count
        case 1:
            return users.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 0:
            let cell = devicesTableView.dequeueReusableCell(withIdentifier: "deviceCell") as! DeviceTableViewCell
            let device = devices[indexPath.row]
            cell.user = users.first(where: { $0.uid == device.userId })
            cell.device = device
            cell.callback = { device in
                self.deviceId = device.uid
                self.deviceLabel.text = device.name
            }
            return cell
        case 1:
            let cell = usersTableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
            cell.user = users[indexPath.row]
            cell.callback = { user in
                self.userId = user.uid
                self.userLabel.text = user.name
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}
