//
//  ClassExtension.swift
//  KChat
//
//  Created by 王申宇 on 21/11/2019.
//  Copyright © 2019 王申宇. All rights reserved.
//

import Foundation

extension String {
    func withoutWhitespace() -> String {
      return self.replacingOccurrences(of: "\n", with: "")
        .replacingOccurrences(of: "\r", with: "")
        .replacingOccurrences(of: "\0", with: "")
    }
}
