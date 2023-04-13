//
//  AddAlertViewController.swift
//  Drink
//
//  Created by 조동진 on 2022/02/10.
//

import UIKit

class AddAlertViewController: UIViewController {
  var pickedDate: ((_ date: Date) -> Void)? // closure
  
  @IBOutlet weak var datePicker: UIDatePicker!
  
  
  
  @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
    // DatePicker의 시간을 부모 뷰 (AlertListViewController에 전달)
    pickedDate?(datePicker.date)
    self.dismiss(animated: true, completion: nil)
  }
}
