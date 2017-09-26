//
//  AppDelegate.swift
//  DouBan
//
//  Created by zhou on 16/11/17.
//  Copyright © 2016年 zhou. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        return true
    }
    
    //后台播放响应控制所必须的
    override func becomeFirstResponder() -> Bool {
        print("\(canBecomeFirstResponder)")
        return true
    }
    
    //后台播放控制事件响应
    override func remoteControlReceived(with event: UIEvent?) {
        let vc = self.window?.rootViewController
        if (vc?.isEqual(ViewController.self) != nil) {
            
            if event?.type == UIEventType.remoteControl {
                switch event!.subtype {
                case UIEventSubtype.remoteControlTogglePlayPause:
                    
                    print("暂停播放")
                case UIEventSubtype.remoteControlNextTrack:
                    (vc as! ViewController).onRemotePlayNext()
                    print("下一首")
                case UIEventSubtype.remoteControlPreviousTrack:
                    (vc as! ViewController).onRemotePlayPre()
                    print("上一首")
                case UIEventSubtype.remoteControlPause:
                    (vc as! ViewController).onRemotePause()
                    print("暂停")
                case UIEventSubtype.remoteControlPlay:
                    (vc as! ViewController).onRemotePlay()
                    print("播放")
                default:
                    print("呵呵")
                }
            }
            
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        
//        AVAudioSession session=[AVAudioSession sharedInstance]
//        [session setActive:YES error:nil]
//        //后台播放
//        [session setCategory:AVAudioSessionCategoryPlayback error:nil]
//        //这样做，可以在按home键进入后台后 ，播放一段时间，几分钟吧。但是不能持续播放网络歌曲，若需要持续播放网络歌曲，还需要申请后台任务id，具体做法是：
//        _bgTaskId=[AppDelegate backgroundPlayerID:_bgTaskId]
//        //其中的_bgTaskId是后台任务UIBackgroundTaskIdentifier _bgTaskId;
//        
//        try
//            {
//        AVAudioSession.sharedInstance().setActive(true)
//        }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

