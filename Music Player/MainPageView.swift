//
//  MainPageView.swift
//  Music Player
//
//  Created by Даниил on 05/10/2018.
//  Copyright © 2018 polat. All rights reserved.
//

import Foundation

protocol MainPageView: BaseView  {
    
    var onSongFlowSelect: ((_ popupController: PopupController) -> Void)? { get set }
    var onAlbumFlowSelect: ((_ popupConroller: PopupController) -> Void)? { get set }
}
