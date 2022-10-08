//
//  Tools.swift
//  HDCoverageDemo
//
//  Created by denglibing on 2021/10/27.
//

import Foundation

class HDCoverageTools: NSObject {
    static var shared = HDCoverageTools()
    var fileName = ""
    var _filePath = ""
    func registerCoverage(moduleName: String) {
        let name = "\(moduleName).profraw"
        print("registerCoverage, moduleName: \(moduleName)")
        fileName = name
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let filePath: NSString = documentDirectory.appendingPathComponent(name).path as NSString
            _filePath = filePath as String
            print("HDCoverageGather filePath: \(filePath)")
            __llvm_profile_set_filename(filePath.utf8String)
        } catch {
            print(error)
        }
//        saveAndUpload()
    }
    
    // 合适的时机代码覆盖率上报
    func saveAndUpload() {
        __llvm_profile_write_file()
//        debugPrint("HDCoverageTools.shared.saveAndUpload: " + fileName)
        let ftp = FTPUpload(baseUrl: "10.32.20.51:8111", userName: "123", password: "123", directoryPath:  "CoverageResult/")
        do {
            let data = try NSData(contentsOfFile: _filePath, options: .alwaysMapped)
            print("保存文件路径： \(_filePath)");print("文件大小：\(data.count)***")
            ftp.send(data: Data(referencing: data), with: fileName) { (success) in
                print("success?\(success)")
            }
            print(data.count)
        }catch {
            print(error)
        }
    }
}
