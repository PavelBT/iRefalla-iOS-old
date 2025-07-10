//
//  extension.swift
//  iReFalla
//
//  Created by Pavel on 30/06/16.
//  Copyright © 2016 Pavel. All rights reserved.
//

import Foundation
import UIKit
import MRProgress

// MARK: Vars

let dateFormatterTemplate = "MMM dd, yyyy HH:mm"
let timeStampFormatterTemplate = "MMM dd, yyyy HH:mm:ss +SSS"


private enum fechaFormatter{
    case get_falla
}

let imageDir = NSHomeDirectory()

// MARK: Dispatch Vars

var GlobalMainQueue: DispatchQueue {
    return DispatchQueue.main
}
var GlobalUserInteractiveQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInteractive)
}
var GlobalUserInitiatedQueue: DispatchQueue {
    return DispatchQueue.global(qos: .userInitiated)
}
var GlobalUtilityQueue: DispatchQueue {
    return DispatchQueue.global(qos: .utility)
}
var GlobalBackgroundQueue: DispatchQueue {
    return DispatchQueue.global(qos: .background)
}

// MARK: UIVIEW
// Constrains

extension UIView{
    func addConstraintsWithFormat(format:String, views: UIView...){
        
        var viewsDictionary = [String:UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}


// MARK: UIApplication

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}


// MARK: VIEWCONTROLLER EXTENSION

extension UIViewController {
    
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController, let controller = navigation.visibleViewController {
            return controller.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
        
    // Keyword Function
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    enum indicatorMode {
        case overlay, navigation
    }
    
    // ACTIVITY INDICATOR
    func loadActivityIndicator(title: String) {
        MRProgressOverlayView.showOverlayAdded(to: self.navigationController?.view, title: title, mode: .indeterminateSmall, animated: true)
    }
    
    func dismissActivityIndicator() {
        MRProgressOverlayView.dismissOverlay(for: self.navigationController?.view, animated: true)
    }
}

// MARK: File Manager

extension FileManager {
    
    // Temp folder function
    
    func saveTempFolder(DataString: String, dirPath dir: String, fileName: String) -> NSURL? {
        let dirPath = NSTemporaryDirectory() + dir
        let filepath = dirPath + "/" + fileName
        
        let file = Data(base64Encoded: DataString, options: NSData.Base64DecodingOptions(rawValue: 0))
        do{
            try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        }catch{
            print("Error creating a new folder")
        }
        let sucess = FileManager.default.createFile(atPath: filepath, contents: file, attributes: nil)
        if sucess {
            return NSURL(fileURLWithPath: filepath)
        } else {
            return nil
        }
    }
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            print(filePaths)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: NSTemporaryDirectory() + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
}

// MARK: TABLEVIEWCONTROLLER EXTENSION

extension UITableViewController {
    
    func searchBarLoad(searchController: UISearchController, placeholder: String, ScopeTitles: [String]? = nil, hide:Bool = true) {
       
        searchController.searchBar.placeholder = placeholder
        searchController.searchBar.searchBarStyle =  .default
        searchController.searchBar.scopeButtonTitles = ScopeTitles
        searchController.extendedLayoutIncludesOpaqueBars = false
        searchController.obscuresBackgroundDuringPresentation = false
        
//        // CONFIGURAR COLORES A BLANCO
//        if navigationController?.navigationBar.barStyle != UIBarStyle.default {
//            searchController.searchBar.tintColor = UIColor.white
//            if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
//                if let backgroundview = textfield.subviews.first {
//                    // Background color
//                    backgroundview.backgroundColor = UIColor.gray
//                    // Rounded corner
//                    backgroundview.layer.cornerRadius = 10;
//                    backgroundview.clipsToBounds = true;
//                }
//            }
//        }

        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = hide
        } else {
            tableView.tableHeaderView = searchController.searchBar
            print("searcbar en table view")
        }

        //OCULTAR LA BARRA DE BUSQUEDA
        if hide {
            var newBounds : CGRect? = self.tableView.bounds
            newBounds?.origin.y = 0
            newBounds?.origin.y += searchController.searchBar.bounds.height
            self.tableView.bounds = newBounds!

        }
    }
}

// MARK: VAR TYPES

// Dictionary

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

// Date

extension Date {

