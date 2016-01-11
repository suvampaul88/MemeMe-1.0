//
//  MemeMeEditorController.swift
//  MemeMe 1.0
//
//  Created by Suvam Paul on 1/2/16.
//  Copyright © 2016 Suvam Paul. All rights reserved.
//

import UIKit

class MemeMeEditorController:  UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    @IBOutlet weak var shareMeme: UIBarButtonItem!
    @IBOutlet weak var cancelMeme: UIBarButtonItem!
    
    
    
    @IBOutlet weak var textfieldTop: UITextField!
    @IBOutlet weak var textfieldButtom: UITextField!
    
    
    //define attributes of texts in textfields
    let memeTextArrributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 38)!,
        NSStrokeWidthAttributeName : NSNumber(float: -3.0)
    ]
    
    func formatmemeText(text: String, textfield: UITextField) {
        textfield.text = text
        textfield.defaultTextAttributes = memeTextArrributes
        textfield.textAlignment = NSTextAlignment.Center
        textfield.delegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // view color 
        view.backgroundColor = UIColor.grayColor()
        
        //shareMeme button disabled 
        shareMeme.enabled = false
        
        //textfield attributes
        formatmemeText("TOP", textfield: textfieldTop)
        formatmemeText("BUTTOM", textfield: textfieldButtom)
        
    }
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //subscribe to notification
        subscribeToKeyboardNotification()
        
        //enable access to camera if available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //unsunscribe from notification
        unsubscribeFromKeyboardNotification()
    
    }
    

    func imagepickerSource(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func pickfromAlbum(sender: AnyObject) {
        imagepickerSource(.PhotoLibrary)
    }
    
    
    @IBAction func pickfromCamera(sender: AnyObject) {
        imagepickerSource(.Camera)
    }
    
    
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {
            (activityItem: String?, completed: Bool, item: [AnyObject]?, error:NSError?) -> Void in
            if (!completed) {
                print("cancelled")
                return
            }
                
            else {
                self.save()
                print("Shared meme activity: \(activityItem)")
                
            }
        }
        presentViewController(activityVC, animated: true, completion: nil)
    }


    @IBAction func cancelMeme(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //choose image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = UIViewContentMode.ScaleToFill
            dismissViewControllerAnimated(true, completion: nil)
            
            shareMeme.enabled = true
            
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //functions for textfield
    
    //keyboard disappears when return button is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    //dismiss keyboard
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    
    //keyboard adjustments
    
    //show keyboard
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userinfo = notification.userInfo
        let keyboardSize = userinfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if textfieldButtom.isFirstResponder(){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //hide keyboard
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }
    
    
    //notifications for keyboard
    
    func subscribeToKeyboardNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
    }

    
    func save() {
        let memedImage = generateMemedImage()
        _ = Meme(topText: textfieldTop.text!, bottomText: textfieldButtom.text!, originalImage: imageView.image!, memeImage: memedImage)
    }
    
    
    func generateMemedImage() -> UIImage {
        
        toolBar.hidden = true
        navigationBar.hidden = true
        
        //render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolBar.hidden = false
        navigationBar.hidden = false
        
        
        return memedImage
        
    }


}