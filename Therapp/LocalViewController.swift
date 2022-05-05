//
//  ViewController.swift
//  Therapp
//
//  Created by Luis Gizirian on 02/04/2021.
//

import UIKit
import CoreData
import CoreMotion

class LocalViewController: UIViewController {
    
    var stream = MyStreamer()
    let df = DateFormatter()
    let motion = CMMotionManager()
    
    @IBOutlet weak var feedback: UILabel!
    
    @IBAction func onRecord(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected {
            getMotionData()
        } else {
            motion.stopDeviceMotionUpdates()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        
        stream.write("date\tacx\tacy\tacz\tgyx\tgyy\tgyz\n")
    }
    
    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Sample measurement queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    var samples: Int64 = 0
    
    func getMotionData() {
        
         if motion.isDeviceMotionAvailable {
            let begun = Date()
            let lastBoot = Date() - ProcessInfo.processInfo.systemUptime
            motion.deviceMotionUpdateInterval = 1.0 / 10.0
            motion.startDeviceMotionUpdates(to: queue){(data, error) in
                if let motion = data {
                    let date = Date(timeInterval: motion.timestamp, since: lastBoot)
                    let dateString = self.df.string(from: date)
                    
                    let line = "\(dateString)\t\(motion.userAcceleration.x)\t\(motion.userAcceleration.y)\t\(motion.userAcceleration.z)\t\(motion.rotationRate.x)\t\(motion.rotationRate.y)\t\(motion.rotationRate.z)\n"
                    
                    self.stream.write(line)
                    self.samples += 1
                    
                    // UI updates (if any) source - https://nshipster.com/cmdevicemotion/#queueing-up
                    DispatchQueue.main.async {
                        self.feedback.text = "Samples: \(self.samples)\nBegun at: \(self.df.string(from: begun))"
                    }
                    //
                }
            }
        }
    }
}
