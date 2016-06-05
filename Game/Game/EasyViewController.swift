//
//  EasyViewController.swift
//  Wee Coders
//
//  Created by Chuanxi Xiong on 4/5/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import UIKit
import AVFoundation

/// This is the view controller for the Count Down to One game. All the elements in this view were added programatically instead of in the interface builder. Only the unwind segue is added in the interface builder.
class EasyViewController: UIViewController {
    
    // MARK: Properties
    var filledPosition = 0    // The number of pieces that already put into the script.
    var positionViews = [UIView]()   // The array of views that are half of the length and width of the puzzle pieces. They mark the locations that the pieces should snap into.
    var filledViews = [UIView]()   // The array of views that are the puzzle pieces already in the script.
    var filledValues = [Int]()     // The array of integers that are the value of on the puzzle pieces put in the script.
    
    // These are the UIImageViews of the number images, the hand for hint and the rocket.
    let image3 = UIImageView(image: UIImage(named: "three"))
    let image2 = UIImageView(image: UIImage(named: "two"))
    let image1 = UIImageView(image: UIImage(named: "one"))
    let image4 = UIImageView(image: UIImage(named: "four"))
    let image5 = UIImageView(image: UIImage(named: "five"))
    let helpingHand = UIImageView(image: UIImage(named: "hand"))
    let rocket = UIImageView(image: UIImage(named: "rocket"))
    var images = [UIImage]()    // The array of images in image1, image2 and image3
    
    // These are the frames of pieces in the block palette area, to be set up in the viewDidLoad method. These will be used for putting pieces back to the original places.
    var frame3: CGRect?
    var frame2: CGRect?
    var frame1: CGRect?
    var frames = [CGRect]()   // The array of CGRects that are the frames of the blocks.
    
    var currIter = 0    // This is a global variable that mark the block in the script to be animated next when the play button is hit.

    let soundManager = SoundManager.sharedInstance   // This is an instance of the Singleton class SoundManager.
    var view2: UIView?   // The rounded rectangle in the middle, the scripts area.
    var view1: UIView?   // The rounded rectangle on the left, the block palette area.
    var usedNumbers = [UIView]()   // The array of the UIViews of the number blocks that are left in the second, scripts area.
    var buttons = [UIButton]()   // The array of all the buttons, the back button, help button, play button, and redo button.
    var unusedNumbers = [UIView]()   // The array of the UIViews of the numbers in the block palette area.
    var playButtonFrame: CGRect?   // The frame of the play button. It's used for locating the hand when giving hint.
    
