//
//  BLEDiscovery.swift
//  Orbit 360 Facetracking
//
//  Created by Philipp Meyer on 17.10.16.
//  Copyright © 2016 Philipp Meyer. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BLEDiscovery: NSObject, CBCentralManagerDelegate {

    var centralManager: CBCentralManager!
    let onDeviceFound: (CBPeripheral, NSString) -> Void
    let onDeviceConnected: (CBPeripheral) -> Void
    let services: [CBUUID]
    var connectedPeripherals: [CBPeripheral] = []
    
    public init(onDeviceFound: @escaping (CBPeripheral, NSString) -> Void, onDeviceConnected: @escaping (CBPeripheral) -> Void, services: [CBUUID]) {
        self.onDeviceFound = onDeviceFound
        self.onDeviceConnected = onDeviceConnected
        self.services = services
        
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: services, options: nil)
        print("Searching for BLE Devices")
    }

    func disconnectPeripheral(peripheralIndex: Int) {
        centralManager.cancelPeripheralConnection(connectedPeripherals[peripheralIndex])
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .poweredOff:
            break;

        case .unauthorized:
            // Indicate to user that the iOS device does not support BLE.
            break
            
        case .unknown:
            // Wait for another event
            break
            
        case .poweredOn:
            self.startScanning()
            
        case .resetting:
            break;

        case .unsupported:
            break;
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let nameOfDeviceFound = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        if let name = nameOfDeviceFound {
            self.onDeviceFound(peripheral, name)
        }
        
    }
    
    public func connectPeripheral(_ peripheral: CBPeripheral) {
        // Connect to peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //let bleService = BTService(initWithPeripheral: peripheral)
        self.onDeviceConnected(peripheral)
        print(peripheral)
        connectedPeripherals.append(peripheral)
        // Stop scanning for new devices
        central.stopScan()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripherals.removeAll()
        // Start scanning for new devices
        self.startScanning()
    }

}
