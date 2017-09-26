//
//  ViewController.swift
//  DouBan
//
//  Created by zhou on 16/11/17.
//  Copyright © 2016年 zhou. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import MediaPlayer
import Toast_Swift

class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,HttpProtocol,ChannelProtocol,LRClProtocol{

    //歌曲列表
    @IBOutlet weak var tv: UITableView!
    //圆形封面
    @IBOutlet weak var iv: EkoImage!
    //时间背景
    @IBOutlet weak var bg: UIImageView!
    //网络操作类的实例
    var eHttp:HTTPController = HTTPController()
    //定义一个变量，接收频道的歌曲数据
    var tableData = [JSON]()
    //定义一个变量，接收频道的数据
    var channelData = [MChannel]()
    
    //当前在播放第几首
    var currIndex:Int = 0
    
    var currSong:MSong = MSong()
    
    //定义一个图片缓存的字典
    var imageCache = Dictionary<String,UIImage>()
    
    //申明一个媒体播放器的实例
    var audioPlayer:MPMoviePlayerController =  MPMoviePlayerController()
    
    //申明一个计时器
    var timer:Timer?

    //播放时间标签
    @IBOutlet weak var playTime: UILabel!
    
    //播放进度图
    @IBOutlet weak var progress: UIImageView!
    
    //上一首按钮
    @IBOutlet weak var btnPre: UIButton!

    //播放按钮
    @IBOutlet weak var btnPlay: EkoButton!
    
    //下一首按钮
    @IBOutlet weak var btnNext: UIButton!
    
    //播放顺序控制按钮
    @IBOutlet weak var btnOrder: OrderButton!
    
    //歌词视图
    var lrcView:LRCVC?
    var arrLRC = [LRCModel]()
    
    var isAutoFinish:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置背景模糊
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        bg.didAddSubview(blurView)
        
        //设置tbaleView的数据源和代理
        tv.dataSource = self
        tv.delegate = self
        
        tv.backgroundColor = UIColor.clear
        
        eHttp.delegate = self
        
        eHttp.onSearch(url: "http://tingapi.ting.baidu.com/v1/restserver/ting?from=webapp_music&method=baidu.ting.billboard.billList&format=json&type=1&size=100")
        
//        eHttp.test(url: "http://www.ol3vs.com/static/js/player/06.js?t=20160926")
        
        
        //创建频道数据
        channelData.append(MChannel(channel_id: "1", channel_name: "新歌榜"))
        channelData.append(MChannel(channel_id: "2", channel_name: "热歌榜"))
        channelData.append(MChannel(channel_id: "11", channel_name: "摇滚榜"))
        channelData.append(MChannel(channel_id: "12", channel_name: "爵士"))
        channelData.append(MChannel(channel_id: "16", channel_name: "流行"))
        channelData.append(MChannel(channel_id: "21", channel_name: "欧美金曲榜"))
        channelData.append(MChannel(channel_id: "22", channel_name: "经典老歌榜"))
        channelData.append(MChannel(channel_id: "23", channel_name: "情歌对唱榜"))
        channelData.append(MChannel(channel_id: "24", channel_name: "影视金曲榜"))
        channelData.append(MChannel(channel_id: "25", channel_name: "网络歌曲榜"))
        
