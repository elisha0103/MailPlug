//
//  ModalBoardsDelegate.swift
//  MailPlug
//
//  Created by 진태영 on 2023/08/05.
//

import UIKit

protocol ModalBoardsDelegate: AnyObject {
    func didSelectedBoard(_ board: Board)
}
