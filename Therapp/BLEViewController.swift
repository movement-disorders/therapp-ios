//
//  BLEViewController.swift
//  Therapp
//
//  Created by Luis Gizirian on 12/05/2021.
//

import UIKit
import CoreBluetooth
import CoreData

class BLEViewController: UIViewController {
    
    var centralManager: CBCentralManager!
    var imuPeripheral: CBPeripheral!
    var readCharacteristic: CBCharacteristic!
    var writeCharacteristic: CBCharacteristic!
    
    var keepAlive = false
    
    var sampling = 0
    var accum = 0.0
    
    var stream = MyStreamer()
    let df = DateFormatter()
    
    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Sample measurement queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    @IBAction func onCalibrate(_ sender: UIButton) {
        let commCalibrateAccelerometer = Data([255, 170, 1, 1, 0])
        writeOutgoingValue(data: commCalibrateAccelerometer)
    }

    @IBAction func onRecord(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected {
            
//            keepAlive = true
            
            centralManager.connect(self.imuPeripheral)
                        
//            let commCalibrateAccelerometer = Data([0xff, 0xaa, 0x01, 0x01, 0x00])
//            writeOutgoingValue(data: commCalibrateAccelerometer)
//            let comm10hzSetRate = Data([0xFF, 0xAA, 0x03, 0x06, 0x00])
//            let comm20hzSetRate = Data([0xFF, 0xAA, 0x03, 0x07, 0x00])
//            let commSave = Data([0xFF, 0xAA, 0x00, 0x00, 0x00])
//            writeOutgoingValue(data: comm20hzSetRate)
//            writeOutgoingValue(data: commSave)
            
//            let commGetMoYe = Data([255, 170, 39, 48, 0])
//            let commGetHoDa = Data([255, 170, 39, 49, 0])
//            let commGetSeMi = Data([255, 170, 39, 50, 0])
//            let commGetStam = Data([255, 170, 39, 51, 0])
//            readValue(data: commGetMoYe)
//            readValue(data: commGetHoDa)
//            readValue(data: commGetSeMi)
//            readValue(data: commGetTimestamp)
        } else {
            keepAlive = false
            centralManager.cancelPeripheralConnection(imuPeripheral)
        }
        
    }
    //
    @IBAction func onSetRate(_ sender: UIButton) {
        
        let comm10hzSetRate = Data([255, 170, 3, 6, 0])
        let comm20hzSetRate = Data([255, 170, 3, 7, 0])
        let commSave = Data([255, 170, 0, 0, 0])
        writeOutgoingValue(data: comm20hzSetRate)
        writeOutgoingValue(data: commSave)
        print(readValue(data: Data([255, 170, 39, 3, 0])))
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        
        stream.write("date\tacx\tacy\tacz\tgyx\tgyy\tgyz\troll\tpitch\tyaw\n")
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func writeOutgoingValue(data: Data, withResponse: Bool = true){

        if let characteristic = writeCharacteristic {
            self.imuPeripheral.writeValue(
                                data,
                                for: characteristic,
                                type: (
                                    withResponse ?
                                    CBCharacteristicWriteType.withResponse :
                                    CBCharacteristicWriteType.withoutResponse)
                                )
        }

    }


    func readValue(data: Data) {

        if let characteristic = readCharacteristic {
            self.imuPeripheral.readValue(for: characteristic)
        }

    }
    
}

extension BLEViewController: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state in .unknown")
        case .resetting:
            print("central.state in .resetting")
        case .unsupported:
            print("central.state in .unsupported")
        case .unauthorized:
            print("central.state in .unauthorized")
        case .poweredOff:
                print("central.state in .poweredOff")
        case .poweredOn:

            print("central.state in .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)

        @unknown default:
            print("invalid option/enum for central.state")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if (peripheral.name == "    ") {
            imuPeripheral = peripheral
            imuPeripheral.delegate = self
            centralManager.stopScan()
            //centralManager.connect(imuPeripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to " + (peripheral.name ?? "unknown"))
        peripheral.discoverServices(nil)
    }


    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Force disconnected...")
        if keepAlive { centralManager.connect(peripheral) }
    }

}

