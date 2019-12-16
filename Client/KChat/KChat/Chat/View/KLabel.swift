//
//  KLabel.swift
//  KChat
//
//  Created by 王申宇 on 24/11/2019.
//  Copyright © 2019 王申宇. All rights reserved.
//

import UIKit

class KLabel: UILabel {
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets.init(top: 8, left: 16, bottom: 8, right: 16)
    super.drawText(in: rect.inset(by: insets))
  }
}
