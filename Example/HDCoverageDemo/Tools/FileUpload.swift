//
//  FileUpload.swift
//  HDCoverageDemo
//
//  Created by user on 2022/9/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CFNetwork

public class FTPUpload {
    fileprivate let baseFtpUrl: String
    fileprivate let directoryPath: String
    fileprivate let username: String
    fileprivate let password: String
    
    public init(baseUrl: String, userName: String, password: String, directoryPath: String) {
        self.baseFtpUrl = baseUrl
        self.username = userName
        self.password = password
        self.directoryPath = directoryPath
    }
}

extension FTPUpload {
    private func setFtpUserName(for ftpWriteStream: CFWriteStream, userName: CFString) {
        let propertyKey = CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPUserName)
        CFWriteStreamSetProperty(ftpWriteStream, propertyKey, userName)
    }
    
    private func setFtpPassword(for ftpWriteStream: CFWriteStream, pasword: CFString) {
        let propertyKey = CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPPassword)
        CFWriteStreamSetProperty(ftpWriteStream, propertyKey, pasword)
    }
    
    fileprivate func ftpWriteStream(forFileName fileName: String) -> CFWriteStream? {
        var char = CharacterSet()
        char.insert("/")
        let fullyQualifiedPath = "ftp://\(baseFtpUrl)/\(directoryPath.trimmingCharacters(in: char))/\(fileName)"
        print("upload to: \(fullyQualifiedPath)")
        guard let ftpUrl = CFURLCreateWithString(kCFAllocatorDefault, fullyQualifiedPath as CFString, nil) else { return nil }
        let ftpStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, ftpUrl)
        let ftpWriteStream = ftpStream.takeRetainedValue()
        setFtpUserName(for: ftpWriteStream, userName: username as CFString)
        setFtpPassword(for: ftpWriteStream, pasword: password as CFString)
        return ftpWriteStream
    }
}

extension FTPUpload {
    public func send(data: Data, with fileName: String, success: @escaping ((Bool)->Void)) {
        guard let ftpWriteStream = ftpWriteStream(forFileName: fileName) else {
            success(false)
            return
        }
        if CFWriteStreamOpen(ftpWriteStream) == false {
            print("Could not open stream:  \(fileName)")
            success(false)
            return
        }
        
        let fileSize = data.count
        print(">>>>\(fileName)>>>>>\(fileSize)")
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: fileSize)
        data.copyBytes(to: buffer, count: fileSize)
        defer {
            CFWriteStreamClose(ftpWriteStream)
            buffer.deallocate()
        }
        
        var offset: Int = 0
        var dataToSendSize = fileSize
        var shouldContinue = true
        repeat {
            if (CFWriteStreamCanAcceptBytes(ftpWriteStream)) {
                let bytesWriten = CFWriteStreamWrite(ftpWriteStream, &buffer[offset], dataToSendSize)
                if bytesWriten > 0 {
                    offset += bytesWriten.littleEndian
                    dataToSendSize -= bytesWriten
                    continue
                } else if bytesWriten < 0 {
                    print("FTPupload -ERROR??")
                    shouldContinue = false
                    break
                } else if bytesWriten  == 0 {
                    print("FTPupload -Completed!!")
                    shouldContinue = false
                    break
                }
            } else {
                usleep(200000)
                print(".", separator: "", terminator: "")
            }
        } while shouldContinue
        
        success(true)
    }
}