        //监听按钮点击
        btnPlay.addTarget(self, action: #selector(onPlay(btn:)), for: UIControlEvents.touchUpInside)
        btnNext.addTarget(self, action: #selector(onClick(btn:)), for: UIControlEvents.touchUpInside)
        btnPre.addTarget(self, action: #selector(onClick(btn:)), for: UIControlEvents.touchUpInside)
        btnOrder.addTarget(self, action: #selector(onOrder(btn:)), for: UIControlEvents.touchUpInside)
        
        //后台播放
        
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setActive(true)
            try session.setCategory(AVAudioSessionCategoryPlayback)
        }catch{
            print("后台播创建放失败")
        }
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            
//        }

    }
    
    func didRecieveResults(results:AnyObject){
        let json = JSON(results)
        //获取歌曲数据
        
        if let song = json["song_list"].array {
            isAutoFinish = false
            self.tableData = song
            //刷新tv的数据
            self.tv.reloadData()
            //设置第一首歌的图片以及背景
            //onSelectRow(index: 0)
        }
    }
    
    //设置tableview的数据行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    //配置tableView的单元格 cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tv.dequeueReusableCell(withIdentifier: "douban")!
        //让cell背景透明
        cell.backgroundColor = UIColor.clear
        //获取cell的数据
        let rowData:JSON = tableData[indexPath.row]
        //设置cell的标题
        cell.textLabel?.text = rowData["title"].string
        cell.detailTextLabel?.text = rowData["author"].string
        //设置缩略图
        cell.imageView?.image = UIImage(named: "timeBg")
        //封面的网址
        let url = rowData["pic_small"].string
        
//        request(url!).response { (data) in
//            let img = UIImage.init(data: data.data!)
//            cell.imageView?.image = img
//        }
        onGetCacheImage(url: url!, imgView: cell.imageView!)
        
        return cell
    }
    
    //点击了哪一首歌曲
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isAutoFinish = false
        currIndex = indexPath.row
        onSelectRow(index: indexPath.row)
    }
    
    //选中了哪一行
    func onSelectRow(index:Int)
    {
        
        //构建一个indexPath
        let indexPath = IndexPath.init(row: index, section: 0)
        //选中的效果
        tv.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
        //获取行数据
        var rowData:JSON = self.tableData[index] as JSON
        
        //获取音乐的文件地址
        let url:String = "http://ting.baidu.com/data/music/links?songIds=" + rowData["song_id"].string!
        let lrcUrl:String = "http://tingapi.ting.baidu.com/v1/restserver/ting?method=baidu.ting.song.lry&songid=" + rowData["song_id"].string!
        //获取歌曲地址等信息
        eHttp.onGetSong(url: url)
        //获取歌词
        eHttp.onGetLrc(url: lrcUrl)
    }
    
    //设置歌曲的封面以及背景
    func onSetImage(url:String){
        onGetCacheImage(url: url, imgView: self.iv)
        onGetCacheImage(url: url, imgView: self.bg)
    }
    
    //锁屏封面图片
    func onGetNowPlayingImg(mSong:MSong){
        
        //通过图片地址去缓存中取图片
        let image = self.imageCache[mSong.pic] as UIImage?
        if image == nil {
            //如果缓存中没有这张图片，就通过网络获取
            request(mSong.pic).response(completionHandler: { (data) in
                //将获取的图像数据赋予imgView
                let img = UIImage(data: data.data!)
                self.imageCache[mSong.pic] = img
                self.onSetNowPlaying(img: img!,mSong: mSong)
            })
        }else{
            //如果缓存中有，就直接用
            onSetNowPlaying(img: image!,mSong: mSong)
        }
    }
    //设置锁屏 必须真机调试才出得来
    func onSetNowPlaying(img:UIImage,mSong:MSong){
        
        let albumArtWork = MPMediaItemArtwork(image: img)
        let songInfo:[String:AnyObject]? = [
            MPMediaItemPropertyTitle:mSong.title as AnyObject,
            MPMediaItemPropertyArtist:mSong.artistName as AnyObject,
            MPMediaItemPropertyArtwork:albumArtWork,
            MPNowPlayingInfoPropertyElapsedPlaybackTime:0 as AnyObject,
            MPMediaItemPropertyPlaybackDuration:0 as AnyObject,
            MPNowPlayingInfoPropertyPlaybackRate:1.0 as AnyObject
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
        
        
    }
    func onUpdatePlayBackTime(playTime:Int = 0,duration:Int = 1000){
        var songInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if songInfo != nil {
            songInfo!.updateValue(playTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
            songInfo!.updateValue(duration, forKey: MPMediaItemPropertyPlaybackDuration)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo!
        }
        
        
    }


    //播放音乐的方法
    func onSetAudio(mSong:MSong){
        self.currSong = mSong
        onSetImage(url: mSong.pic)
        onGetNowPlayingImg(mSong: mSong)
        
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string: mSong.url) as URL!
        self.audioPlayer.play()
        
        btnPlay.onPlay()
        iv.onRotation()
        
        //先停掉计时器
        timer?.invalidate()
        //将计时器归零
        playTime.text = "00:00"

        //启动计时器
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdate), userInfo: nil, repeats: true)
        
