//
//  ViewController.swift
//  RageComicGetter
//
//  Created by 张奥 on 15/2/16.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var pathField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func request(sender: NSButton) {
        RCRequestManager.sharedManager().getListWithDirectory(pathField.stringValue)
    }
}

