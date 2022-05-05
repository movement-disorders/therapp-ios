//
//  MyStreamer.swift
//  Therapp
//
//  Created by Luis Gizirian on 20/05/2021.
//

import Foundation

// Based on: https://stackoverflow.com/a/30865283
struct MyStreamer{
    
    lazy var fileHandle = FileHandle(forWritingAtPath: logPath)

    lazy var logPath: String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0]
        let filePath = path + "/log.txt"
        if FileManager.default.fileExists(atPath: filePath) == false {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        } else {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {}
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
//        print(filePath)
        return filePath

    }()

    mutating func write(_ string: String) {
//        print(fileHandle?.description ?? "no/handle")
        fileHandle?.seekToEndOfFile()
        if let data = string.data(using: String.Encoding.utf8){
            fileHandle?.write(data)
        }
    }
}
