//
//  ViewController.swift
//  LocalizationTool
//
//  Created by sungrow on 2017/12/13.
//  Copyright © 2017年 sungrow. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var allKeyFilePath: String {
        return filePath(fileName: "allKeys.txt")
    }
    
    var i18nKeyFilePath: String {
        return filePath(fileName: "i18nKeys.txt")
    }
    
    @IBOutlet weak var importButton: NSButton!
    @IBOutlet weak var importTextField: NSTextField!
    @IBOutlet weak var exportButton: NSButton!
    @IBOutlet weak var exportTextField: NSTextField!
    @IBOutlet weak var sourceFileButton: NSButton!
    @IBOutlet weak var sourceFileTextField: NSTextField!
    
    @IBOutlet weak var showMessageLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showMessage(message: "请先选择导入路径和导出路径, 然后点击确认导出")
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func importButtonAction(_ sender: NSButton) {
        importTextField.placeholderString = openPanel(canChooseFile: false)
    }

    @IBAction func exportButtonAction(_ sender: NSButton) {
        var path = openPanel(canChooseFile: false)
        if path.count > 0 {
             path = path.appending("/Localization")
        }
        exportTextField.placeholderString = path
    }
    
    @IBAction func sourceFileButtonAction(_ sender: NSButton) {
        sourceFileTextField.placeholderString = openPanel(canChooseFile: true)
    }
    
    fileprivate func openPanel(canChooseFile: Bool) -> String {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = !canChooseFile
        openPanel.canChooseFiles = canChooseFile
        if openPanel.runModal() == .OK {
            let path = openPanel.urls.first?.absoluteString.components(separatedBy: ":").last?.removingPercentEncoding as NSString?
            return path?.expandingTildeInPath ?? ""
        }
        return ""
    }
    
    /// 确认导出
    ///
    /// - Parameter sender: sender
    @IBAction func confirmToExport(_ sender: NSButton) {
        if importTextField.placeholderString == nil || importTextField.placeholderString?.count == 0 {
            showMessage(message: "请选择导入路径")
            return
        }
        
        if exportTextField.placeholderString == nil || exportTextField.placeholderString?.count == 0 {
            showMessage(message: "请选择导出路径")
            return
        }
        
        showMessage(message: "开始导出...")
        let path = importTextField.placeholderString!
        
        DispatchQueue.global().async {
            self.readFiles(path: path)
        }
    }
    
    /// 根据路径读取文件
    ///
    /// - Parameter path: 路径
    fileprivate func readFiles(path: String) {
        
        let fileManager = FileManager.default
        let homePath = (path as NSString).expandingTildeInPath
        let directoryEnumerator = fileManager.enumerator(atPath: homePath)
        
        /// 统计文件个数
        var files = [String]()
        var localizableFiles = [String]()
        var fileName: String? = (directoryEnumerator?.nextObject() as! String?)
        let fileExtensions: [String] = ["h", "m", "swift"]
        while (fileName != nil) {
            if let fileExtension = (fileName as NSString?)?.pathExtension {
                if fileExtensions.contains(fileExtension) {
                    files.append(fileName!)
                }
                
                if fileExtension == "strings" {
                    localizableFiles.append(fileName!)
                }
            }
            fileName = (directoryEnumerator?.nextObject() as! String?)
        }
        print("--------\(files.count) ------- \(localizableFiles.count)")
        showMessage(message: "共\(files.count)个文件需要查询")
        
        ///
        var keyCount = 0
        var keys = ""
        for (index, file) in files.enumerated() {
            let fileStr = try? String.init(contentsOfFile: homePath + "/" + file, encoding: String.Encoding.utf8)
            guard let fileContent = fileStr else {
                continue
            }
            let isSwift = file.hasSuffix(".swift")
            var regular = try? NSRegularExpression(pattern: "(?<=NSLocalizedString\\(@\").*?(?=\",)", options: .caseInsensitive)
            if isSwift {
                regular = try? NSRegularExpression(pattern: "(?<=NSLocalizedString\\(\").*?(?=\",)", options: .caseInsensitive)
            }
            let matches = regular?.matches(in: fileContent, options: .reportProgress, range: NSRange.init(location: 0, length: fileContent.count))
            guard let checkResults = matches else {
                continue
            }
            if checkResults.count > 0 {
                keys = keys + "\n" + "/*" + "\n" + "\(file.components(separatedBy: "/").last ?? "")" + "\n" + "*/" + "\n"
            }
            for checkResult in checkResults {
                let key = (fileContent as NSString).substring(with: checkResult.range)
                keys = keys + "\"" +  key + "\" = \"\";" + "\n"
                keyCount += 1
            }
            showMessage(message: "查询中.....\(index)/\(files.count)")
        }
        try? keys.write(toFile: allKeyFilePath, atomically: true, encoding: String.Encoding.utf8)
        showMessage(message:"查询完成\n" + "共查询了--\(files.count)个file---\(keyCount)个key" + "\n" + "文件路径: \(filePath(fileName: ""))")
    }
    
    /// 显示提示信息
    ///
    /// - Parameter message: 提示信息
    fileprivate func showMessage(message: String) {
        DispatchQueue.main.async {
            self.showMessageLabel.stringValue = message
        }
    }
    
    /// 生成文件路径
    ///
    /// - Parameter fileName: 文件名
    /// - Returns: 文件路径
    fileprivate func filePath(fileName: String) -> String {
        var exportPath = ""
        DispatchQueue.main.sync {
            exportPath = self.exportTextField.placeholderString!
        }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: exportPath) {
            try? fileManager.createDirectory(atPath: exportPath, withIntermediateDirectories: true, attributes: nil)
        }
        let filePath = exportPath + "/" + fileName
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        return filePath
    }
}

