//
//  HTTPController.swift
//  DouBan
//
//  Created by zhou on 16/11/18.
//  Copyright © 2016年 zhou. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//定义http协议
protocol HttpProtocol {
    //定义一个方法，接收一个参数：AnyObject
    func didRecieveResults(results:AnyObject)
    func onSetAudio(mSong:MSong)
    func onGetLrc(arrLrc:[LRCModel])
}


class HTTPController: NSObject
{
    //定义一个代理
    var delegate:HttpProtocol?
    //接收网址，回调代理的方法传回数据
    func onSearch(url:String){
        
        request(url).responseJSON(completionHandler: { (data) in
            if data.result.isSuccess {
                self.delegate?.didRecieveResults(results: data.result.value as AnyObject)
            }
        })
    }
    
    func onGetSong(url:String)
    {
        request(url).responseJSON(completionHandler: { (data) in
            if data.result.isSuccess {
                let json = JSON(data.result.value!)
                if let song = json["data"]["songList"].array {
                    let mSong = MSong(url: song[0]["songLink"].string!, pic: song[0]["songPicRadio"].string!, lrc: song[0]["lrcLink"].string!,title: song[0]["songName"].string!,artistName: song[0]["artistName"].string!)
                    self.delegate?.onSetAudio(mSong: mSong)
                }
        }
    })
    }
    func onGetLrc(url:String){
        request(url).responseJSON(completionHandler: { (data) in
            
            if data.result.isSuccess {
                var lrcLineArr = [LRCModel]()
                let json = JSON(data.result.value!)
                if let lrc = json["lrcContent"].string {
                    let lrcArr:Array = lrc.components(separatedBy: "\n")
                    for lrcCmp in lrcArr {
                        let line:LRCModel = LRCModel()
                        lrcLineArr.append(line)
                        //如果该行没有以[开头就跳过去不处理，防止空格行的出现
                        if !lrcCmp.hasPrefix("["){continue}
                        //如果该lrc有包含头部信息
                        if lrcCmp.hasPrefix("[ti:") || lrcCmp.hasPrefix("[ar:") || lrcCmp.hasPrefix("[al:") || lrcCmp.hasPrefix("[by:") || lrcCmp.hasPrefix("[offset:"){
                            
                            let wordStr:String = lrcCmp.components(separatedBy:":").last!
                            let endIndex = wordStr.index(before: wordStr.endIndex)//.advancedBy(-1) //相对于当前索引的偏移
                            line.word = wordStr.substring(to: endIndex)
                        }else{ //歌词文本
                            
                            let wordArr:Array = lrcCmp.components(separatedBy:"]")
                            let startIndex = wordArr.first!.index(after: wordArr.first!.startIndex)//.advancedBy(1)
                            line.time = (wordArr.first?.substring(from: startIndex))!
                            line.word = wordArr.last!
                        }
                    }
                    
                }else{
                    let error = LRCModel()
                    error.time = ""
                    error.word = "没有歌词"
                    lrcLineArr.append(error)
                }
                self.delegate?.onGetLrc(arrLrc: lrcLineArr)
            }
    
        })
    }
    
//    //接收网址，回调代理的方法传回数据
//    func test(url:String){
//        request(url).responseString(queue: nil, encoding: String.Encoding.nonLossyASCII, completionHandler: { (DataResponse) in
//            if DataResponse.result.isSuccess {
//                let json = DataResponse.result.value!
//                let lrcArr:Array = json.components(separatedBy: "[[\"")
//                let last:Array = (lrcArr.last?.components(separatedBy: ",[\""))!
//                for i in last
//                {
//                    let l:Array = (i.components(separatedBy: "\",\""))
//                    print("++++++++++++++++++\(l[1])")
//                    //                    for a in l
//                    //                    {
//                    //                        print("++++++++++++++++++"+a)
//                    //                    }
//                }
//            }
//
//        })
//    }
}

