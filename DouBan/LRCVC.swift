//
//  LRCVC.swift
//  DouBan
//
//  Created by zhou on 16/11/21.
//  Copyright © 2016年 zhou. All rights reserved.
//

import UIKit

class LRCVC: UITableViewController {
    
    //申明代理
    var delegate:LRClProtocol?
    var arrLrc:[LRCModel]!
    let headerHeight:CGFloat = 50.0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.alpha = 0.8
        self.tableView.backgroundColor = UIColor.white
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        //设定歌词cell的高度，以及高度随着歌词的行数自动变高
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrLrc.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let h = headerHeight
        let hView:UIView? = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: h))
        hView?.backgroundColor = UIColor.clear
        return hView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath as IndexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.text = arrLrc[indexPath.row].word
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.onCloseLRC()
        //关闭当前界面
        self.dismiss(animated: true, completion: nil)
    }
    
    func onMoveToIndex(index:Int){
        self.tableView.reloadData()
        let indexPath:IndexPath = IndexPath.init(row: index, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath as IndexPath)
        cell?.textLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        cell?.textLabel?.backgroundColor = UIColor.clear
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.middle, animated: true)
    }


}

protocol LRClProtocol{
    //回调方法，将频道id传回到代理中
    func onCloseLRC()
}