extension BLEViewController: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("discover services error, error is \(error)");
            return;
        }
        
        guard let services = peripheral.services else { return }

        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
            
            print("Service: \(service.debugDescription)")
        }
    }


    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        if let error = error {
            print("discover characteristics error, error is \(error)");
            return;
        }
        
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            
            let uuidString = characteristic.uuid.uuidString;
            if uuidString.lowercased().contains("ffe9") {
                self.writeCharacteristic = characteristic;
            } else if uuidString.lowercased().contains("ffe4") {
                self.readCharacteristic = characteristic;
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
            }
        }
        
        if (!self.keepAlive && self.writeCharacteristic != nil && self.readCharacteristic != nil) {
            let commCalibrateAccelerometerBegin = Data([0xFF, 0xAA, 0x01, 0x01, 0x00])
            let commCalibrateAccelerometerEnd = Data([0xFF, 0xAA, 0x01, 0x00, 0x00])
            writeOutgoingValue(data: commCalibrateAccelerometerBegin)
            
            // TODO: solve this in a non blocking way.
            do {
                sleep(5)
            }
            //
            
            writeOutgoingValue(data: commCalibrateAccelerometerEnd)
            //let comm10hzSetRate = Data([0xFF, 0xAA, 0x03, 0x06, 0x00])
            let comm20hzSetRate = Data([0xFF, 0xAA, 0x03, 0x07, 0x00])
            let commSave = Data([0xFF, 0xAA, 0x00, 0x00, 0x00])
            writeOutgoingValue(data: comm20hzSetRate)
            
            // TODO: solve this in a non blocking way.
            do {
                sleep(1)
            }
            //
            
            writeOutgoingValue(data: commSave)
            
            let commGetMoYe = Data([0xFF, 0xAA, 0x27, 0x30, 0x00])
            let commGetHoDa = Data([0xFF, 0xAA, 0x27, 0x31, 0x00])
            let commGetSeMi = Data([0xFF, 0xAA, 0x27, 0x32, 0x00])
            let commGetStam = Data([0xFF, 0xAA, 0x27, 0x33, 0x00])
            writeOutgoingValue(data: commGetMoYe)
            writeOutgoingValue(data: commGetHoDa)
            writeOutgoingValue(data: commGetSeMi)
            writeOutgoingValue(data: commGetStam)
            
            // TODO: solve this in a non blocking way.
            do {
                sleep(1)
            }
            //
            
            writeOutgoingValue(data: commSave)
            
            self.keepAlive = true
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("called")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let characteristic = readCharacteristic {
            dealWithReadCharacteristicValue(payload: characteristic.value ?? Data())
        } else {
            print("uuid: \(characteristic.uuid.uuidString), alternative: \(characteristic.value ?? nil)")
        }

    }

    func dealWithReadCharacteristicValue(payload: Data) {

        let bytes = [UInt8](payload)
        guard bytes.count != 0 else {
            return
        }

        if bytes.count == 1 {
            print(bytes[0])
        }

        if (bytes.count > 1) {
            let header: UInt8 = bytes[0] & 0xff
            let flag: UInt8 = bytes[1] & 0xff
            print(bytes)

             

            if (flag == 0x61) {
                if (bytes.count != 20) {
                    print("0x61 not in correct format")
                    return;
                }
                
                queue.addOperation {
                    
                    let ax: Double = (Double)((bytes[3] << 8) | (bytes[2] & 0xff)) / 32768.0 * 16
                    let ay: Double = (Double)((bytes[5] << 8) | (bytes[4] & 0xff)) / 32768.0 * 16
                    let az: Double = (Double)((bytes[7] << 8) | (bytes[6] & 0xff)) / 32768.0 * 16

                    let wx: Double = (Double)((bytes[9] << 8) | (bytes[8] & 0xff)) / 32768.0 * 2000
                    let wy: Double = (Double)((bytes[11] << 8) | (bytes[10] & 0xff)) / 32768.0 * 2000
                    let wz: Double = (Double)((bytes[13] << 8) | (bytes[12] & 0xff)) / 32768.0 * 2000

                    let roll: Double = (Double)((bytes[15] << 8) | (bytes[14] & 0xff)) / 32768.0 * 180
                    let pitch: Double = (Double)((bytes[17] << 8) | (bytes[16] & 0xff)) / 32768.0 * 180
                    let yaw: Double = (Double)((bytes[19] << 8) | (bytes[18] & 0xff)) / 32768.0 * 180
                    
                    let date = Date()
                    let dateString = self.df.string(from: date)
                    
                    let line = "\(dateString)\t\(String(ax))\t\(String(ay))\t\(String(az))\t\(String(wx))\t\(String(wy))\t\(String(wz))\t\(String(roll))\t\(String(pitch))\t\(String(yaw))\n"
                    
                    self.stream.write(line)

//                    DispatchQueue.main.async {

//                    }
                }
                
            } else if (flag == 0x71) {
                let regH: UInt8 = bytes[2] & 0xff
                let regL: UInt8 = bytes[3] & 0xff

                if (regH == 0x3A && regL == 0x00) {
                    let mx: Double = (Double)((bytes[5] << 8) | (bytes[4] & 0xff));
                    let my: Double = (Double)((bytes[7] << 8) | (bytes[6] & 0xff));
                    let mz: Double = (Double)((bytes[9] << 8) | (bytes[8] & 0xff));
                } else if (regH == 0x45 && regL == 0x00) {
                    let p: UInt8 = (bytes[7] << 24) | (bytes[6] << 16) | (bytes[5] << 8) | (bytes[4]);
				                    let h: UInt8 = (bytes[11] << 24) | (bytes[10] << 16) | (bytes[9] << 8) | (bytes[8]);
                } else if (regH == 0x41 && regL == 0x00) {
                    let d0: Double = (Double)((bytes[5] << 8) | (bytes[4] & 0xff));
                    let d1: Double = (Double)((bytes[7] << 8) | (bytes[6] & 0xff));
                    let d2: Double = (Double)((bytes[9] << 8) | (bytes[8] & 0xff));
                    let d3: Double = (Double)((bytes[11] << 8) | (bytes[10] & 0xff));
                } else if (regH == 0x51 && regL == 0x00) {
                    let q0: Double = (Double)((bytes[5] << 8) | (bytes[4] & 0xff)) / 32768.0;
                    let q1: Double = (Double)((bytes[7] << 8) | (bytes[6] & 0xff)) / 32768.0;
                    let q2: Double = (Double)((bytes[9] << 8) | (bytes[8] & 0xff)) / 32768.0;
                    let q3: Double = (Double)((bytes[11] << 8) | (bytes[10] & 0xff)) / 32768.0;
                } else if (regH == 0x40 && regL == 0x00) {
                    let t: Double = (Double)((bytes[5] << 8) | (bytes[4] & 0xff)) / 100.0;
                }
            } else {
                print("Unknown flag :(")}
        }
    }

}
