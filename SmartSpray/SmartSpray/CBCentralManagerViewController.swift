//
//  CBCentralManagerViewController.swift
//  SmartSpray
//
//  Created by Patrick Sheehan on 1/11/15.
//  Copyright (c) 2015 MSDS. All rights reserved.
//

import UIKit
import CoreBluetooth

class CBCentralManagerViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    let PERIPHERAL_KEY = "smartSprayers"
    let TRANSFER_SERVICE_UUID = "FB694B90-F49E-4597-8306-171BBA78F846"
    let TRANSFER_CHARACTERISTIC_UUID = "EB6727C4-F184-497A-A656-76B0CDAC633A"

    var myCentralManager: CBCentralManager?
    var myPeripheral: CBPeripheral?
    var smartSprayers = NSMutableArray()

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var myTextView: UITextView!
    
    override init() {
        super.init(nibName: "CBCentralManagerViewController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(nibName: "CBCentralManagerViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myCentralManager = CBCentralManager(delegate: self, queue: nil)
        self.startScan()
    }

    override func viewWillDisappear(animated: Bool) {
        myCentralManager?.stopScan()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Start/Stop Scan methods
    
    func isLECapableHardware() -> Bool {
        
        var state = ""
        
        switch (self.myCentralManager!.state)
        {
        case .Unsupported:
            state = "The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case .Unauthorized:
            state = "The app is not authorized to use Bluetooth Low Energy.";
            break;
        case .PoweredOff:
            state = "Bluetooth is currently powered off.";
            break;
        case .PoweredOn:
            return true;
        default:
            return false;
            
        }
        
        NSLog("Central manager state: %@", state);
        
        return false;
    }
    
    func startScan() {
        println("Scanning for peripherals")
        
        var options = NSDictionary(object: NSNumber(bool: true), forKey:CBCentralManagerScanOptionAllowDuplicatesKey)
        var services = NSArray(object: CBUUID(string: TRANSFER_SERVICE_UUID))
        self.myCentralManager?.scanForPeripheralsWithServices(services, options: options)
    }
    
    func stopScan() {
        println("Stopping scan")
        self.myCentralManager?.stopScan()
    }
    
    // MARK: - CBCentralManager delegate methods
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("centralManagerDidUpdateState")
        
        if self.isLECapableHardware() {
            self.startScan()
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Discovered periferal: \(peripheral) at \(RSSI)")
        
        if self.myPeripheral != peripheral {
            self.myPeripheral = peripheral
            
            println("Connecting to peripheral \(peripheral)")
            self.myCentralManager?.connectPeripheral(peripheral, options: nil)
        }
        
        //        var peripherals = self.mutableArrayValueForKey(peripheralKey)
        //
        //        if !self.smartSprayers.containsObject(peripheral) {
        //            peripherals.addObject(peripheral)
        //        }
        //
        //        // Retrieve already known devices
        //        manager?.retrievePeripheralsWithIdentifiers([peripheral.identifier])
    }
    
    func centralManager(central: CBCentralManager!, didRetrievePeripherals peripherals: [AnyObject]!) {
        println("Retrieved peripheral: \(peripherals.count) - \(peripherals)")
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        
        self.myCentralManager?.stopScan()
        println("Scanning stopped")
        
        self.smartSprayers.removeAllObjects()
        
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: TRANSFER_SERVICE_UUID)])
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        
        var options = NSDictionary(object: NSNumber(bool: true), forKey:CBCentralManagerScanOptionAllowDuplicatesKey)
        
        myCentralManager?.scanForPeripheralsWithServices([CBUUID(string: TRANSFER_SERVICE_UUID)], options: options)
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Fail to connect to peripheral: \(peripheral) with error = \(error.localizedDescription)")
        
        //        connectButton.title = "Connect"
        
        if let p = self.myPeripheral {
            p.delegate = nil
        }
        
        self.myPeripheral = nil
        
    }
    
    // MARK: - CBPeripheral delegate methods
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if (error != nil) {
            // self.cleanup()
            return;
        }
        
        //        for service: CBService in peripheral.services as CBService {
        //            peripheral.discoverServices([CBUUID(string: TRANSFER_SERVICE_UUID)])
        //        }
        println("didDiscoverServices")
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        println("didDiscoverCharacteristicsForService")
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("didUpdateValueForCharacteristic")
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if characteristic.UUID.isEqual(CBUUID(string: TRANSFER_CHARACTERISTIC_UUID)) {
            return;
        }
        
        if characteristic.isNotifying {
            println("Notification began on \(characteristic)")
        }
        else { // Notification has stopped
            myCentralManager?.cancelPeripheralConnection(peripheral)
        }
    }

}
