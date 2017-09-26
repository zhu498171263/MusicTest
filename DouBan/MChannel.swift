//
//  MChannel.swift
//  DouBan
//
//  Created by zhou on 16/11/18.
//  Copyright © 2016年 zhou. All rights reserved.
//

import UIKit

class MChannel: NSObject {
    var channel_id:String = ""
    var channel_name:String = ""
    init(channel_id:String,channel_name:String) {
        self.channel_id = channel_id
        self.channel_name = channel_name
    }

}
