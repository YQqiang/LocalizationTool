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
    
    var removedExistKeyFilePath: String {
        return filePath(fileName: "removedExistKey.txt")
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
    @IBOutlet weak var stringsFileTextField: NSTextField!
    
    /// MARK - 补充需要扫描的文件后缀名
    @IBOutlet weak var addFileExtensionNameButton: NSButton!
    @IBOutlet weak var addFileExtensionNameView: NSView!
    @IBOutlet weak var addFileExtensionNameTextField: NSTextField!
    
    @IBOutlet weak var removeAllFileExistKeyButton: NSButton!
    @IBOutlet weak var removeOneFileExistKeyButton: NSButton!
    @IBOutlet weak var oneFileStringsView: NSView!
    @IBOutlet weak var showMessageLabel: NSTextField!
    @IBOutlet weak var customRegularTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /// 默认选中 剔除所有strings文件中重复key
        removeAllFileExistKeyButton.state = .on
        removeAllFileExistKey(removeAllFileExistKeyButton)
        showMessage(message: "请先选择导入路径和导出路径, 然后点击确认导出")
        
        /// 默认不补充文件扩展名
        addFileExtensionNameButton.state = .off
        addFileExtensionNameButtonAction(addFileExtensionNameButton)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func removeAllFileExistKey(_ sender: NSButton) {
        if sender.state == .on {
            removeOneFileExistKeyButton.state = .off
            removeOneFileExistKey(removeOneFileExistKeyButton)
        }
    }
    
    @IBAction func removeOneFileExistKey(_ sender: NSButton) {
        if sender.state == .on {
            removeAllFileExistKeyButton.state = .off
        }
        oneFileStringsView.isHidden = !(sender.state == .on)
    }
    @IBAction func addFileExtensionNameButtonAction(_ sender: NSButton) {
        addFileExtensionNameView.isHidden = !(sender.state == .on)
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
    
    @IBAction func stringsFileButtonAction(_ sender: NSButton) {
        stringsFileTextField.placeholderString = openPanel(canChooseFile: true)
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
        
        if removeOneFileExistKeyButton.state == .on {
            if stringsFileTextField.placeholderString == nil || stringsFileTextField.placeholderString?.count == 0 {
                showMessage(message: "请选择strings文件路径")
                return
            }
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
        DispatchQueue.main.sync {
            if self.removeOneFileExistKeyButton.state == .on {
                localizableFiles.append(stringsFileTextField.placeholderString!)
            }
        }
        var fileName: String? = (directoryEnumerator?.nextObject() as! String?)
        var fileExtensions: [String] = ["h", "m", "swift"]
        if Thread.current.isMainThread {
            if let addFileExtensions = addFileExtensionNameTextField.placeholderString?.replacingOccurrences(of: " ", with: "").components(separatedBy: ",") {
                addFileExtensions.forEach({ (addFileExtension) in
                    if !fileExtensions.contains(addFileExtension) {
                        fileExtensions.append(addFileExtension)
                    }
                })
            }
        } else {
            DispatchQueue.main.sync {
                let addFileExtensions = addFileExtensionNameTextField.stringValue.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
                addFileExtensions.forEach({ (addFileExtension) in
                    if !fileExtensions.contains(addFileExtension) {
                        fileExtensions.append(addFileExtension)
                    }
                })
            }
        }
        
        while (fileName != nil) {
            if let fileExtension = (fileName as NSString?)?.pathExtension {
                if fileExtensions.contains(fileExtension) {
                    files.append(fileName!)
                }
                DispatchQueue.main.sync {
                    if removeAllFileExistKeyButton.state == .on && fileExtension == "strings" {
                        localizableFiles.append(fileName!)
                    }
                }
            }
            fileName = (directoryEnumerator?.nextObject() as! String?)
        }
        print("--------\(files.count) ------- \(localizableFiles.count)")
        showMessage(message: "共\(files.count)个文件需要查询")
        
        /// 存储所有的key
        var keyCount = 0
        var keys = ""
        
        /// 存储剔除已有key后的key
        var removeExistKeys = ""
        
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
            
            /// 自定义匹配规则
            var customRegular = ""
            DispatchQueue.main.sync {
                customRegular = customRegularTextField.stringValue
            }
            if customRegular.count > 0  {
                regular = try? NSRegularExpression(pattern: customRegular, options: .caseInsensitive)
                if regular == nil {
                    showMessage(message: "匹配规则错误, 请修正")
                    return
                }
            }
            
            let matches = regular?.matches(in: fileContent, options: .reportProgress, range: NSRange.init(location: 0, length: fileContent.count))
            guard let checkResults = matches else {
                continue
            }
            
            /// 所有key的文件是否加了文件名称
            var keysAddedFileName = false
            /// 剔除key的文件是否加了文件名称
            var removeExistKeysAddedFileName = false
            for checkResult in checkResults {
                let key = (fileContent as NSString).substring(with: checkResult.range)
                var canAddKey = true
                for localizableFile in localizableFiles {
                    var localizableFileStr = try? String.init(contentsOfFile: homePath + "/" + localizableFile, encoding: String.Encoding.utf8)
                    DispatchQueue.main.sync {
                        if removeOneFileExistKeyButton.state == .on {
                            localizableFileStr = try? String.init(contentsOfFile: localizableFile, encoding: String.Encoding.utf8)
                        }
                    }
                    if let localizableFileContent = localizableFileStr {
                        let localizableRegular = try? NSRegularExpression(pattern: "\"+[^\"]+[^\"\\n]*?\" =", options: .caseInsensitive)
                        let localizableMatches = localizableRegular?.matches(in: localizableFileContent, options: .reportProgress, range: NSRange.init(location: 0, length: localizableFileContent.count))
                        if let localizableCheckResults = localizableMatches {
                            for localizableCheckResult in localizableCheckResults {
                                let localizableKey = (localizableFileContent as NSString).substring(with: localizableCheckResult.range).replacingOccurrences(of: " =", with: "")
                                if "\"" + key + "\"" == localizableKey {
                                    canAddKey = false
                                    break
                                }
                            }
                        }
                    }
                }
                
                if canAddKey {
                    if !removeExistKeysAddedFileName {
                        removeExistKeysAddedFileName = true
                        removeExistKeys = removeExistKeys + "\n" + "/*" + "\n" + "\(file.components(separatedBy: "/").last ?? "")" + "\n" + "*/" + "\n"
                    }
                    removeExistKeys = removeExistKeys + "\"" +  key + "\" = \"\";" + "\n"
                }
                if !keysAddedFileName {
                    keysAddedFileName = true
                    keys = keys + "\n" + "/*" + "\n" + "\(file.components(separatedBy: "/").last ?? "")" + "\n" + "*/" + "\n"
                }
                keys = keys + "\"" +  key + "\" = \"\";" + "\n"
                keyCount += 1
            }
            showMessage(message: "查询中.....\(index)/\(files.count)")
        }
        try? keys.write(toFile: allKeyFilePath, atomically: true, encoding: String.Encoding.utf8)
        DispatchQueue.main.sync {
            if removeAllFileExistKeyButton.state == .on || removeOneFileExistKeyButton.state == .on {
                try? removeExistKeys.write(toFile: removedExistKeyFilePath, atomically: true, encoding: String.Encoding.utf8)
            }
        }
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
        if Thread.current.isMainThread {
            exportPath = self.exportTextField.placeholderString!
        } else {
            DispatchQueue.main.sync {
                exportPath = self.exportTextField.placeholderString!
            }
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

