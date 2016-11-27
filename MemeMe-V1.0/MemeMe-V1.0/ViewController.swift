//
//  ViewController.swift
//  MemeMe-V1.0
//
//  Created by Rakesh Kumar on 27/11/16.
//  Copyright © 2016 Rakesh Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {

    // Meme image and text
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topTextField: UITextField!
    
    // Top Bar
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    // Bottom Bar
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    var selectedTextField: UITextField!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isEnabled = false
        cameraAvailabilityCheck()
        let textFieldsArray = [topTextField,bottomTextField]
        textFieldsConfiguration(textFields: textFieldsArray)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyBoardNotificatin()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyBoardNotification()
    }

    

    // MARK: -TextFields Configuration
    func textFieldsConfiguration(textFields: [UITextField?])
    {
        let memeTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSStrokeColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium", size: 40)!,
            NSStrokeWidthAttributeName : -4.0
        ] as [String : Any]
        
        for textField in textFields
        {
            textField?.defaultTextAttributes = memeTextAttributes
            textField?.textAlignment = .center
            textField?.delegate = self
        }
    }

    // MARK: - KeyBoard Resigning and Notification
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
    }
    
    func keyBoardWillShow(_ notification:Notification){
        
        if bottomTextField.isFirstResponder{
            view.frame.origin.y -= getKeyBoardHeight(notification)
        }
    }
    
    func getKeyBoardHeight(_ notification:Notification) -> CGFloat{
        
        let userInfo = notification.userInfo
        let keyBoardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyBoardSize.cgRectValue.height
    }
    
    func keyBoardWillHide(_ notification:Notification){
        if bottomTextField.isFirstResponder{
             view.frame.origin.y = 0
        }
    }
    
    func subscribeToKeyBoardNotificatin(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyBoardNotification(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Image Picking and delegation
    
    @IBAction func pickAnImageFromCamera(_ sender: AnyObject) {
        presentImagePickerType(source: UIImagePickerControllerSourceType.camera)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: AnyObject) {
        presentImagePickerType(source: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    func presentImagePickerType(source sourceType : UIImagePickerControllerSourceType){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.imagePickerView.image = image
            shareButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // Check for camera avaialbility in device
    func cameraAvailabilityCheck()
    {
        if (UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            cameraButton.isEnabled = true
        }
        else
        {
            cameraButton.isEnabled = false
        }
        
    }
    
    // MARK: - cancel Button Pressed
    @IBAction func cancelButtonPressed(sender: AnyObject)
    {
        topTextField.text = nil                     // Clear Top TextField
        bottomTextField.text = nil                  // Clear Bottom TextField
        imagePickerView.image = nil                     // Clear ImageViewer
        shareButton.isEnabled = false                 // Disabled share button
        if(selectedTextField != nil)
        {
            selectedTextField.resignFirstResponder()   // Keyboard should resign
        }
    }

    // MARK: - Share button pressed
    
    @IBAction func shareMeme(_ sender: AnyObject) {
        
        let memedImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
       present(activityViewController, animated: true, completion: {self.save(memedImage)})
        
    }
    
    func save(_ memedImage:UIImage){
        let meme = MemeModel(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        print(meme)
    
    }
    
    func toolBarVisible(_ visible:Bool){
        topBar.isHidden = !visible
        bottomBar.isHidden = !visible
    }
    
    func generateMemedImage() -> UIImage {
        
        // hide toolbar
        toolBarVisible(false)
        
        // Render view to image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // show toolbar
        toolBarVisible(true)
        
        return memedImage
    }
}

