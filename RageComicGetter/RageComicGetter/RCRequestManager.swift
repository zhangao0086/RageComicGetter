//
//  RCRequestManager.swift
//  RageComicGetter
//
//  Created by 张奥 on 15/2/16.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import Cocoa

let ListAllURL = "http://alltheragefaces.com/api/all/faces"

let requestManager = RCRequestManager()

class RCRequestManager: NSObject {
    
    private let manager = AFHTTPRequestOperationManager()
    
    class func sharedManager() -> RCRequestManager {
        return requestManager
    }
    
    func getListWithDirectory(directory: NSString) {
        var isDir = ObjCBool(true)
        let isExists = NSFileManager.defaultManager().fileExistsAtPath(directory, isDirectory:&isDir)
        if isExists == false {
            println("不是有效的目录")
            return
        }
        manager.GET(ListAllURL, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            var images = Array<RCImage>()
            if let imagesDict = responseObject as? NSArray {
                for imageDict in imagesDict {
                    let image = RCImage()
                    image.id = imageDict["id"] as NSString
                    image.title = imageDict["title"] as NSString
                    image.emotion = imageDict["emotion"] as NSString
                    image.canonical = imageDict["canonical"] as NSString
                    image.created = imageDict["created"] as NSString
                    image.categoryfk = imageDict["categoryfk"] as NSString
                    if let tags = imageDict["tags"] as? NSString {
                        image.tags = tags
                    }
                    image.views = imageDict["views"] as NSString
                    image.weeklyViews = imageDict["weekly_views"] as NSString
                    image.png = imageDict["png"] as NSString
                    image.jpg = imageDict["jpg"] as NSString
                    image.largePng = imageDict["largepng"] as NSString
                    image.svg = imageDict["svg"] as NSString
                    
                    images.append(image)
                }
            }
            println("共\(images.count)张")
            
            self.downloadsForImages(images, directory: directory)
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print(error)
        }
    }
    
    private func downloadsForImages(images: Array<RCImage>, directory: NSString) {
        if images.count > 0 {
            println("开始下载...")

            var i = 0
            for image in images {
                let request = NSURLRequest(URL: NSURL(string: image.png)!)
                var imageName = image.title + "-\(image.id)"
                while (imageName.hasPrefix(".")) {
                    imageName.removeAtIndex(imageName.startIndex)
                }
                let savedUrl = NSURL(string: directory)
                let savedPath = savedUrl!.URLByAppendingPathComponent(imageName + ".png").absoluteString!.stringByRemovingPercentEncoding!
                
                let operation = AFHTTPRequestOperation(request: request)
                operation.outputStream = NSOutputStream(toFileAtPath: savedPath, append: false)
                operation.setCompletionBlockWithSuccess({ (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                    println("File download to \(savedPath)")
                    println(++i)
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    println("error: \(error)")
                })
                
                manager.operationQueue.maxConcurrentOperationCount = 3
                manager.operationQueue.addOperation(operation)
            }
        }
    }
}
