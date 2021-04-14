//
//  BLEOTAMgr.swift
//  YYBLEDemo1
//
//  Created by fuhuayou on 2021/4/8.
//
import CoreBluetooth
import Foundation

class BLEOTAMgr: NSObject {
    
    typealias OTACallback = (Bool, Float, Error) -> Void
    var bleCenter: BLECenter?
    var filePath: String?
    var otaCallback: OTACallback?
    var inputStream: InputStream? // 数据流
    var perMaxLength: Int = 180 // 每次读取长度
    var fileSize: Int64? // 文件大小
    var sentSize: Int64 = Int64(0)  // 已经发送的长度
    
    init(_ ble: BLECenter?, _ file: String?) {
        bleCenter = ble
        filePath = file
    }
    
    func resumeOtaCallback(_ callback: OTACallback?) {
        otaCallback = callback
        
    }
    
    func stopOtaCallback(_ callback: OTACallback?) {
        otaCallback = callback
        
    }
}


// send data stream.
extension BLEOTAMgr: StreamDelegate {
    
    func resumeStream() {
        
        // if path nil or file nil, then return.
        if self.filePath == nil || !(FileManager.default.fileExists(atPath: self.filePath!)) {
            completion(success: false, message: "File path nil or file nil.", error: nil)
            return;
        }
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: self.filePath!)
            if let fileSize = fileAttributes[FileAttributeKey.size] {
                self.fileSize = (fileSize as! NSNumber).int64Value
            }
        } catch {
            print(error)
        }
        if self.fileSize == 0 {
            completion(success: false, message: "File could not get size.", error: nil)
            return;
        }
        
        // init inputStream
        if self.inputStream == nil {
            let backgroundQueue = DispatchQueue.global(qos: .background)
            backgroundQueue.async {
                self.inputStream = InputStream.init(fileAtPath: self.filePath!)
                self.inputStream?.delegate = self
                self.inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
                self.inputStream?.open()
//                self.inputStream?.close()
//                self.inputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
//                self.inputStream = nil
                RunLoop.current.run()
            }
        }
    }
    
    
    // deleagate methods.
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        let inputStream: InputStream = aStream as! InputStream
        switch eventCode {
        case Stream.Event.openCompleted:
            print("=====Stream.Event.openCompleted=====")
        case Stream.Event.hasBytesAvailable:
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: perMaxLength)
            let readBufferIsAvailable = inputStream.read(buffer, maxLength: perMaxLength)
            if readBufferIsAvailable > 0 {
                let temData = Data(bytes: buffer, count: readBufferIsAvailable)
                sentSize += Int64(readBufferIsAvailable)
                print("======== temData =========", temData)
                print("======== sentSize =========", sentSize)
                // send data.
                
                // caculate progress.
            }
        case Stream.Event.hasSpaceAvailable:
            break
        case Stream.Event.errorOccurred:
            print("=====Stream.Event.errorOccurred=====")
        case Stream.Event.endEncountered:
            print("=====Stream.Event.endEncountered=====")
        default:
            break
        }
        
    }
    
    
    
    func completion(success: Bool, message: String?, error: NSError?) {
        
    }
    
}