        isAutoFinish = true
    }
    
    func onGetLrc(arrLrc:[LRCModel]){
        self.arrLRC = arrLrc
        self.lrcView?.arrLrc = arrLrc
        self.lrcView?.tableView.reloadData()
    }
    
    //计时器更新方法
    func onUpdate(){
        // 00:00 获取播放器当前的播放时间
        let c = audioPlayer.currentPlaybackTime
        
        if c>0.0 {
            onUpdatePlayBackTime(playTime: Int(audioPlayer.currentPlaybackTime),duration: Int(audioPlayer.duration))
            onUpdataLrc(c: Float(c))
            //歌曲的总时间
            let t = audioPlayer.duration
            
            //计算百分比
            let pro:CGFloat = CGFloat(c/t)
            //按百分比显示进度条的宽度
            progress?.frame.size.width = view.frame.size.width * pro
            //这是一个小算法，来实现 00:00 这种样式的播放时间
            
            let all:Int = Int(c)
            let m:Int = all % 60
            let f:Int = Int(all/60)
            
            var time:String = ""
            if f<10 {
                time = "0\(f):"
            }else{
                time = "\(f):"
            }
            
            if m<10 {
                time+="0\(m)"
            }else{
                time+="\(m)"
            }
            //更新播放时间
            playTime.text = time
            
            if all == Int(t) {
                playFinish()
            }
        }
    }
    
    func onUpdataLrc(c:Float){
        
        for (index,lrc) in arrLRC.enumerated() {
            let strTime = lrc.time
            if strTime != ""{
                let arrTime:[String] = strTime.components(separatedBy: ":")
                
                let fTime = Float(arrTime.first!)! * 60 + Float(arrTime.last!)!
                if c < fTime && index > 0{
                    self.lrcView?.onMoveToIndex(index: index - 1)
                    break
                }
            }
        }
    }
    
    //图片缓存策略方法
    func onGetCacheImage(url:String,imgView:UIImageView){
        //通过图片地址去缓存中取图片
        let image = self.imageCache[url] as UIImage?
        
        if image == nil {
            //如果缓存中没有这张图片，就通过网络获取
            request(url).responseJSON(completionHandler: { (data) in
                //将获取的图像数据赋予imgView
                let img = UIImage(data: data.data! )
                imgView.image = img
                
                self.imageCache[url] = img
            })
        }else{
            //如果缓存中有，就直接用
            imgView.image = image!
        }
    }
    
    func playFinish() {
        if isAutoFinish {
            switch(btnOrder.order){
            case 1:
                //顺序播放
                currIndex += 1
                if currIndex > tableData.count - 1 {
                    self.currIndex = 0
                }
                onSelectRow(index: currIndex)
            case 2:
                //随机播放
                currIndex = Int(arc4random_uniform(UInt32(tableData.count +  1)))
                onSelectRow(index: currIndex)
            case 3:
                //单曲循环
                onSelectRow(index: currIndex)
            default: break
                //"default"
            }
        }else{
            isAutoFinish = true
        }
    }
    
    func onOrder(btn:OrderButton){
        var message:String = ""
        switch(btn.order){
        case 1:
            message = "顺序播放"
        case 2:
            message = "随机播放"
        case 3:
            message = "单曲循环"
        default:
            message = "你逗我的吧"
        }
        self.view.makeToast(message, duration: 0.5, position: ToastPosition.center)
    }

    func playModel(num:Int)
    {
        if num == 0 {
            switch(btnOrder.order){
            case 1:
                //顺序播放
                currIndex += 1
                if currIndex > tableData.count - 1 {
                    self.currIndex = 0
                }
                onSelectRow(index: currIndex)
            case 2:
                //随机播放
                currIndex = Int(arc4random_uniform(UInt32(tableData.count +  1)))
                onSelectRow(index: currIndex)
            case 3:
                //单曲循环
                currIndex += 1
                if currIndex > tableData.count - 1 {
                    self.currIndex = 0
                }
                onSelectRow(index: currIndex)
            default: break
                //"default"
            }
        } else {
            switch(btnOrder.order){
            case 1:
                //顺序播放
                currIndex -= 1
                if currIndex < 0 {
                    currIndex = self.tableData.count - 1
                }
                onSelectRow(index: currIndex)
            case 2:
                //随机播放
                currIndex = Int(arc4random_uniform(UInt32(tableData.count +  1)))
                onSelectRow(index: currIndex)
            case 3:
                //单曲循环
                currIndex -= 1
                if currIndex < 0 {
                    currIndex = self.tableData.count - 1
                }
                onSelectRow(index: currIndex)
            default: break
                //"default"
            }
        }
    }
    
    func onClick(btn:UIButton){
        isAutoFinish = false
        if btn == btnNext {
            playModel(num: 0)
        }else{
            playModel(num: 1)
        }
        //onSelectRow(index: currIndex)
    }

    func onPlay(btn:EkoButton){
        if btn.isPlay{
            audioPlayer.play()
            let pausedTime = iv.layer.timeOffset
            if (pausedTime > 0)//在暂停后才能使用
            {
                iv.layer.speed = 1.0
                iv.layer.beginTime = 0.0
                let timeSincePause = iv.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                iv.layer.beginTime = timeSincePause
            }
        }else{
            audioPlayer.pause()
            let pausedTime = iv.layer.convertTime(CACurrentMediaTime(), from: nil)
            iv.layer.speed = 0.0;
            iv.layer.timeOffset = pausedTime;
        }
    }

    func onRemotePlayNext(){
        isAutoFinish = false
//        currIndex += 1
//        if currIndex > self.tableData.count - 1 {
//            currIndex = 0
//        }
//        onSelectRow(index: currIndex)
        playModel(num: 0)
        //        self.onUpdatePlayBackTime(0, duration: Int(audioPlayer.duration))
    }
    func onRemotePlayPre(){
        isAutoFinish = false
//        currIndex -= 1
//        if currIndex < 0 {
//            currIndex = self.tableData.count - 1-1
//        }
//        onSelectRow(index: currIndex)
        playModel(num: 0)
        //        self.onUpdatePlayBackTime(0, duration: Int(audioPlayer.duration))
    }
    func onRemotePlay(){
        audioPlayer.play()
        btnPlay.onClick()
        let pausedTime = iv.layer.timeOffset
        if (pausedTime > 0)//在暂停后才能使用
        {
            iv.layer.speed = 1.0
            iv.layer.beginTime = 0.0
            let timeSincePause = iv.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            iv.layer.beginTime = timeSincePause
        }
    }
    func onRemotePause(){
        audioPlayer.pause()
        btnPlay.onClick()
        let pausedTime = iv.layer.convertTime(CACurrentMediaTime(), from: nil)
        iv.layer.speed = 0.0;
        iv.layer.timeOffset = pausedTime;
    }

    //跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLRC" {
            let lrc:LRCVC = segue.destination as! LRCVC
            self.lrcView = lrc
            lrc.delegate = self
            lrc.arrLrc = self.arrLRC
        }else{
            //获取跳转目标
            let channelC:ChannelController = segue.destination as! ChannelController
            //设置代理
            channelC.delegate = self
            //传输频道列表数据
            channelC.channelData = self.channelData
        }
    }
    
    //歌词视图回调
    func onCloseLRC(){
        self.lrcView = nil
    }

    //频道列表协议的回调方法
    func onChangeChannel(channel_id:String){
        //拼凑频道列表的歌曲数据网络地址
        let url:String = "http://tingapi.ting.baidu.com/v1/restserver/ting?from=webapp_music&method=baidu.ting.billboard.billList&format=json&type=\(channel_id)&size=100"
        eHttp.onSearch(url: url)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



