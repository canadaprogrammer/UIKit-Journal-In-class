//
//  AddJournalEntryViewController.swift
//  JRNL
//
//  Created by Jungman Bae on 5/10/24.
//

import UIKit

class AddJournalEntryViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var newJournalEntry: JournalEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        bodyTextView.delegate = self
        updateSaveButtonState()
    }
    
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let title = titleTextField.text ?? ""
        let body = bodyTextView.text ?? ""
        let photo = photoImageView.image
        let rating = 3
        newJournalEntry = JournalEntry(rating: rating, title: title,
                                       body: body, photo: photo)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateSaveButtonState()
        return true
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        print("text: \(range.description) \(text)")
        if(text == "\n") {
            textView.resignFirstResponder()
        }
        updateSaveButtonState()
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonState()
    }
    
    // MARK: - Methods
    private func updateSaveButtonState() {
        let textFieldText = titleTextField.text ?? ""
        let textViewText = bodyTextView.text ?? ""
        saveButton.isEnabled = !textFieldText.isEmpty && !textViewText.isEmpty
    }
}
