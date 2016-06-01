//
//  HSNTViewController.swift
//  Wee Coders
//
//  Created by Chuanxi Xiong on 5/24/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import UIKit
import AVFoundation

class HSNTViewController: UIViewController {
    

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
    let personImage = UIImageView(image: UIImage(named: "person"))
    var arrowFrames = [CGRect]()
    let arrowImage = UIImage(named: "arrow")
    var paletteTag = [Int]()
    let seconds = [1.3, 1.2, 0.7, 0.7]
    let secondsForSong = [1.2, 1.2, 0.6, 0.6, 0.8, 1.2, 1.4, 1, 0.7, 0.8, 0.7, 7.1, 1.4, 1, 0.6, 0.6, 0.9, 0.8]
    let partsForSong = [0, 1, 2, 3, 2, 3, 0, 1, 2, 3, 2, 3, 0, 1, 2, 3, 2, 3]
    
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
        performSegueWithIdentifier("unwindToMainPageFromHSNT", sender: sender)
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
        
        imageViews = [UIImageView(image: UIImage(named: "head")), UIImageView(image: UIImage(named: "shoulder")), UIImageView(image: UIImage(named: "knee")), UIImageView(image: UIImage(named: "toe"))]
        
        for i in 0..<4 {
            imageViews[i].tag = i + 1
        }
        
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
        
        addPalette(spacingToTop, frame: frame)
        
        let widthOfPuzzle = (frame.width - 50)/15 * 1.2
        let spacingBtwPieces = (frame.height - spacingToTop - 20 - 5 * widthOfPuzzle) / 6
        let widthOfPositionView = widthOfPuzzle / 2
        let originXOfPositionView = 25 + 7.25 * widthOfPuzzle / 1.2
        var originYOfPositionView = spacingToTop + spacingBtwPieces + 0.25 * widthOfPuzzle
        
