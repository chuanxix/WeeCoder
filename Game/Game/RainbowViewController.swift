//
//  RainbowViewController.swift
//  Wee Coders
//
//  Created by Chuanxi Xiong on 5/4/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import UIKit
import AVFoundation

class RainbowViewController: UIViewController {// MARK: Properties
    var filledPosition = 0
    var positionViews = [UIView]()
    var filledViews = [UIView]()
    var filledValues = [Int]()

    var imageViews = [UIImageView]()
    var arcViews = [UIImageView]()
    var given1: UIImageView?
    var given2: UIImageView?
    var colors = [UIColor]()
    var colorStrings = [String]()
    
    let helpingHand = UIImageView(image: UIImage(named: "hand"))
    var frames = [CGRect]()
    var images = [UIImage]()

    var currIter = 0
    var rocket: UIView?
    let soundManager = SoundManager.sharedInstance
    var view2: UIView?
    var view1: UIView?
    var view3: UIView?
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
        performSegueWithIdentifier("unwindToMainPageFromRainbow", sender: sender)
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
        
        imageViews = [UIImageView(image: UIImage(named: "color1")), UIImageView(image: UIImage(named: "color2")), UIImageView(image: UIImage(named: "color3")), UIImageView(image: UIImage(named: "color4")), UIImageView(image: UIImage(named: "color5")), UIImageView(image: UIImage(named: "color6")), UIImageView(image: UIImage(named: "color7")), UIImageView(image: UIImage(named: "color8")), UIImageView(image: UIImage(named: "color9")), UIImageView(image: UIImage(named: "color10"))]
        arcViews = [UIImageView(image: UIImage(named: "arc1")), UIImageView(image: UIImage(named: "arc2")), UIImageView(image: UIImage(named: "arc3")), UIImageView(image: UIImage(named: "arc4")), UIImageView(image: UIImage(named: "arc5")), UIImageView(image: UIImage(named: "arc6")), UIImageView(image: UIImage(named: "arc7")), UIImageView(image: UIImage(named: "arc8")), UIImageView(image: UIImage(named: "arc9")), UIImageView(image: UIImage(named: "arc10"))]
        
        colorStrings = ["purple", "pink", "red", "dark orange", "orange", "light orange", "yellow", "green", "turquoise", "blue"]
        
        // add the colors to array
        colors = [UIColor.init(red: 143/255, green: 41/255, blue: 255/255, alpha: 1), UIColor.init(red: 255/255, green: 38/255, blue: 244/255, alpha: 1), UIColor.init(red: 252/255, green: 54/255, blue: 50/255, alpha: 1), UIColor.init(red: 255/255, green: 106/255, blue: 38/255, alpha: 1), UIColor.init(red: 255/255, green: 168/255, blue: 37/255, alpha: 1), UIColor.init(red: 255/255, green: 216/255, blue: 53/255, alpha: 1), UIColor.init(red: 246/255, green: 255/255, blue: 52/255, alpha: 1), UIColor.init(red: 113/255, green: 255/255, blue: 68/255, alpha: 1), UIColor.init(red: 52/255, green: 221/255, blue: 221/255, alpha: 1), UIColor.init(red: 15/255, green: 125/255, blue: 244/255, alpha: 1)]
        
        // setting up the background
        self.view.backgroundColor = UIColor(white: 0.25, alpha: 1)
        let frame = self.view.frame
        var spacingToTop = frame.height/10
        
        // in case the spacing is too small for small devices like iphone4s
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
        
        // add the rainbow frames
        addRainbowFrames(spacingToTop, frame: frame)
        
        addPalette(spacingToTop, frame: frame)

        let widthOfPuzzle = (frame.width - 50)/15
        let widthOfPositionView = widthOfPuzzle / 2
        let originXOfPositionView = 25 + 7.25 * widthOfPuzzle
        var originYOfPositionView = spacingToTop + 0.775 * widthOfPuzzle
        
