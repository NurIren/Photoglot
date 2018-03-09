//
//  LanguageViewController.swift
//  photoGlotTwo
//
//  Created by Nur Iren on 2/12/18.
//  Copyright © 2018 Nur Iren. All rights reserved.
//
//language select page
//Will send selected language to CameraViewController

import UIKit

class LanguageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
    @IBOutlet weak var pickerView: UIPickerView!
    var pickedLanguage = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        start = false;
       

        // Do any additional setup after loading the view.
    }
    var start = false;
    @IBAction func pressedStart(_ sender: Any) {
        start = true;
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destinationController : CameraViewController = segue.destination as! CameraViewController
            destinationController.translateLanguageWord = pickedLanguage;
       
    }
    let languages = ["Spanish", "French", "German", "Turkish"]
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return languages.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickedLanguage = languages[row];
        print(pickedLanguage)
        
        return languages[row]
        
    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        //translatedWord.text = languages[row]
    }
    

}