        while (originYOfPositionView < frame.height) {
            let newPos = UIView()
            newPos.frame = CGRectMake(originXOfPositionView, originYOfPositionView, widthOfPositionView, widthOfPositionView * 1.2)
            self.view.addSubview(newPos)
            positionViews.append(newPos)
            filledValues.append(0)
            originYOfPositionView += widthOfPuzzle
        }
        addDefaultPieces(frame)
        addArrowPositions()
        print(paletteTag)
    }
    
    func addPalette(spacingToTop: CGFloat, frame : CGRect) {

        imageViews = imageViews.shuffle()
        
        for i in 0..<4 {
            paletteTag.append(imageViews[i].tag)
            imageViews[i].tag = i + 1
            images.append(imageViews[i].image!)
            imageViews[i].userInteractionEnabled = true
            unusedNumbers.append(imageViews[i])
        }
        
        
        let widthOfPuzzle = (frame.width - 50)/15 * 1.2
        let spacingBtwPieces = (frame.height - spacingToTop - 20 - 4 * widthOfPuzzle) / 5
        
        let originX = 20 + 1.9 * widthOfPuzzle / 1.2
        var originY = spacingToTop + spacingBtwPieces
        
        
        for i in 0..<4 {
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
        
        view3 = UIView(frame: CGRect(x: 30 + 2 * view1!.frame.width, y: spacingToTop, width: view1!.frame.width, height: view1!.frame.height))
        view3!.backgroundColor = color
        view3!.layer.cornerRadius = spacingToTop/4
        view3!.clipsToBounds = true
        
        personImage.frame = view3!.frame
        personImage.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.view.addSubview(view1!)
        self.view.addSubview(view2!)
        self.view.addSubview(view3!)
        self.view.addSubview(personImage)
    }
    
    func addArrowPositions() {
        let imageFrame = personImage.frame
        let widthUnit = imageFrame.width / 500
        let heightUnit = imageFrame.height / 800
        
        let frame1 = CGRectMake(imageFrame.origin.x + 415 * widthUnit, imageFrame.origin.y + 150 * heightUnit, 80 * widthUnit, 50 * heightUnit)
        let frame2 = CGRectMake(imageFrame.origin.x + 415 * widthUnit, imageFrame.origin.y + 275 * heightUnit, 80 * widthUnit, 50 * heightUnit)
        let frame3 = CGRectMake(imageFrame.origin.x + 370 * widthUnit, imageFrame.origin.y + 550 * heightUnit, 80 * widthUnit, 50 * heightUnit)
        let frame4 = CGRectMake(imageFrame.origin.x + 370 * widthUnit, imageFrame.origin.y + 690 * heightUnit, 80 * widthUnit, 50 * heightUnit)
        arrowFrames = [frame1, frame2, frame3, frame4]
    }
    
    func addDefaultPieces(frame: CGRect) {
        let widthOfPuzzle = view2!.frame.width/5 * 1.2
        
        let dottedImageView = UIImageView(image: UIImage(named: "dotted"))
        dottedImageView.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        dottedImageView.center = positionViews[0].center
        dottedImageView.userInteractionEnabled = false
        
        given1 = UIImageView(image: UIImage(named: "head"))
        given1!.tag = paletteTag.indexOf(1)! + 1
        given1!.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        given1!.center = positionViews[0].center
        given1!.userInteractionEnabled = true
        addPanAndTapGestureRecognizer(given1!)
        
        self.view.addSubview(dottedImageView)
        self.view.addSubview(given1!)
        
        usedNumbers = [given1!]
        filledViews = [given1!]
        filledPosition = 1
        filledValues[0] = given1!.tag
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
    
//    func playSequentEffect(timer: NSTimer) {
//        print(currIter)
//        playIndividualEffect(filledViews[currIter])
//        let imageView = UIImageView(image: arrowImage)
//        imageView.frame = self.arrowFrames[self.paletteTag[self.filledValues[self.currIter] - 1] - 1]
//        imageView.alpha = 1
//        self.view.addSubview(imageView)
//        UIView.animateWithDuration(1.5, delay: 0, options: .CurveEaseIn, animations: {
//            imageView.alpha = 0
//            }, completion: {finished in
//                UIView.animateWithDuration(0, animations: {
//                    imageView.removeFromSuperview()
//                })
//        })
//
//            
//        currIter = currIter + 1
//        if (currIter == filledViews.count) {
//            timer.invalidate()
//            if(checkWin()) {
//                print("win")
//                NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "playSong:", userInfo: nil, repeats: false)
//            }
//        }
//    }
    
    
    func playSequentEffect(index: Int) {
        if (index == self.filledViews.count) {
            return
        }
        playIndividualEffect(filledViews[index])
        let imageView = UIImageView(image: arrowImage)
        imageView.frame = self.arrowFrames[self.paletteTag[self.filledValues[index] - 1] - 1]
        imageView.alpha = 1
        self.view.addSubview(imageView)
        UIView.animateWithDuration(seconds[self.paletteTag[self.filledValues[index] - 1] - 1], delay: 0, options: .CurveEaseIn, animations: {
            imageView.alpha = 0
            }, completion: {finished in
                UIView.animateWithDuration(0, animations: {
                    imageView.removeFromSuperview()
                    }, completion: {
                        finished in self.playSequentEffect(index + 1)
                })
            })
        if (index == self.filledViews.count  - 1 && checkWin()) {
            print("win")
            NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "playSong:", userInfo: nil, repeats: false)
        }
    }
    
    func playSongParts() {
        
    }


//        if (index == filledViews.count) {
//            if(checkWin()) {
//                print("win")
//                NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: "playSong:", userInfo: nil, repeats: false)
//            }
//        }
//        else {
//            playSequentEffect(index + 1)
//        }
//    }
    
    func playSong(timer: NSTimer) {
        soundManager.playSong()
    }
    
    func playIndividualEffect(view: UIView) {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.25, delay: 0, options: [], animations: {
                view.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.soundManager.playBody(self.paletteTag[view.tag - 1])
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
        if (filledPosition < 4) {
            pieceToMove = unusedNumbers[paletteTag.indexOf(filledPosition + 1)!]
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
                        pieceToMove!.frame = self.frames[pieceToMove!.tag - 1]
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

    }
    
    
    func play() {
        for value in filledViews {
            print("tag\(value.tag)")
        }

        disableButtons(1 * Double(filledPosition))
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        currIter = 0
        if (filledPosition > 0) {
//            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "playSequentEffect:", userInfo: nil, repeats: true)
            playSequentEffect(0)
        }
    }
    
    func checkWin() -> Bool {
        if (filledPosition == 6){
            for i in 0..<4 {
                if (filledValues[i] != paletteTag[i]) {
                    return false
                }
            }
            for i in 4..<6 {
                if (filledValues[i] != paletteTag[i - 2]) {
                    return false
                }
            }
            return true
        }
        return false
    }

    func recalculate() {

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

extension HSNTViewController: UIGestureRecognizerDelegate {
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


// http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
