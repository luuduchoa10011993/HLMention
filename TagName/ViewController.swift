//
//  ViewController.swift
//  TagName
//
//  Created by Mojave on 3/17/20.
//  Copyright © 2020 Mojave. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Tagging
import SZMentionsSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var mentionsTextField: HoaLDMentionsTextField!
    @IBOutlet weak var tbListUserTag: UITableView!
    
    let kUsers: [UserInfo] = [UserInfo("00", "Hoa"), UserInfo("01", "Vuong Khac Duy"), UserInfo("02", "Dương"),
                               UserInfo("03", "Nguyễn Đoàn Nguyên An"), UserInfo("04", "Nguyễn Kiều Vy"), UserInfo("05", "Nguyễn Duy Ngân"),
                               UserInfo("06", "Donald Trump"), UserInfo("07", "Hoà cute phô mai que")]
    var range: NSRange = _NSRange()
    var replacementString: String = ""
    var arrayNameDidChangeAttribute:[String] = []
    
    let disposeBag = DisposeBag()
    var stringNeedReplace = ""
    var textChange = ""
    var text  = ""
    
    //tableview data
    var kUsersTableView: [UserInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbListUserTag.tableFooterView = UIView()
        mentionsTextField.kUsers = kUsers
        
    }
    //attribute of String
    func attributeString(initialString: String , valueReplace: String) -> NSMutableAttributedString{
        let mutableAttributedString = NSMutableAttributedString(string: initialString)
        
        // check text has been replaced or not ?
        if checkStringChange(textSelected: valueReplace, textChange: textChange) == true{
            
            // get range of the text is Changed  in textField
            if ((initialString.contains(textChange))){
                guard let range = mutableAttributedString.string.range(of: textChange) else { exit(0) }
                let rangeOftextChange = NSRange(range,in: mutableAttributedString.string )
                print (rangeOftextChange)
                
                // Set new attributed string
                let newAttributes = [NSAttributedString.Key.backgroundColor: UIColor.yellow ]
                
                // Replace content in range with the new content
                mutableAttributedString.addAttributes(newAttributes, range: rangeOftextChange)
            }
        }
        return mutableAttributedString
    }
    
    // func check the string which is selected was change or not?
    func checkStringChange(textSelected: String, textChange: String ) -> Bool{
        if textSelected == textChange{
            return true
        }
        return  false
    }
    
    // replace the string by the name which is selected
    /**
     @ param
     @ textField             :  textField where input the value
     @ string                  :  string after @ which will be replaced by value selected
     @ nameReplace     : the value which is selected
     */
    //    func replaceString (textFieldString: String, range: (range: NSRange, foundString: String), stringNeedReplace: String, nameReplace: String) -> String? {
    ////        if let range = tfText.text!.range(of: string) {
    ////        guard let textInTextField = tfSearchName.text as? String else  {return nil}
    ////        textInTextField.range(of: stringNeedReplace)
    //        let substring = textFieldString[...range.range.lowerBound]
    //            print("Substring: \(substring)")
    //        self.stringNeedReplace = String(substring)
    //            textFieldString.replaceSubrange(range , with: nameReplace + " ")
    //            print(stringNeedReplace)
    //            return stringNeedReplace
    //        return nil
    //    }
    
    
    func replaceString (textInTextField: String, stringAfterSymbol: String, nameReplace: String) -> String? {
        //        if let range = tfText.text!.range(of: string) {
        //            guard let textInTextField = textInTextField else  {return nil}
        textInTextField.range(of: stringAfterSymbol)
        print("stringAfterSymbol: \(stringAfterSymbol)")
        if let range = textInTextField.range(of: stringAfterSymbol) {
            
            let substring = mentionsTextField.text![...range.lowerBound]
            print("Substring: \(substring)")
            stringNeedReplace = String(substring)
            mentionsTextField.text!.replaceSubrange(range , with: nameReplace + " ")
            print(stringNeedReplace)
            return stringNeedReplace
        }
        return nil
    }
    
    func valueChanges(range: NSRange, replacementString: String){
        handleSymbol(initialString: mentionsTextField.text!, range: self.range, replacementString: self.replacementString)
    }
    
    // @==---------------------------func check current input---------------------------------==@
    func checkCurrentInputIsSymbol(characterInput: String) -> Bool {
        if characterInput == "@"{
            return true
        }
        return false
    }
    
    // func check character before the symbol if character == "@" return true else return false
    func checkCharacterBeforeCurrentInput(locationOfCharacterBefore: Int, textInTextField: String, stringInput: String) -> Bool{
        let symbol: String = "@"
        let rangeOfCharacterBeforeSymbol = self.range.location - locationOfCharacterBefore
        let characterBeforeSymbol = textInTextField.index(textInTextField.startIndex, offsetBy: rangeOfCharacterBeforeSymbol)
        if String(textInTextField[characterBeforeSymbol]) == symbol{
            return true
        }
        return false
    }
    
    //check location of symbol is 0 or not?? if @ at 0
    func checkLocationAt(locationOfCharacterInputAt: Int) -> Bool{
        if self.range.location == locationOfCharacterInputAt {
            return true
        }
        return false
    }
    
    /*
     // func filter name in list
     func filter(data:[String] ,string: String) -> [String] {
     var arrayDetected: [String] = []
     for name in data{
     if name.contains(string){
     arrayDetected.append(name)
     }
     }
     self.arrayName = arrayDetected
     print ("Array  Name: \(self.arrayName.count)")
     print("Array  Name    : \(self.arrayName)")
     
     self.tbListUserTag.reloadData()
     
     return arrayDetected
     }
     */
    
    // func get string without symbol
    func getStringWithoutSymbol(textInput:String , indexOfLastCharacter: Int,_ symbol: Character) -> String? {
        if indexOfLastCharacter == 0, textInput == String(symbol) {
            return ""
        }
        for ranges in (0 ..< indexOfLastCharacter ).reversed(){
            
            let index = textInput.index(textInput.startIndex, offsetBy: ranges)
            
            let character = textInput[index]
            if character == symbol {
                let startIndex = textInput.index(textInput.startIndex, offsetBy: ranges + 1 )
                let endIndex = textInput.index(textInput.startIndex, offsetBy: indexOfLastCharacter )
                
                //case "" -> has @ not character
                if textInput == "" {
                    return ""
                } else  {
                    var rangesofString = textInput[startIndex ... endIndex]
                    //             print("rangeOfString : \(rangesofString)")
                    return String(textInput[startIndex ... endIndex] )
                }
            }
        }
        //case nil -> not @
        return nil
    }
    
    func handleSymbol (initialString: String, range: NSRange, replacementString string: String ){
        let currentChange = string
        /**
         @ if current Input == @ show tableView
         @ if current input != @ hidden tableView
         */
        if checkCurrentInputIsSymbol(characterInput: string) == true {
            tbListUserTag.isHidden = false
            /**
             @ if location of @ == 0 hidden tableView
             @ if location of @ != 0 show tableView
             */
            if checkLocationAt(locationOfCharacterInputAt: 0) == true {
                tbListUserTag.isHidden = false
            } else {
                /**
                 @ if the character before @ == @  -> hidden table View = true
                 @ if the character before @ != @ ->   hidden table View = false
                 */
                if checkCharacterBeforeCurrentInput(locationOfCharacterBefore: 1, textInTextField: mentionsTextField.text!, stringInput: string) == true {
                    tbListUserTag.isHidden = true
                } else {
                    self.kUsersTableView = self.kUsers
                    print("currentchange: \(currentChange)")
                    tbListUserTag.reloadData()
                    return
                }
            }
        }
        // if current input != @ if true ->
        let symbol: Character = "@"
        if currentChange != String(symbol), range.location >= 0{
            
            //            if let stringoutput = getStringWithoutSymbol(textInput: tfSearchName.text!, indexOfLastCharacter: range.location, symbol){
            if let stringAfterSymbol = getStringWithoutSymbol(textInput: mentionsTextField.text!, indexOfLastCharacter: range.location, symbol){
                print("stringAfterSymbol: \(stringAfterSymbol)")
                stringNeedReplace = stringAfterSymbol
                if stringAfterSymbol.count == 0 {
                    //                    print(arrayData)
                } else {
                    /*
                     filter(data: arrayData, string: stringAfterSymbol)
                     trả về mảng string
                     */
                }
            }
        }
    }
    
    
}

