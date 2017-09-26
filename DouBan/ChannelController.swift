//
//  ChannelController.swift
//  DouBan
//
//  Created by zhou on 16/11/18.
//  Copyright © 2016年 zhou. All rights reserved.
//

import UIKit

protocol ChannelProtocol{
    //回调方法，将频道id传回到代理中
    func onChangeChannel(channel_id:String)
}


class ChannelController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    //频道列表tableview组件
    @IBOutlet weak var tv: UITableView!
    //申明代理
    var delegate:ChannelProtocol?
    //频道列表数据
    var channelData = [MChannel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.delegate = self
        tv.dataSource = self
        
        self.view.alpha = 0.8

        // Do any additional setup after loading the view.
    }
    
    //配置tableview数据的行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    //配置cell的数据
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = tv.dequeueReusableCell(withIdentifier: "channel")!
        //获取行数据
        let rowData:MChannel = self.channelData[indexPath.row] as MChannel
        //设置cell的标题
        cell.textLabel?.text = rowData.channel_name
        return cell
    }
    
  
    
    //选中了具体的频道
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //获取行数据
        let rowData:MChannel = self.channelData[indexPath.row] as MChannel
        //获取选中行的频道id
        let channel_id:String = rowData.channel_id
        //将频道id反向传给主界面
        delegate?.onChangeChannel(channel_id: channel_id)
        //关闭当前界面
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