    var toStringFormatter: String? {
        get {
            return stringFormatter(type: .datetime)
        }
    }
    
    var toStringTimeStampFormatter: String? {
        get {
            return stringFormatter(type: .timestamp)
        }
    }
    
    fileprivate enum dateType {
        case datetime, timestamp
    }
    
    fileprivate func stringFormatter(type: dateType) -> String? {
        let calendar = NSCalendar.current
        let dateFormatter = DateFormatter()
        let date = type == .datetime ? dateFormatterTemplate : timeStampFormatterTemplate
        let time = type == .datetime ? "HH:mm" : "HH:mm:ss +SSS"
        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = time
            return "hoy " + dateFormatter.string(from: self) + " hrs"
        } else if calendar.isDateInYesterday(self) {
            dateFormatter.dateFormat = time
            return "ayer " + dateFormatter.string(from: self) + " hrs"
        } else {
            dateFormatter.dateFormat = date
            return dateFormatter.string(from: self)
        }
    }
    
    init?(fromString string: String, formatter: String? = "yyyy/MM/dd HH:mm", utc: Bool = false) {
        guard !string.isEmpty else {return nil}
        let dateFormatt = DateFormatter()
        if utc {
            dateFormatt.timeZone = TimeZone(abbreviation: "UTC")
        }
        dateFormatt.locale = NSLocale.system
        dateFormatt.dateFormat = formatter
        guard let date = dateFormatt.date(from: string) else {return nil}
        self.init(timeInterval: 0, since: date)
    }
}


// MARK: UIKIT

// UITextField

extension UIViewController: UITextFieldDelegate {
    func addToolBar(_ textView: UITextField, doneAction: Selector, cancelAction: Selector?){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
        let doneButton = UIBarButtonItem(title: "Aceptar", style: UIBarButtonItem.Style.done, target: self, action: doneAction)
        let cancelButton = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItem.Style.done , target: self, action:cancelAction)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textView.delegate = self
        textView.inputAccessoryView = toolBar
    }
}


// UI Datepicked


extension UITextField {
    func setInputViewDatePicker(target: Any, selector: Selector, type: UIDatePicker.Mode) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = type //2
        self.inputView = datePicker //3
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
        
        toolBar.setItems([cancel, flexible, barButton], animated: false) //8
        self.inputAccessoryView = toolBar //9
    }
    
    @objc private func tapCancel() {
           self.resignFirstResponder()
    }
}
// UIColor

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1.0 ) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    convenience init(hex: UInt, alpha: CGFloat) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    // Parse a KML string based color into a UIColor.  KML colors are agbr hex encoded.
    convenience init(KMLString kmlColorString: String) {
        let scanner = Scanner(string: kmlColorString)
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let a = (color >> 24) & 0x000000FF
        let b = (color >> 16) & 0x000000FF
        let g = (color >> 8) & 0x000000FF
        let r = color & 0x000000FF
        
        let rf = CGFloat(r) / 255.0
        let gf = CGFloat(g) / 255.0
        let bf = CGFloat(b) / 255.0
        var af: CGFloat {
            if CGFloat(a) / 255.0 == 0 {
                return 1.0
            } else {return CGFloat(a) / 255.0}
        }
        self.init(red: rf, green: gf, blue: bf, alpha: af)
    }
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}


// String

extension String {
    func extractLeft(offset: Int) -> String? {
        if self.count > 0 {
            let index = self.index(self.startIndex, offsetBy: offset)
            return self.substring(to: index)
        } else {return nil}
    }
    
    func extractRigth(offset: Int) -> String? {
        if self.count > 0 {
            let index = self.index(self.startIndex, offsetBy: offset-1)
            return self.substring(from: index)
        } else {return nil}
    }
    
    func extractFromTo(from: Int, to: Int) -> String? {
        if self.count > 0 {
            let start = self.index(self.startIndex, offsetBy: from-1)
            let endOffsset = to - self.characters.count
            let end = self.index(self.endIndex, offsetBy: endOffsset)
            let range = start..<end
            return self.substring(with: range)  // play
        } else {return nil}
    }
    
    func estimateSize(width: Int, fontSize: Int) -> CGSize {
        let size = CGSize(width: width, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        return CGSize(width: estimatedFrame.width, height: estimatedFrame.height)
    }
}


