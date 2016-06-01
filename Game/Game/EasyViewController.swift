//
//  EasyViewController.swift
//  Game
//
//  Created by Chuanxi Xiong on 4/5/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import UIKit
import AVFoundation

class EasyViewController: UIViewController {
    
    // MARK: Properties
    var filledPosition = 0
    var positionViews = [UIView]()
    var filledViews = [UIView]()
    var filledValues = [Int]()
    let image3 = UIImageView(image: UIImage(named: "three"))
    let image2 = UIImageView(image: UIImage(named: "two"))
    let image1 = UIImageView(image: UIImage(named: "one"))
    let image4 = UIImageView(image: UIImage(named: "four"))
    let image5 = UIImageView(image: UIImage(named: "five"))
    let helpingHand = UIImageView(image: UIImage(named: "hand"))
    var frame3: CGRect?
    var frame2: CGRect?
    var frame1: CGRect?
    var frames = [CGRect]()
    var images = [UIImage]()
    var currIter = 0
    var rocket: UIView?
    let soundManager = SoundManager.sharedInstance
    var view2: UIView?
    var view1: UIView?
    var usedNumbers = [UIView]()
    var buttons = [UIButton]()
    var unusedNumbers = [UIView]()
    var playButtonFrame: CGRect?
    
    @IBAction func pan2(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)
        if let view = sender.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                y:view.center.y + translation.y)
        }
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    @IBAction func buttonSegue(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        performSegueWithIdentifier("unwindToMainPage", sender: sender)
    }
    
    
    /// - Attributions: http://stackoverflow.com/questions/26755014/disable-a-button-for-90-sec-when-pressed-in-swift
    func enableButtons() {
        for button in buttons {
            button.enabled = true
        }
    }
    
    func disableButtons(seconds: NSTimeInterval) {
        for button in buttons {
            button.enabled = false
        }
        NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: "enableButtons", userInfo: nil, repeats: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // setting up the background
        self.view.backgroundColor = UIColor(white: 0.25, alpha: 1)
        let frame = self.view.frame
        var spacingToTop = frame.height/10
         //print(spacingToTop)
        
        if (spacingToTop < 38) {
            spacingToTop = CGFloat(38)
        }
        
        // add three squares
        addThreeViews(spacingToTop, frame: frame)
        
        // setting up the buttons
        addBackButton(spacingToTop)
        addPlayButton(spacingToTop)
        addRedoButton(spacingToTop)
        addHelpButton(spacingToTop)

        
        
        let widthOfPuzzle = (frame.width - 50)/15
        
        image2.frame = CGRectMake(20 + 2 * widthOfPuzzle, spacingToTop + widthOfPuzzle/2 , widthOfPuzzle, widthOfPuzzle * 1.1)
        frame2 = image2.frame
        image2.tag = 2
        image2.userInteractionEnabled = true
        image3.frame = CGRectMake(20 + 2 * widthOfPuzzle, spacingToTop + widthOfPuzzle * 2 , widthOfPuzzle, widthOfPuzzle * 1.1)
        frame3 = image3.frame
        image3.tag = 3
        image3.userInteractionEnabled = true
        image1.frame = CGRectMake(20 + 2 * widthOfPuzzle, spacingToTop + widthOfPuzzle * 3.5 , widthOfPuzzle, widthOfPuzzle * 1.1)
        frame1 = image1.frame
        image1.tag = 1
        image1.userInteractionEnabled = true
        
        frames = [frame1!, frame2!, frame3!]
        images = [image1.image!, image2.image!, image3.image!]
        unusedNumbers = [image1, image2, image3]
        
        self.view.addSubview(image1)
        self.view.addSubview(image2)
        self.view.addSubview(image3)
        
        addPanAndTapGestureRecognizer(image1)
        addPanAndTapGestureRecognizer(image2)
        addPanAndTapGestureRecognizer(image3)

        let widthOfPositionView = widthOfPuzzle / 2
        let originXOfPositionView = 25 + 7.25 * widthOfPuzzle
        var originYOfPositionView = spacingToTop + 2.775 * widthOfPuzzle

        while (originYOfPositionView < frame.height) {
            let newPos = UIView()
            newPos.frame = CGRectMake(originXOfPositionView, originYOfPositionView, widthOfPositionView, widthOfPositionView * 1.1)
            self.view.addSubview(newPos)
            positionViews.append(newPos)
            filledValues.append(0)
            originYOfPositionView += widthOfPuzzle
        }
        sayInstruction()
    }
    
    func addThreeViews(spacingToTop: CGFloat, frame : CGRect) {
        
        let color = UIColor(white: 1, alpha: 0.9)
        view1 = UIView(frame: CGRect(x: 20, y: spacingToTop, width: (frame.width - 50)/3, height: frame.height - 20 - spacingToTop))
        view1!.backgroundColor = color
        view1!.layer.cornerRadius = spacingToTop/4

        view2 = UIView(frame: CGRect(x: 25 + view1!.frame.width, y: spacingToTop, width: view1!.frame.width, height: view1!.frame.height))
        view2!.backgroundColor = color
        view2!.layer.cornerRadius = spacingToTop/4

        let view3 = UIView(frame: CGRect(x: 30 + 2 * view1!.frame.width, y: spacingToTop, width: view1!.frame.width, height: view1!.frame.height))
        view3.backgroundColor = color
//        let view3 = UIImageView(image: UIImage(named: "background"))
//        view3.contentMode = UIViewContentMode.ScaleToFill
//        view3.clipsToBounds = true

        view3.frame = CGRectMake(30 + 2 * view1!.frame.width, spacingToTop, view1!.frame.width, view1!.frame.height)
        view3.layer.cornerRadius = spacingToTop/4
        
        let widthOfPuzzle = view2!.frame.width/5
        image5.tag = 5
        image5.frame = CGRectMake(view2!.frame.origin.x + 2 * widthOfPuzzle, view2!.frame.origin.y + widthOfPuzzle/2 , widthOfPuzzle, widthOfPuzzle * 1.1)
        image5.userInteractionEnabled = true
        addTapGestureRecognizer(image5)
        
        image4.tag = 4
        image4.frame = CGRectMake(view2!.frame.origin.x + 2 * widthOfPuzzle, image5.frame.origin.y + widthOfPuzzle , widthOfPuzzle, widthOfPuzzle * 1.1)
        image4.userInteractionEnabled = true
        addTapGestureRecognizer(image4)
        filledViews = [image5, image4]

        let widthOfRocket = view2!.frame.width/3
        rocket = UIImageView(image: UIImage(named: "rocket"))
        rocket!.frame = CGRectMake(view3.frame.origin.x + widthOfRocket, frame.height - 2.5 * widthOfRocket, widthOfRocket, 2 * widthOfRocket)

        self.view.addSubview(view1!)
        self.view.addSubview(view2!)
        self.view.addSubview(view3)
        self.view.addSubview(image5)
        self.view.addSubview(image4)
        self.view.addSubview(rocket!)
        
    }

    func addBackButton(spacingToTop : CGFloat) {

        let backButton = UIButton(frame: CGRect(x: 20, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        backButton.setImage(UIImage(named: "backButton"), forState: .Normal)
        backButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        backButton.addTarget(self, action: "buttonSegue:", forControlEvents: .TouchUpInside)
        buttons.append(backButton)
        self.view.addSubview(backButton)
    }
    
    func addPlayButton(spacingToTop : CGFloat) {
        

        let playButton = UIButton(frame: CGRect(x: self.view.frame.width - 20 - spacingToTop * 3 / 4, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        playButtonFrame = playButton.frame
        playButton.setImage(UIImage(named: "playButton"), forState: .Normal)
        playButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        playButton.addTarget(self, action: "checkWin", forControlEvents: .TouchUpInside)
        buttons.append(playButton)
        self.view.addSubview(playButton)
    }
    
    func addRedoButton(spacingToTop : CGFloat) {
        
        let redoButton = UIButton(frame: CGRect(x: self.view.frame.width - 20 - spacingToTop * 2, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        redoButton.setImage(UIImage(named: "redoButton"), forState: .Normal)
        redoButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        redoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        redoButton.addTarget(self, action: "reset", forControlEvents: .TouchUpInside)
        buttons.append(redoButton)
        self.view.addSubview(redoButton)
    }
    
    func addHelpButton(spacingToTop : CGFloat) {
        
        let helpButton = UIButton(frame: CGRect(x: self.view.frame.width - 20 - spacingToTop * 13 / 4, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        helpButton.setImage(UIImage(named: "questionButton"), forState: .Normal)
        helpButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        helpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        helpButton.addTarget(self, action: "help", forControlEvents: .TouchUpInside)
        buttons.append(helpButton)
        self.view.addSubview(helpButton)
    }
    
    func addPanAndTapGestureRecognizer(view: UIImageView) {

        let panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        addTapGestureRecognizer(view)
    }
    
    func addTapGestureRecognizer(view: UIImageView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
//        print("\(recognizer.view!.tag) panned")

        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        // update the filled Position is a puzzle put in the chain is moved, so that it can still snap to the original place
        if recognizer.state == .Began {
            let tag = recognizer.view!.tag
            if (filledViews.contains(recognizer.view!)) {
                filledPosition = filledViews.indexOf(recognizer.view!)! - 2
                print("filled position updated = \(filledPosition) and the tag is \(tag)")
            }
        }
        
        if recognizer.state == .Ended {

            if CGRectIntersectsRect(recognizer.view!.frame, positionViews[filledPosition].frame) {
                let tag = recognizer.view!.tag
                filledValues[filledPosition] = tag
                
                // if put into the right place, generate a new image view to snap into place
                let newImageView = UIImageView(image: images[tag - 1])
                newImageView.tag = tag
                newImageView.frame = recognizer.view!.frame
                newImageView.center = positionViews[filledPosition].center
                newImageView.userInteractionEnabled = true
                self.view.addSubview(newImageView)
                addPanAndTapGestureRecognizer(newImageView)
                
                usedNumbers.append(newImageView)
                filledViews.append(newImageView)
                
                //put the original one back
                if (usedNumbers.contains(recognizer.view!)) {
                    usedNumbers.removeAtIndex(usedNumbers.indexOf(recognizer.view!)!)
                }
                recognizer.view!.frame = frames[tag - 1]
                unusedNumbers[tag - 1].removeFromSuperview()
                unusedNumbers[tag - 1] = recognizer.view!
                self.view.addSubview(unusedNumbers[tag - 1])

                filledPosition++
                dispatch_async(dispatch_get_main_queue()) {
                    self.soundManager.playSnap()
                }
                recalculate()
            }
            else if CGRectContainsRect(view2!.frame, recognizer.view!.frame){
                
                // create a new piece wherever the pan is
                let tag = recognizer.view!.tag
                let newImageView = UIImageView(image: images[tag - 1])
                newImageView.tag = tag
                newImageView.frame = recognizer.view!.frame
                newImageView.userInteractionEnabled = true
                usedNumbers.append(newImageView)
                self.view.addSubview(newImageView)
                addPanAndTapGestureRecognizer(newImageView)
                
                // put the original one back
                recognizer.view!.frame = frames[tag - 1]
                
                if (usedNumbers.contains(recognizer.view!)) {
                    usedNumbers.removeAtIndex(usedNumbers.indexOf(recognizer.view!)!)
                }
                unusedNumbers[tag - 1].removeFromSuperview()
                unusedNumbers[tag - 1] = recognizer.view!
                self.view.addSubview(unusedNumbers[tag - 1])
                recalculate()
            }
            else {

                let tag = recognizer.view!.tag
                
                if (usedNumbers.contains(recognizer.view!)) {
                    usedNumbers.removeAtIndex(usedNumbers.indexOf(recognizer.view!)!)
                }

                dispatch_async(dispatch_get_main_queue()) {
                    self.soundManager.playSlide()
                    if (recognizer.view! !== self.unusedNumbers[tag - 1]) {
                        self.unusedNumbers[tag - 1].removeFromSuperview()
                        self.unusedNumbers[tag - 1] = UIView()
                        self.unusedNumbers[tag - 1] = recognizer.view!
                    }
                }
                
                UIView.animateWithDuration(1, delay: 0, options: [], animations: {
                    recognizer.view!.frame = self.frames[tag - 1]
                    }, completion: nil)
                recalculate()
            }
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
//        print("\(recognizer.view!.tag) tapped")
        playIndividualEffect(recognizer.view!)
    }
    
    func playSequentEffect(timer: NSTimer) {
        
        playIndividualEffect(filledViews[currIter++])
        if (currIter == filledViews.count) {
            timer.invalidate()
        }
    }
    
    func playIndividualEffect(view: UIView) {
        
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.25, delay: 0, options: [], animations: {
                view.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.soundManager.play(view.tag)
                }, completion: { finished in
                    UIView.animateWithDuration(0.25, animations: {
                        view.transform = CGAffineTransformMakeScale(1, 1)
                    })
            })
        }
    }
    
    func sayInstruction() {
        let string = "Drag the numbers from the left to the middle area to count to one"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
    }
    
    func help() {
        disableButtons(1.0)
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        var pieceToMove : UIView?
        if (filledPosition < 3) {
            sayInstruction()
            pieceToMove = unusedNumbers[2 - filledPosition]
            pieceToMove?.alpha = 0.8
            helpingHand.alpha = 0.8
            helpingHand.frame = frames[2]
            helpingHand.frame.origin.y = frame1!.height * 0.6
            helpingHand.frame.origin.x = 0
            pieceToMove!.addSubview(helpingHand)
            self.view.addSubview(pieceToMove!)
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(2, delay: 0, options: .CurveEaseInOut, animations: {
                    pieceToMove?.center = self.positionViews[self.filledPosition].center
                    }, completion: { finished in
                        pieceToMove!.frame = self.frames[2 - self.filledPosition]
                        pieceToMove?.alpha = 1
                        self.helpingHand.removeFromSuperview()
                })
            }
        }
        else {
            helpingHand.frame = frames[2]
            helpingHand.center = CGPointMake((playButtonFrame?.midX)!, (playButtonFrame?.midY)!)
            helpingHand.center.y += frames[2].height/2
            helpingHand.alpha = 0.8
            self.view.addSubview(self.helpingHand)
            UIView.animateWithDuration(2, delay: 0, options: .CurveEaseIn, animations: {
                self.helpingHand.alpha = 0
                }, completion: {finished in
                    UIView.animateWithDuration(0, animations: {
                        self.helpingHand.removeFromSuperview()
                    })
            })
        }
    }
    
    func checkWin() {
        print("array \(filledValues)")
        
        disableButtons(0.75 * Double(filledPosition + 4))
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        currIter = 0
        NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: "playSequentEffect:", userInfo: nil, repeats: true)
        if filledPosition == 3 && filledValues[0] == 3 && filledValues[1] == 2 && filledValues[2] == 1 {
            NSTimer.scheduledTimerWithTimeInterval(0.75 * Double(filledPosition + 3), target: self, selector: "playWin:", userInfo: nil, repeats: false)
            NSTimer.scheduledTimerWithTimeInterval(0.75 * Double(filledPosition + 4), target: self, selector: "animateRocket:", userInfo: nil, repeats: false)
        }
        else {
            NSTimer.scheduledTimerWithTimeInterval(0.75 * Double(filledPosition + 3), target: self, selector: "playLose:", userInfo: nil, repeats: false)
            NSTimer.scheduledTimerWithTimeInterval(0.75 * Double(filledPosition + 4), target: self, selector: "fallingRocket:", userInfo: nil, repeats: false)

        }
    }
    
    func reset() {
        disableButtons(1.0)
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        for view in usedNumbers {
            view.removeFromSuperview()
        }
        usedNumbers.removeAll()
        unusedNumbers = [image1, image2, image3]
        filledPosition = 0
        filledViews = [image5, image4]
    }
    
    func playWin(timer: NSTimer) {

        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playBlastOff()
        }
    }
    
    func playLose(timer: NSTimer) {
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTrombone()
        }
    }
    
    func animateRocket(timer: NSTimer) {
        let curr = self.rocket!.frame
        UIView.animateWithDuration(2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            var ending = curr
            ending.origin.y = curr.origin.y - self.view.frame.height
            self.rocket!.frame = ending
            }) {_ in
                self.rocket!.frame = curr
        }
//        rocket!.frame.origin.y = rocket!.frame.origin.y + self.view.frame.height
    }
    
    func fallingRocket(timer: NSTimer) {
        let frame = self.rocket!.frame
        let origin = frame.origin
        var newOrigin = origin
        newOrigin.x = origin.x - frame.width / 2
        newOrigin.y = origin.y + frame.height - frame.width

        UIView.animateWithDuration(3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.rocket!.frame = frame
            let rotate = CGAffineTransformMakeRotation(90.0 * CGFloat(M_PI) / 180.0);
            self.rocket!.transform = rotate
            self.rocket!.frame.origin = newOrigin
            }) {_ in UIView.animateWithDuration(0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.rocket!.transform = CGAffineTransformMakeRotation((0 * CGFloat(M_PI))/180.0)
                self.rocket!.frame.origin = origin
                }, completion: { (finised: Bool) -> Void in
            })
        }
    }

    
    func recalculate() {
        print("filledposition \(filledPosition)")
        print("filledcount \(filledViews.count)")
        filledViews = [image5, image4]
        filledValues = Array(count: filledValues.count, repeatedValue: 0)
        filledPosition = 0
        for index in 0..<self.positionViews.count {
            var flag = false
            for view in self.usedNumbers {
                if (CGRectIntersectsRect(self.positionViews[index].frame, view.frame)) {
                    flag = true
                    filledPosition = index + 1
                    filledViews.append(view)
                    filledValues[index] = view.tag
//                    print(filledPosition)
                }
            }
            if (flag == false) {
                break
            }
        }
        
        if (filledPosition < filledViews.count - 2) {
            filledViews.removeRange(filledPosition+2..<filledViews.count)
        }
        
        if (filledPosition < filledValues.count) {
            for index in filledPosition+1..<filledValues.count {
                filledValues[index] = 0
            }
        }

        print("filledposition \(filledPosition)")
        print("filledcount \(filledViews.count)")
        print("filledvalues\(filledValues)")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}

extension EasyViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(gestureRecognizer.view!) {
            return true
        }
        return false
    }
}

