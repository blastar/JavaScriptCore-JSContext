//
//  ViewController.swift
//  JSContextDemo
//
//  Created by Krzysztof Deneka on 06.02.2017.
//  Copyright © 2017 biz.blastar.jscontextdemo. All rights reserved.
//

import UIKit
import JavaScriptCore

class ViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var textfield: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
        let url = Bundle.main.url(forResource: "web", withExtension: "html")
        webview.loadRequest(URLRequest(url: url!))
    }

    @IBAction func textfieldChanged(_ sender: UITextField) {
        self.webview.stringByEvaluatingJavaScript(from: "changeText('"+sender.text!+"')")

    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        let ctx = webview.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as! JSContext
        ctx.setObject(unsafeBitCast(CommunicationClass.self, to: AnyObject.self), forKeyedSubscript: "SwiftBridge" as (NSCopying & NSObjectProtocol)!)
        let textChanged: @convention(block) (String) -> () =
            { newtext in
                print("text changed \(newtext)")
                self.textfield.text = newtext
        }
        ctx.setObject(unsafeBitCast(textChanged, to: AnyObject.self), forKeyedSubscript: "textChanged" as (NSCopying & NSObjectProtocol)!)
    }
}

@objc protocol CommunicationProtocol: JSExport {
    static func callNativeFunction(_ mytext: String)
}

@objc class CommunicationClass: NSObject, CommunicationProtocol {
    class func callNativeFunction(_ mytext: String) {
        print("Native function called \(mytext)")
    }
}
