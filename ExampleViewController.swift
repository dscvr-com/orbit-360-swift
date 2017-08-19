//
//  ViewController.swift
//  FrameWorkTest
//
//  Created by Philipp Meyer on 19.08.17.
//  Copyright © 2017 Philipp Meyer. All rights reserved.
//

import UIKit
import Orbit360Framework
import CoreBluetooth

class ViewController: UIViewController {

    var btDiscovery: BLEDiscovery!
    var btService : BLEService?
    var btMotorControl : MotorControl?

    var btDevices = [CBPeripheral]()

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.remoteTop), name: NSNotification.Name(rawValue: remoteTopNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.remoteBottom), name: NSNotification.Name(rawValue: remoteBottomNotificationKey), object: nil)

        btDiscovery = BLEDiscovery(onDeviceFound: onDeviceFound, onDeviceConnected: onDeviceConnected, services: [MotorControl.BLEServiceUUID])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func onDeviceFound(device: CBPeripheral, name: NSString) {
        self.btDevices = self.btDevices + [device]
        btDiscovery.connectPeripheral(btDevices[0])
    }

    func onDeviceConnected(device: CBPeripheral) {
        btService = BLEService(initWithPeripheral: device, onServiceConnected: onServiceConnected, bleService: MotorControl.BLEServiceUUID, bleCharacteristic: [MotorControl.BLECharacteristicUUID, MotorControl.BLECharacteristicResponseUUID])
        btService?.startDiscoveringServices()
    }

    func onServiceConnected(service: CBService) {
        btMotorControl = MotorControl(s: service, p: service.peripheral, allowCommandInterrupt: true)
        //Orbit 360 connected and ready to use
        btMotorControl?.moveX(1000, speed: 1000)
    }

    func remoteTop() {
        print("top button pressed")
    }

    func remoteBottom() {
        print("bottom button pressed")
    }

}

