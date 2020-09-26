//
//  ViewController.swift
//  FileManager
//
//  Created by Konstantins Belcickis on 24/09/2020.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var name: String?
    var path: String?
    
    private let fileManager = FileManagerService()
    private let reuseIdentifier = "TableCell"
    private var elements: [(Types, String)]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = name,
           let path = path {
            elements = fileManager.listFiles(in: path)
            self.title = name
        } else {
            elements = fileManager.listFiles()
        }
        
        self.tableView.frame = self.view.frame
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        let createDirectoryButton = UIBarButtonItem(image: UIImage(named: "addDirectory"), style: .plain, target: self, action: #selector(barItemDirectoryPressed(_:)))
        let createFileButton = UIBarButtonItem(image: UIImage(named: "addFile"), style: .plain, target: self, action: #selector(barItemFilePressed(_:)))
        self.navigationItem.rightBarButtonItems = [createFileButton, createDirectoryButton]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let elements = elements else {
            return 0
        }
        
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
        
        let (type, name) = elements![indexPath.item]
        cell.textLabel?.text = name
        if type == .file {
            cell.imageView?.image = UIImage(named: "file")
        } else {
            cell.imageView?.image = UIImage(named: "directory")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let name = name,
               let path = path {
                fileManager.deleteFile(withName: path + elements![indexPath.item].1)
                tableView.deleteRows(at: [indexPath], with: .fade)
                elements = fileManager.listFiles(in: path)
                self.title = name
            } else {
                fileManager.deleteFile(withName: elements![indexPath.item].1)
                elements = fileManager.listFiles()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (type, nameElem) = elements![indexPath.item]
        
        if type == .directory {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "mainVC") as! ViewController
            
            vc.name = nameElem
            if let path = path {
                vc.path = "\(path)/\(nameElem)/"
            } else {
                vc.path = "/\(nameElem)/"
            }
            
            self.show(vc, sender: self)
        } else if type == .file {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "textView") as! FileViewController
            if path == nil {
                path = ""
            }
            vc.name = nameElem
            vc.text = fileManager.readFile(at: path!, withName: nameElem)
            self.show(vc, sender: self)
        }
    }
    
    @objc func barItemFilePressed(_ sender: Any?) {
        let alert = UIAlertController(title: "File name", message: "", preferredStyle: .alert)
        
        alert.addTextField()
        let createAction = UIAlertAction(title: "Create", style: UIAlertAction.Style.default) {
            UIAlertAction in
            guard let name = alert.textFields?.first?.text else {
                print("text field was an empty")
                return
            }
            if let path = self.path {
                self.fileManager.createFile(withName: path + name)
                self.elements = self.fileManager.listFiles(in: path)
            } else {
                self.fileManager.createFile(withName: name)
                self.elements = self.fileManager.listFiles()
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func barItemDirectoryPressed(_ sender: Any?) {
        let alert = UIAlertController(title: "Directory name", message: "", preferredStyle: .alert)
        
        alert.addTextField()
        let createAction = UIAlertAction(title: "Create", style: UIAlertAction.Style.default) {
            UIAlertAction in
            guard let name = alert.textFields?.first?.text else {
                print("text field was an empty")
                return
            }
            if let path = self.path {
                self.fileManager.createDirectory(atPath: path + name)
                self.elements = self.fileManager.listFiles(in: path)
            } else {
                self.fileManager.createDirectory(atPath: name)
                self.elements = self.fileManager.listFiles()
            }
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

