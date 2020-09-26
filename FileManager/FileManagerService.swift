//
//  FileManagerService.swift
//  FileManager
//
//  Created by Konstantins Belcickis on 24/09/2020.
//

import Foundation

class FileManagerService {
    
    private let text = "Hello world!"
    
    func listFiles(in directory: String = "") -> [(Types, String)] {
        var docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if directory != "" {
            docsURL.appendPathComponent(directory)
        }
        let docs = try? FileManager.default.contentsOfDirectory(atPath: docsURL.path)
        
        var elements = [(Types, String)]()
        
        for doc in docs! {
            if !doc.contains(".DS_Store") {
                if let _ = try? FileManager.default.contentsOfDirectory(atPath: docsURL.path + "/\(doc)") {
                    elements.append((.directory, doc))
                } else {
                    elements.append((.file, doc))
                }
            }
        }
        
        elements.sort(by: {
            (firstElem, secondElem) in
            if (firstElem.0 == .file) && (secondElem.0 == .directory) {
                return false
            } else if (firstElem.1 > secondElem.1) && (firstElem.0 == secondElem.0) {
                return false
            }
            
            return true
        })
        
        return elements
    }
    
    func createDirectory(atPath: String = "") {
        if atPath == "" {
            return
        }
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newDir = docsURL.appendingPathComponent(atPath)
        print(newDir)
        try? FileManager.default.createDirectory(at: newDir, withIntermediateDirectories: false, attributes: nil)
    }
    
    func createFile(withName name: String, atPath: String = "") {
        var docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if atPath != "" {
            docsURL.appendPathComponent(atPath)
        }
        let filePath = docsURL.path + "/" + name
        print(filePath)
        let content = text.data(using: .utf8)
        FileManager.default.createFile(atPath: filePath, contents: content, attributes: nil)
    }
    
    func deleteFile(withName name: String, atPath: String = "") {
        var docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if atPath != "" {
            docsURL.appendPathComponent(atPath)
        }
        let filePath = docsURL.appendingPathComponent(name)
        
        try? FileManager.default.removeItem(at: filePath)
    }
    
    func readFile(at path: String, withName name: String) -> String {
        var filePath: String
        if path == "" {
            filePath = "/\(name)"
        } else {
            filePath = path + name
        }
        
        filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path + filePath
        
        guard let fileContent = FileManager.default.contents(atPath: filePath),
              let fileContentEncoded = String(bytes: fileContent, encoding: .utf8) else {
            return ""
        }
        
        return fileContentEncoded
    }
    
}