    // MARK: Segue
    /// The segue function of the back button. The unwind segue to "Exit" with the identifier "unwindToMainPage" is added in the interface builder.
    /// - Parameters:
    ///     - sender: The UIButton to trigger the unwind segue
    @IBAction func buttonSegue(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        performSegueWithIdentifier("unwindToMainPage", sender: sender)
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the dark grey background
        self.view.backgroundColor = UIColor(white: 0.25, alpha: 1)

        let frame = self.view.frame  // the size of view on the screen
        var spacingToTop = frame.height/10  // The space from the top of the gray rectangles to the top will set to be 1/10 of the height on all devices
        
        // If the spacing is too small, it will be set to 38. This will only be adjusted for iPhone 4s, in case the buttons will be too small.
        if (spacingToTop < 38) {
            spacingToTop = CGFloat(38)
        }
        
        // Add three gray rectangle areas to the view, whose sizes will be proportional to the screen size.
        addThreeViews(spacingToTop, frame: frame)
        
        // Set up the buttons, whose sizes will be proportional to the screen size.
        addBackButton(spacingToTop)
        addPlayButton(spacingToTop)
        addRedoButton(spacingToTop)
        addHelpButton(spacingToTop)

        // This is the width of the puzzle piece. It will be 1/5 of the width of the three rounded-corner rectangle.
        let widthOfPuzzle = (frame.width - 50)/15
        
        // The portion of the puzzle piece is 1 : 1.1, the height will be 1.1 times of the width. 0.1 is portion of the bumped up part at the lower left. These lines set up the puzzle pieces in the block palette. Each piece is 2 times of the width of a puzzle piece below another. 20 is the spacing between the left border of the light first grey rectangle to the border of the screen. This way the images will be in the middle of the rectangle. frame1, frame2, frame3 will also be set up.
        image2.frame = CGRectMake(20 + 2 * widthOfPuzzle, spacingToTop + widthOfPuzzle/2 , widthOfPuzzle, widthOfPuzzle * 1.1)
        frame2 = image2.frame
        image2.tag = 2   // The tag is the value associated with the piece.
        image2.userInteractionEnabled = true
        image3.frame = CGRectMake(20 + 2 * widthOfPuzzle, spacingToTop + widthOfPuzzle * 2 , widthOfPuzzle, widthOfPuzzle * 1.1)
        frame3 = image3.frame
        image3.tag = 3
        image3.userInteractionEnabled = true
        image1.frame = CGRectMake(20 + 2 * widthOfPuzzle, spacingToTop + widthOfPuzzle * 3.5 , widthOfPuzzle, widthOfPuzzle * 1.1)
        frame1 = image1.frame
        image1.tag = 1
        image1.userInteractionEnabled = true
        
        // frames will be the array consists of frame1, frame2, and frame3
        frames = [frame1!, frame2!, frame3!]
        // images will be the array consists of images in image1, image2, and image3
        images = [image1.image!, image2.image!, image3.image!]
        // unusedNumber (UIImageViews in the block palette) will be the UIImageViews, image1, image2, and image3
        unusedNumbers = [image1, image2, image3]
        
        // Add image1, image2, image3 to the base view
        self.view.addSubview(image1)
        self.view.addSubview(image2)
        self.view.addSubview(image3)
        
        // Add pan and tap gesture reconginzers to all the UIImageViews
        addPanAndTapGestureRecognizer(image1)
        addPanAndTapGestureRecognizer(image2)
        addPanAndTapGestureRecognizer(image3)

        // The width of the position views will be half of that of width of a puzzle piece
        let widthOfPositionView = widthOfPuzzle / 2
        
        // Set up the origin of the first available location.
        // 20 is the distance from the first rectangle to the border of the screen. 5 is the distance between rectangles. 5 * widthOfPuzzle is the width of the rectangle. 20 + 5 * widthOfPuzzle + 2.25 * widthOfPuzzle will make the position views vertically in the middle of the middle rectangle.
        let originXOfPositionView = 25 + 7.25 * widthOfPuzzle
        
        // The first given puzzle piece is spacingToTop + 0.5 * widthOfPuzzle from the screen border. spacingToTop + 2.75 * widthOfPuzzle will make the puzzle piece fit to the next place. The next puzzle piece should be 2.5 * widthOfPuzzle from the left border of the light gray rectangle, so the positionView is spacingToTop + 2.75 * widthOfPuzzle from the top.
        var originYOfPositionView = spacingToTop + 2.75 * widthOfPuzzle

        // Programatically add all the position views until the bottom of the view, and append all of them into the positionViews array. Each will be widthOfPuzzle down the previous one. There will be same number of zeros in the filledValues and positionViews.
        while (originYOfPositionView < frame.height) {
            let newPos = UIView()
            newPos.frame = CGRectMake(originXOfPositionView, originYOfPositionView, widthOfPositionView, widthOfPositionView * 1.1)
            self.view.addSubview(newPos)
            positionViews.append(newPos)
            filledValues.append(0)
            originYOfPositionView += widthOfPuzzle
        }
        
        // Play the audio instruction to the game
        sayInstruction()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIView Set up
    
    /// This method set up three light gray rectangle with rounded corners. The distance from the rectangles to the border of the screen is 20. And the distance between the rectangles is 5.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    ///     - frame: The frame the base view, the same width and height as the screen.
    func addThreeViews(spacingToTop: CGFloat, frame : CGRect) {
        
        // The color of all the rectangles white with an alpha value of 0.9, which will look light gray.
        let color = UIColor(white: 1, alpha: 0.9)
        
        // The first view will be 20 from the left border of the screen, spacingToTop from the top, and 20 from the bottom, with a rounded corner of a spacingToTop / 4 radius.
        view1 = UIView(frame: CGRect(x: 20, y: spacingToTop, width: (frame.width - 50)/3, height: frame.height - 20 - spacingToTop))
        view1!.backgroundColor = color
        view1!.layer.cornerRadius = spacingToTop/4

        // The second view will be 5 from the left view, spacingToTop from the top, and 20 from the bottom, with a rounded corner of spacingToTop / 4 radius.
        view2 = UIView(frame: CGRect(x: 25 + view1!.frame.width, y: spacingToTop, width: view1!.frame.width, height: view1!.frame.height))
        view2!.backgroundColor = color
        view2!.layer.cornerRadius = spacingToTop/4
        
        // The third view will be 5 from the middle view, spacingToTop from the top, and 20 from the bottom, with a rounded corner of spacingToTop / 4 radius.
        let view3 = UIView(frame: CGRect(x: 30 + 2 * view1!.frame.width, y: spacingToTop, width: view1!.frame.width, height: view1!.frame.height))
        view3.backgroundColor = color
        view3.frame = CGRectMake(30 + 2 * view1!.frame.width, spacingToTop, view1!.frame.width, view1!.frame.height)
        view3.layer.cornerRadius = spacingToTop/4
        
        // Add the given pieces of number 5 and number 4, with tags of the corresponding values. They are the same size as number 1, 2, and 3. Number 5 will be widthOfPuzzle from the top of the rectangle view. 5 and 4 can only be tapped instead of panned.
        let widthOfPuzzle = view2!.frame.width/5
        image5.tag = 5
        image5.frame = CGRectMake(view2!.frame.origin.x + 2 * widthOfPuzzle, view2!.frame.origin.y + widthOfPuzzle/2 , widthOfPuzzle, widthOfPuzzle * 1.1)
        image5.userInteractionEnabled = true
        addTapGestureRecognizer(image5)
        
        // Number 4 will be widthOfPuzzle down to Number 5.
        image4.tag = 4
        image4.frame = CGRectMake(view2!.frame.origin.x + 2 * widthOfPuzzle, image5.frame.origin.y + widthOfPuzzle , widthOfPuzzle, widthOfPuzzle * 1.1)
        image4.userInteractionEnabled = true
        addTapGestureRecognizer(image4)
        
        filledViews = [image5, image4]  // image5 and image4 will be added to the filledViews.

        // Set up the size and position of the rocket image.
        let widthOfRocket = view2!.frame.width/3
        rocket.frame = CGRectMake(view3.frame.origin.x + widthOfRocket, frame.height - 2.5 * widthOfRocket, widthOfRocket, 2 * widthOfRocket)

        // All the previous elements will be added to the base view.
        self.view.addSubview(view1!)
        self.view.addSubview(view2!)
        self.view.addSubview(view3)
        self.view.addSubview(image5)
        self.view.addSubview(image4)
        self.view.addSubview(rocket)
        
    }
    
    // MARK: UIButton Set up
    /// This method sets up the back button. The height and width will both be spacingToTop * 3 / 4. It will be horizontally placed in the space between and 20 from the left border of the screen. When pressed, it will segue to the first view.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    func addBackButton(spacingToTop : CGFloat) {
        let backButton = UIButton(frame: CGRect(x: 20, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        backButton.setImage(UIImage(named: "backButton"), forState: .Normal)
        backButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        backButton.addTarget(self, action: #selector(EasyViewController.buttonSegue(_:)), forControlEvents: .TouchUpInside)
        buttons.append(backButton)
        self.view.addSubview(backButton)
    }
    
    /// This method sets up the play button. The height and width will both be spacingToTop * 3 / 4. It will be horizontally placed in the space between the border of the rectangle and the border, and 20 from the left border of the screen. When pressed, checkWin method will be called.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    func addPlayButton(spacingToTop : CGFloat) {
        let playButton = UIButton(frame: CGRect(x: self.view.frame.width - 20 - spacingToTop * 3 / 4, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        playButtonFrame = playButton.frame
        playButton.setImage(UIImage(named: "playButton"), forState: .Normal)
        playButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        playButton.addTarget(self, action: #selector(EasyViewController.checkWin), forControlEvents: .TouchUpInside)
        buttons.append(playButton)
        self.view.addSubview(playButton)
    }
    
    /// This method sets up the redo button. The height and width will both be spacingToTop * 3 / 4. It will be horizontally placed in the space between the border of the rectangle and the border. It is 5 / 4 * spacingToTop to the left of the play button, reset method will be called.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    func addRedoButton(spacingToTop : CGFloat) {
        let redoButton = UIButton(frame: CGRect(x: self.view.frame.width - 20 - spacingToTop * 2, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        redoButton.setImage(UIImage(named: "redoButton"), forState: .Normal)
        redoButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        redoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        redoButton.addTarget(self, action: #selector(EasyViewController.reset), forControlEvents: .TouchUpInside)
        buttons.append(redoButton)
        self.view.addSubview(redoButton)
    }
    
    /// This method sets up the help button. The height and width will both be spacingToTop * 3 / 4. It will be horizontally placed in the space between the border of the rectangle and the border. It is 5 / 4 * spacingToTop to the left of the redo button, help method will be called.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    func addHelpButton(spacingToTop : CGFloat) {
        let helpButton = UIButton(frame: CGRect(x: self.view.frame.width - 20 - spacingToTop * 13 / 4, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        helpButton.setImage(UIImage(named: "questionButton"), forState: .Normal)
        helpButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        helpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        helpButton.addTarget(self, action: #selector(EasyViewController.help), forControlEvents: .TouchUpInside)
        buttons.append(helpButton)
        self.view.addSubview(helpButton)
    }
    

    /// This method enables user interaction for all the buttons.
    /// - Attributions: http://stackoverflow.com/questions/26755014/disable-a-button-for-90-sec-when-pressed-in-swift
    func enableButtons() {
        for button in buttons {
            button.enabled = true
        }
    }
    
    /// This method disables user interaction for all the buttons. If this method is called, all the buttons will be disabled for a given timer interval and then become back to enbaled.
    /// - Parameters:
    ///     - seconds: The time interval that the buttons will be disabled.
    func disableButtons(seconds: NSTimeInterval) {
        for button in buttons {
            button.enabled = false
        }
        NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: #selector(EasyViewController.enableButtons), userInfo: nil, repeats: false)
    }
    
    // MARK: Gesture Recognizer
    /// This method is to add both pan gesture recognizer and tap gesture to the UIImageView.
    /// - Parameters:
    ///     - view: The UIImageView to add the gesture recognizers.
    func addPanAndTapGestureRecognizer(view: UIImageView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(EasyViewController.handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        addTapGestureRecognizer(view)
    }
    
    /// This method is to add tap gesture recognizer to the UIImageView. When the view is tapped, handleTap method will be called.
    /// - Parameters:
    ///     - view: The UIImageView to add the gesture recognizers.
    func addTapGestureRecognizer(view: UIImageView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EasyViewController.handleTap(_:)))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    /// This method will move the view to the point of touch if it is panned. It will also update the arrays of views and values accordingly.
    /// - Parameters:
    ///     - recognizer: The pan gesture recognizers that triggered the action.
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        // move the view to the point of touch
        let translation = recognizer.translationInView(self.view)
        if let view = recognizer.view {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        // update the filled Position if a puzzle put in the script is moved, so that it can still snap to the original place
        if recognizer.state == .Began {
            if (filledViews.contains(recognizer.view!)) {
                filledPosition = filledViews.indexOf(recognizer.view!)! - 2
            }
        }
        
        // update the arrays of views and values when a pan gesture ended
        if recognizer.state == .Ended {

            // if the view panned intersects with the next availabe positionView, a new image view will be generated and snap into place. The panned one will be put back
            if CGRectIntersectsRect(recognizer.view!.frame, positionViews[filledPosition].frame) {
                // the tag of the view is the value shown on the view
                let tag = recognizer.view!.tag
                // put that value into the filledValues array
                filledValues[filledPosition] = tag
                
                // create a new image view with the number the same as the tag, and put into the next place.
                let newImageView = UIImageView(image: images[tag - 1])
                newImageView.tag = tag
                newImageView.frame = recognizer.view!.frame
                newImageView.center = positionViews[filledPosition].center
                newImageView.userInteractionEnabled = true
                self.view.addSubview(newImageView)
                addPanAndTapGestureRecognizer(newImageView)
                
                // add the new image view to the used numbers and the filledViews array
                usedNumbers.append(newImageView)
                filledViews.append(newImageView)
                
                // if the panned view is in the usedNumbers array, delete it from the array
                if (usedNumbers.contains(recognizer.view!)) {
                    usedNumbers.removeAtIndex(usedNumbers.indexOf(recognizer.view!)!)
                }
                
                // put the original one back, if there was already a piece in the block palette, remove the piece there
                recognizer.view!.frame = frames[tag - 1]
                unusedNumbers[tag - 1].removeFromSuperview()
                unusedNumbers[tag - 1] = recognizer.view!
                self.view.addSubview(unusedNumbers[tag - 1])
                
                // increament the filledPosition
                filledPosition += 1
                
                // play the snapping sound effect
                dispatch_async(dispatch_get_main_queue()) {
                    self.soundManager.playSnap()
                }
                // update the arrays of views and values when a pan gesture ended
                recalculate()
            }
                
            // if the panned view is within the second view but doesn't intersect with the next positionView
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
                
                // if the panned view is in the usedNumbers array, delete it from the array
                if (usedNumbers.contains(recognizer.view!)) {
                    usedNumbers.removeAtIndex(usedNumbers.indexOf(recognizer.view!)!)
                }
                
                // if there was already a piece in the block palette, remove the piece there
                unusedNumbers[tag - 1].removeFromSuperview()
                unusedNumbers[tag - 1] = recognizer.view!
                self.view.addSubview(unusedNumbers[tag - 1])
                
                // update the arrays of views and values when a pan gesture ended
                recalculate()
            }
                
            // if it is not in the second area
            else {

                // the tag of the view is the value shown on the view
                let tag = recognizer.view!.tag
                
                // if the panned view is in the usedNumbers array, delete it from the array
                if (usedNumbers.contains(recognizer.view!)) {
                    usedNumbers.removeAtIndex(usedNumbers.indexOf(recognizer.view!)!)
                }
                
                // play the slide back effect, if the panned piece is not the same one in the block palette, delete the one in the palette.
                dispatch_async(dispatch_get_main_queue()) {
                    self.soundManager.playSlide()
                    if (recognizer.view! !== self.unusedNumbers[tag - 1]) {
                        self.unusedNumbers[tag - 1].removeFromSuperview()
                        self.unusedNumbers[tag - 1] = UIView()
                        self.unusedNumbers[tag - 1] = recognizer.view!
                    }
                }
                
                // animate the piece back to the block palette
                UIView.animateWithDuration(1, delay: 0, options: [], animations: {
                    recognizer.view!.frame = self.frames[tag - 1]
                    }, completion: nil)
                
                // update the arrays of views and values when a pan gesture ended
                recalculate()
            }
        }
    }
    
    /// This method will animate the puzzle block when tapped. It will call the playIndividualEffect method.
    /// - Parameters:
    ///     - recognizer: The pan gesture recognizers that triggered the action.
    func handleTap(recognizer: UITapGestureRecognizer) {
        playIndividualEffect(recognizer.view!)
    }
    
    // MARK: Game Logic
    
    /// This method will animate the puzzle block to grow in size of a factor of 1.2 and get back to normal. It will call out the number at the same time.
    /// - Parameters:
    ///     - view: The UIView to be animated.
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
    
    /// This method will animate all the puzzle blocks in the script. It will call the playIndividualEffect method of the views in the sequence one by one.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func playSequentEffect(timer: NSTimer) {
        playIndividualEffect(filledViews[currIter])
        currIter += 1
        if (currIter == filledViews.count) {
            timer.invalidate()
        }
    }
    
    /// This method calls the AVSpeechSynthesizer method to read out the string.
    func sayInstruction() {
        let string = "Drag the numbers from the left to the middle area to count down to one"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
    }
    
    /// This method will be called if the help button is hit. If there are fewer than three views put into the scripts area, a hand will show up, point to the next correct piece and be animated to the correct place. Otherwise, the hand will point to the play button.
    func help() {
        // disable all the buttons for 1 second in case the buttons are pressed to frequently that overburdens the app.
        disableButtons(1.0)
        
        // play the tap sound effect
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        var pieceToMove : UIView?  // The next correct piece to move

        // if there are fewer than three views put into the scripts area, move the next correct piece
        if (filledPosition < 3) {
            sayInstruction()   // say the instruction again
            pieceToMove = unusedNumbers[2 - filledPosition]
            pieceToMove?.alpha = 0.8
            helpingHand.alpha = 0.8
            helpingHand.frame = frames[2]   // the outbound of the hand will be the same as the puzzle pieces
            helpingHand.frame.origin.y = frame1!.height * 0.6   // the hand will point to the correspounding piece
            helpingHand.frame.origin.x = 0
            pieceToMove!.addSubview(helpingHand)
            self.view.addSubview(pieceToMove!)
            
            // animate the hand and the piece, put the piece back when it's done and remove the hand
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
            
        // if there are already at least five views in the scripts area, the hand will be animated to point to the play button
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
    
    /// This method will animate the pieces one by one. It also checks whether the user wins the game by checking the filledPosition and the values in the filledValues. The rocket will be animated as a result of a right or wrong sequence.
    func checkWin() {
        disableButtons(0.75 * Double(filledPosition + 4)) // for the duration of the animation, all the buttons will be disabled
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        currIter = 0
        NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: #selector(EasyViewController.playSequentEffect(_:)), userInfo: nil, repeats: true)
        
        // correct answer
        if filledPosition == 3 && filledValues[0] == 3 && filledValues[1] == 2 && filledValues[2] == 1 {
            NSTimer.scheduledTimerWithTimeInterval(0.75 * Double(filledPosition + 3), target: self, selector: #selector(EasyViewController.playWin(_:)), userInfo: nil, repeats: false)
            NSTimer.scheduledTimerWithTimeInterval(0.75 * Double(filledPosition + 4), target: self, selector: #selector(EasyViewController.animateRocket(_:)), userInfo: nil, repeats: false)
        }
        // wrong answer
        else {
            NSTimer.scheduledTimerWithTimeInterval(0.75 * Double(filledPosition + 3), target: self, selector: #selector(EasyViewController.playLose(_:)), userInfo: nil, repeats: false)
            NSTimer.scheduledTimerWithTimeInterval(0.75 * Double(filledPosition + 4), target: self, selector: #selector(EasyViewController.fallingRocket(_:)), userInfo: nil, repeats: false)

        }
    }
    
    /// This method reset the game interface to the starting point.
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
    
    /// This method to play the blast off audio.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func playWin(timer: NSTimer) {
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playBlastOff()
        }
    }
    
    /// This method to play the trombone audio.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func playLose(timer: NSTimer) {
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTrombone()
        }
    }
    
    /// This method animates the rocket to set off.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func animateRocket(timer: NSTimer) {
        let curr = self.rocket.frame
        UIView.animateWithDuration(2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            var ending = curr
            ending.origin.y = curr.origin.y - self.view.frame.height
            self.rocket.frame = ending
            }) {_ in
                self.rocket.frame = curr
        }
    }

    /// This method animates the rocket to fall off.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func fallingRocket(timer: NSTimer) {
        let frame = self.rocket.frame
        let origin = frame.origin
        var newOrigin = origin
        newOrigin.x = origin.x - frame.width / 2
        newOrigin.y = origin.y + frame.height - frame.width
        
        // animate the rocket to fall 90 degree and shift left
        UIView.animateWithDuration(3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.rocket.frame = frame
            let rotate = CGAffineTransformMakeRotation(90.0 * CGFloat(M_PI) / 180.0);
            self.rocket.transform = rotate
            self.rocket.frame.origin = newOrigin
            }) {_ in UIView.animateWithDuration(0, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.rocket.transform = CGAffineTransformMakeRotation((0 * CGFloat(M_PI))/180.0)
                self.rocket.frame.origin = origin
                }, completion: { (finised: Bool) -> Void in
            })
        }
    }

    /// The method to update the filledViews and filledValues arrays.
    func recalculate() {
        // reset filledViews and filledValues arrays
        filledViews = [image5, image4]
        filledValues = Array(count: filledValues.count, repeatedValue: 0)
        filledPosition = 0
        
        // if the view in usedNumbers intersects with each positionView, put it into the filledViews and update the filledValue with the tag of the view
        for index in 0..<self.positionViews.count {
            var flag = false
            for view in self.usedNumbers {
                if (CGRectIntersectsRect(self.positionViews[index].frame, view.frame)) {
                    flag = true
                    filledPosition = index + 1
                    filledViews.append(view)
                    filledViews[index + 2] = view
                    filledValues[index] = view.tag
                }
            }
            if (flag == false) {
                break
            }
        }
        
        // if there is any missing piece in the array, remove the rest after the missing one
        if (filledPosition < filledViews.count - 2) {
            filledViews.removeRange(filledPosition+2..<filledViews.count)
        }
        if (filledPosition < filledValues.count) {
            for index in filledPosition+1..<filledValues.count {
                filledValues[index] = 0
            }
        }
    }
}

/// To extend the UIGestureRecognizerDelegate that a gesture recongizer won't happen simultenously with another. The gesture recognizer should receive the touch on its descendant of the view.
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