        while (originYOfPositionView < frame.height) {
            let newPos = UIView()
            newPos.frame = CGRectMake(originXOfPositionView, originYOfPositionView, widthOfPositionView, widthOfPositionView * 1.1)
            self.view.addSubview(newPos)
            positionViews.append(newPos)
            filledValues.append(0)
            originYOfPositionView += widthOfPuzzle
        }
        addDefaultPieces(frame)
        sayInstruction()
    }
    
    func addPalette(spacingToTop: CGFloat, frame : CGRect) {
        
        let widthOfPuzzle = (frame.width - 50)/15
        let spacingBtwPieces = (frame.height - spacingToTop - 20 - 5 * widthOfPuzzle) / 6
        
        var originX = 20 + widthOfPuzzle
        var originY = spacingToTop + spacingBtwPieces
        
        for i in 0..<10 {
            imageViews[i].tag = i + 1
            images.append(imageViews[i].image!)
            imageViews[i].userInteractionEnabled = true
            unusedNumbers.append(imageViews[i])
        }
        
        for i in 0..<5 {
            let newUIImageView = imageViews[i]
            newUIImageView.frame = CGRectMake(originX, originY, widthOfPuzzle, widthOfPuzzle * 1.1)
            originY += widthOfPuzzle + spacingBtwPieces
            self.view.addSubview(newUIImageView)
            frames.append(newUIImageView.frame)
            
        }
        
        originX += 2 * widthOfPuzzle
        originY = spacingToTop + spacingBtwPieces
        for i in 5..<10 {
            let newUIImageView = imageViews[i]
            newUIImageView.frame = CGRectMake(originX, originY, widthOfPuzzle, widthOfPuzzle * 1.1)
            originY += widthOfPuzzle + spacingBtwPieces
            self.view.addSubview(newUIImageView)
            frames.append(newUIImageView.frame)
            
        }
        
        for image in imageViews {
            addPanAndTapGestureRecognizer(image)
        }
    }
    
    func addThreeViews(spacingToTop: CGFloat, frame : CGRect) {
        
        let color = UIColor(white: 1, alpha: 0.9)
        view1 = UIView(frame: CGRect(x: 20, y: spacingToTop, width: (frame.width - 50)/3, height: frame.height - 20 - spacingToTop))
        view1!.backgroundColor = color
        view1!.layer.cornerRadius = spacingToTop/4
        
        view2 = UIView(frame: CGRect(x: 25 + view1!.frame.width, y: spacingToTop, width: view1!.frame.width, height: view1!.frame.height))
        view2!.backgroundColor = color
        view2!.layer.cornerRadius = spacingToTop/4

        view3 = UIImageView(image: UIImage(named: "background"))
        view3!.layer.cornerRadius = spacingToTop/4
        view3!.frame = CGRectMake(30 + 2 * view1!.frame.width, spacingToTop, view1!.frame.width, view1!.frame.height)
        view3!.contentMode = UIViewContentMode.ScaleToFill
        view3!.clipsToBounds = true

        self.view.addSubview(view1!)
        self.view.addSubview(view2!)
        self.view.addSubview(view3!)

    }
    
    func addRainbowFrames(spacingToTop: CGFloat, frame: CGRect) {
        let viewHeight = frame.height - spacingToTop - 20
        let viewWidth = (frame.width - 50) / 3
        let arcFrame = CGRectMake(30 + 2 * viewWidth,spacingToTop + (viewHeight - viewWidth)/2, viewWidth, viewWidth)
        for i in 0..<10 {
            let imageView = arcViews[i]
            imageView.frame = arcFrame
            self.view.addSubview(imageView)
            imageView.image = imageView.image!.imageWithRenderingMode(.AlwaysTemplate)
            imageView.tintColor = UIColor.clearColor()
        }
    }
    
    func addDefaultPieces(frame: CGRect) {
        let widthOfPuzzle = view2!.frame.width/5
        
        let dottedImageView = UIImageView(image: UIImage(named: "dotted"))
        dottedImageView.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        dottedImageView.center = positionViews[0].center
        dottedImageView.userInteractionEnabled = false
        
        given1 = UIImageView(image: UIImage(named: "color1"))
        given1!.tag = 1
        given1!.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        given1!.center = positionViews[0].center
        given1!.userInteractionEnabled = true
        addPanAndTapGestureRecognizer(given1!)

        given2 = UIImageView(image: UIImage(named: "color3"))
        given2!.tag = 3
        given2!.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        given2!.center = positionViews[1].center
        given2!.userInteractionEnabled = true
        addPanAndTapGestureRecognizer(given2!)

        self.view.addSubview(dottedImageView)
        self.view.addSubview(given1!)
        self.view.addSubview(given2!)
        
        usedNumbers = [given1!, given2!]
        filledViews = [given1!, given2!]
        filledPosition = 2
        filledValues[0] = 1
        filledValues[1] = 3
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
        playButton.addTarget(self, action: "play", forControlEvents: .TouchUpInside)
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
        //        print("\(view.tag) added")
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
            if (filledViews.contains(recognizer.view!)) {
                filledPosition = filledViews.indexOf(recognizer.view!)!
            }
        }
        
        if recognizer.state == .Ended {
            print("ended with filledPosition = \(filledPosition)")
            if CGRectIntersectsRect(recognizer.view!.frame, positionViews[filledPosition].frame) {
                print("intersected")
                let tag = recognizer.view!.tag
                filledValues[filledPosition] = tag
                print(tag)
                
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
                        print("different")
                        self.unusedNumbers[tag - 1].removeFromSuperview()
                        self.unusedNumbers[tag - 1] = UIView()
                        self.unusedNumbers[tag - 1] = recognizer.view!
                    }
                }
                
                UIView.animateWithDuration(1, delay: 0, options: [], animations: {
                    recognizer.view!.frame = self.frames[tag - 1]
                    }, completion: nil)
                recalculate()
                
                print("count \(unusedNumbers.count)")
                print("count subviews \(self.view.subviews.count)")
            }
        }
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        //        print("\(recognizer.view!.tag) tapped")
        playIndividualEffect(recognizer.view!)
    }
    
    func playSequentEffect(timer: NSTimer) {
        playIndividualEffect(filledViews[currIter])
        UIView.animateWithDuration(1.5, animations: {
            self.arcViews[self.currIter].tintColor = self.colors[self.filledValues[self.currIter] - 1]
        })
        
        currIter = currIter + 1
        if (currIter == filledViews.count) {
//            let view = UIImageView(image: UIImage(named: "shining"))
//            self.view.addSubview(view)
//            view.alpha = 0
//            view.frame = (view3?.frame)!
//            view.contentMode = .ScaleAspectFill
//            view.clipsToBounds = true
//            UIView.animateWithDuration(2, delay: 3, options: .CurveEaseIn, animations: {
//                view.alpha = 1
//                self.soundManager.playMagic()
//                }, completion: {finished in
//                    view.alpha = 0
//                    view.removeFromSuperview()})
            timer.invalidate()
        }
    }
    
    func playIndividualEffect(view: UIView) {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.25, delay: 0, options: [], animations: {
                view.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.callColor(view.tag - 1)
                }, completion: { finished in
                    UIView.animateWithDuration(0.25, animations: {
                        view.transform = CGAffineTransformMakeScale(1, 1)
                    })
            })
        }
    }
    
    func help() {
        disableButtons(1.0)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        
        var pieceToMove : UIView?
        if (filledPosition < 3) {
            sayInstruction()
            pieceToMove = unusedNumbers[0]
            pieceToMove?.alpha = 0.8
            helpingHand.alpha = 0.8
            helpingHand.frame = frames[2]
            helpingHand.frame.origin.y = frames[0].height * 0.6
            helpingHand.frame.origin.x = 0
            pieceToMove!.addSubview(helpingHand)
            self.view.addSubview(pieceToMove!)
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(2, delay: 0, options: .CurveEaseInOut, animations: {
                    pieceToMove?.center = self.positionViews[self.filledPosition].center
                    }, completion: { finished in
                        pieceToMove!.frame = self.frames[0]
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
        
//            dispatch_async(dispatch_get_main_queue()) {
//                            }
    }
    
    func sayInstruction() {
        let string = "Drag the colors from the left to the middle area to draw a rainbow"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
    }
    
    /// - Attributions: http://nshipster.com/avspeechsynthesizer/
    func callColor(index: Int) {
        let string = colorStrings[index]
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
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
        unusedNumbers = imageViews
        addDefaultPieces(self.view.frame)
        clearAllRainbowColors()
    }
    
    func play() {
        for value in filledViews {
            print("tag\(value.tag)")
        }
        clearAllRainbowColors()
        disableButtons(1.5 * Double(filledPosition))
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        currIter = 0
        if (filledPosition > 0) {
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "playSequentEffect:", userInfo: nil, repeats: true)
        }
    }
    
    func clearAllRainbowColors() {
        for imageView in arcViews {
            imageView.tintColor = UIColor.clearColor()
        }
    }
    
    func recalculate() {
//        print("filledposition \(filledPosition)")
//        print("filledcount \(filledViews.count)")
        filledValues = Array(count: filledValues.count, repeatedValue: 0)
        filledPosition = 0
        filledViews = [UIImageView]()
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
        
        if (filledPosition < filledViews.count) {
            filledViews.removeRange(filledPosition..<filledViews.count)
        }
        
        if (filledPosition < filledValues.count) {
            for index in filledPosition+1..<filledValues.count {
                filledValues[index] = 0
            }
        }
        
//        print("filledposition \(filledPosition)")
//        print("filledcount \(filledViews.count)")
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

extension RainbowViewController: UIGestureRecognizerDelegate {
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
