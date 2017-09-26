//
//  MSong.swift
//  DouBan
//
//  Created by zhou on 16/11/18.
//  Copyright © 2016年 zhou. All rights reserved.
//

import UIKit

class MSong: NSObject {
    var url:String!
    var pic:String!
    var lrc:String!
    var title:String!
    var artistName:String!
    
    init(url:String="",pic:String="",lrc:String="",title:String="",artistName:String=""){
        self.url = url
        self.pic = pic
        self.lrc = lrc
        self.title = title
        self.artistName = artistName
    }
}