//  MARK: - UITableView Delegate - DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.isHidden = kUsersTableView.count == 0 ? true : false
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if kUsersTableView.count > 5 {
            return 5
        }
        return kUsersTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NameTableViewCell.self), for: indexPath) as! NameTableViewCell
        cell.display(kUsersTableView[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let UserInfo = kUsersTableView[indexPath.row]
        mentionsTextField.kStringRaw.insertString(insertString: UserInfo.getTagID(), textField: mentionsTextField, atCurrentCursorPosition: true)
        mentionsTextField.refreshDisplay()
        tbListUserTag.isHidden = true
    }
}

//  MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate{
    
    @IBAction func tfEditingChange(_ sender: UITextField) {
        // if text Field  != "" -> run value Change
        if sender.text != "" {
            //  valueChanges(range: self.range, replacementString: self.replacementString)
            handleSymbol(initialString: sender.text!, range: self.range, replacementString: self.replacementString)
            
            // if text field == "" -> remove all name in arrayName + table View Name (tbvName) hidden + reload data
        } else {
            kUsersTableView.removeAll()
            tbListUserTag.reloadData()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.range = range
        self.replacementString = string
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            let newRange = NSRange(location: range.location - 1, length: range.length)
            self.range = newRange
        }
        return true
    }
}
