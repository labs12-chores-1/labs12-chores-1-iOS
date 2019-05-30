//
//  UsersPopoverView.swift
//  Fairshare
//
//  Created by Ilgar Ilyasov on 5/24/19.
//  Copyright © 2019 Lambda School Labs. All rights reserved.
//

import Foundation

class UsersPopoverView: UIView, NibInstantiatable {
    
    static var nibName: NibName = "UsersPopoverView"
    weak var delegate: PopoverViewDelegate?
    @IBOutlet weak var userPickerView: UIPickerView!

}

extension UsersPopoverView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let group = selectedGroup else { return 0 }
        return group.users.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let group = selectedGroup else { return nil }
        return group.users[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let group = selectedGroup else { return }
        let userName = group.users[row].name
        delegate?.updatesNeeded()
        popover.dismiss()
    }
}
