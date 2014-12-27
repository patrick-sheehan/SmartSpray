//
//  HomeViewController.swift
//  SmartSpray
//
//  Created by Patrick Sheehan on 12/27/14.
//  Copyright (c) 2014 MSDS. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    var audioPlayer : AVAudioPlayer?

    override init() {
        super.init(nibName: "HomeViewController", bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        var path = NSBundle.mainBundle().resourcePath! + "/siren.mp3"
        var soundUrl = NSURL.fileURLWithPath(path)
        
        audioPlayer = AVAudioPlayer(contentsOfURL: soundUrl, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Button Actions
    
    @IBAction func speakerButtonPressed(sender: AnyObject) {
        
        if (audioPlayer?.playing == true) {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
        }
        else {
            audioPlayer?.play()
        }
    }
    
    @IBAction func phoneButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func messageButtonPressed(sender: AnyObject) {
        
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
