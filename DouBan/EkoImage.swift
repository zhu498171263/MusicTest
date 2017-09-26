//
//  EkoImage.swift
//  DouBan
//
//  Created by zhou on 16/11/17.
//  Copyright © 2016年 zhou. All rights reserved.
//

import UIKit

class EkoImage: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //设置圆角
        self.clipsToBounds = true
        self.layer.cornerRadius = (self.image?.size.width)!/2
        
        //边框
        self.layer.borderWidth = 4
        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).cgColor
    }
    
    //旋转
    func onRotation(){
        //动画实例关键字
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        //初始值
        animation.fromValue = 0.0
        //结束值
        animation.toValue = M_PI*2.0
        //动画执行时间
        animation.duration = 20
        //动画重复次数
        animation.repeatCount = 10000
        self.layer.add(animation, forKey: nil)
    }

}
