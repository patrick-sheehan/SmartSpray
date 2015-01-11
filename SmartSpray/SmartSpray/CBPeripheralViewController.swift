//
//  CBPeripheralViewController.swift
//  SmartSpray
//
//  Created by Patrick Sheehan on 1/11/15.
//  Copyright (c) 2015 MSDS. All rights reserved.
//

import UIKit
import CoreBluetooth

class CBPeripheralViewController: UIViewController, CBPeripheralManagerDelegate, UITextViewDelegate {

    let TRANSFER_SERVICE_UUID = "FB694B90-F49E-4597-8306-171BBA78F846"
    let TRANSFER_CHARACTERISTIC_UUID = "EB6727C4-F184-497A-A656-76B0CDAC633A"
    let NOTIFY_MTU = 20

    var myPeripheralManager = CBPeripheralManager()
    var myTransferCharacteristic = CBMutableCharacteristic()
    var dataToSend = NSData()
    var sendDataIndex = NSInteger()
    
    override init() {
        super.init(nibName: "CBPeripheralViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(nibName: "CBPeripheralViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        var options = NSDictionary(object: CBUUID(string:TRANSFER_SERVICE_UUID), forKey:CBAdvertisementDataServiceUUIDsKey)

        self.myPeripheralManager.startAdvertising(options)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        println("peripheralManagerDidUpdateState")
        
        if peripheral.state != CBPeripheralManagerState.PoweredOn {
            return
        }
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        println("peripheral manager didSubscribeToCharacteristic")
        
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        self.sendData()
    }
    @IBAction func activateFirstStage() {
        
    }
    
    @IBAction func activateSecondStage() {
        
    }
    
    func sendData() {
        var sendingEOM = false
    
        // end of message?
        if (sendingEOM) {
            var didSend = self.myPeripheralManager.updateValue(NSData(base64EncodedString: "EOM", options: nil), forCharacteristic: myTransferCharacteristic, onSubscribedCentrals: nil)
        
            if (didSend) {
                // It did, so mark it as sent
                sendingEOM = false
            }
            // didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return;
        }
        
        // We're sending data
        // Is there any left to send?
        if (self.sendDataIndex >= self.dataToSend.length) {
            // No data left.  Do nothing
            return;
        }
        
        // There's data left, so send until the callback fails, or we're done.
        var didSend = true
        
        while didSend {
            // Work out how big it should be
            var amountToSend = self.dataToSend.length - self.sendDataIndex;
        
            // Can't be longer than 20 bytes
            if (amountToSend > NOTIFY_MTU) {
                amountToSend = NOTIFY_MTU
            }
        
            // Copy out the data we want
             var chunk = NSData(bytes:self.dataToSend.bytes+self.sendDataIndex, length:amountToSend)
        
            didSend = self.myPeripheralManager.updateValue(chunk, forCharacteristic:self.myTransferCharacteristic, onSubscribedCentrals:nil)
        
            // If it didn't work, drop out and wait for the callback
            if (!didSend) {
                return;
            }
        
            var stringFromData = NSString(data: chunk, encoding: NSUTF8StringEncoding)
            println("Sent: \(stringFromData)")
        
            // It did send, so update our index
            self.sendDataIndex += amountToSend;
            
            // Was it the last one?
            if (self.sendDataIndex >= self.dataToSend.length) {
            
                // Set this so if the send fails, we'll send it next time
                sendingEOM = true
                var eomSent = self.myPeripheralManager.updateValue(NSData(base64EncodedString: "EOM", options: nil), forCharacteristic: self.myTransferCharacteristic, onSubscribedCentrals: nil)

                if (eomSent) {
                    // It sent, we're all done
                    sendingEOM = false
                    println("Sent: EOM");
                }
            
                return
            }
        
        }
    }
}
