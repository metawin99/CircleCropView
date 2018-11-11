//
//  ViewController.swift
//  CircleCropView
//
//  Created by Bhavesh Chaudhari on 11/11/18.
//  Copyright © 2018 Bhavesh Chaudhari. All rights reserved.
//
import Foundation
import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    let picker = UIImagePickerController()
    @IBOutlet var imgView : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
      
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imgView.layer.cornerRadius = imgView.bounds.width/2
        imgView.clipsToBounds = true
    }

    
    
    @IBAction func selectImageClick(sender:UIButton) {
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let cropController = CropViewController(image:chosenImage) { [weak self] selectedImage in
                self?.imgView.image = selectedImage
            }
            picker.dismiss(animated: true, completion: nil)
            self.present(cropController, animated: true, completion: nil)
        }
    }

}

