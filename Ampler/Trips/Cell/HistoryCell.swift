//
//  HistoryCell.swift
//  Ampler
//
//  Created by Haik Ampardjian on 8/18/19.
//  Copyright © 2019 Haik Ampardjian. All rights reserved.
//

import UIKit

final class HistoryCell: UITableViewCell {
    @IBOutlet fileprivate weak var start: UILabel!
    @IBOutlet fileprivate weak var end: UILabel!
    
    func setup(session: Trip) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        start.text = formatter.string(from: session.startDate)
        end.text = formatter.string(from: session.endDate)
    }
}
