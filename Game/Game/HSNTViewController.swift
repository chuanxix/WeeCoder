//
//  HSNTViewController.swift
//  Wee Coders
//
//  Created by Chuanxi Xiong on 5/24/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import UIKit
import AVFoundation

/// This is the view controller for the Head, Shoulders, Knees and Toes game. All the elements in this view were added programatically instead of in the interface builder. Only the unwind segue is added in the interface builder.
class HSNTViewController: UIViewController {
    
    // MARK: Properties
    var filledPosition = 0    // The number of pieces that already put into the script.
    var positionViews = [UIView]()   // The array of views that are half of the length and width of the puzzle pieces. They mark the locations that the pieces should snap into.
    var filledViews = [UIView]()   // The array of views that are the puzzle pieces already in the script.
    var filledValues = [Int]()     // The array of integers that are the value of on the puzzle pieces put in the script.
    
    // These are the UIImageViews of the hand for hint, the person figure and the arrow.
    let helpingHand = UIImageView(image: UIImage(named: "hand"))
    let personImage = UIImageView(image: UIImage(named: "person"))
    let arrowImage = UIImage(named: "arrow")
    var given1: UIImageView?   // The UIImageView of the given default piece
    var imageViews = [UIImageView]()  // The array of UIImageViews of head, shoulders, knees and toes
    var arcViews = [UIImageView]()   // The array of UIImageViews of the layers of the rainbow
    var images = [UIImage]()  // The array of UIImages of head, shoulders, knees and toes
    
    var frames = [CGRect]()  // The array of the frames of the puzzle blocks in the block palette
    var arrowFrames = [CGRect]()  // The array of the frames of the four possible locations of the arrow pointing to different part of the person figure
    var paletteTag = [Int]()   // The tags of the shuffled UIImageViews
    let seconds = [1.3, 1.2, 0.7, 0.7, 0.7, 0.7]    // The length of the sound clips for different parts
    let secondsForSong = [1.2, 1.2, 0.6, 0.6, 0.8, 1.2, 1.4, 1, 0.7, 0.8, 0.7, 7.1, 1.4, 1, 0.6, 0.6, 0.9, 0.8]     // The length of the sound clip in the whole song where each of the part start
    
    var currIter = 0    // This is a global variable that mark the block in the script to be animated next when the play button is hit.
    let soundManager = SoundManager.sharedInstance   // This is an instance of the Singleton class SoundManager.
    var view2: UIView?   // The rounded rectangle in the middle, the scripts area.
    var view1: UIView?   // The rounded rectangle on the left, the block palette area.
    var view3: UIView?   // The rounded rectangle on the right, the animation area.
    var usedNumbers = [UIView]()   // The array of the UIViews of the number blocks that are left in the second, scripts area.
    var buttons = [UIButton]()   // The array of all the buttons, the back button, help button, play button, and redo button.
    var unusedNumbers = [UIView]()   // The array of the UIViews of the numbers in the block palette area.
    var playButtonFrame: CGRect?   // The frame of the play button. It's used for locating the hand when giving hint.

    // MARK: Segue
    /// The segue function of the back button. The unwind segue to "Exit" with the identifier "unwindToMainPageFromHSNT" is added in the interface builder.
    /// - Parameters:
    ///     - sender: The UIButton to trigger the unwind segue.
    @IBAction func buttonSegue(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        performSegueWithIdentifier("unwindToMainPageFromHSNT", sender: sender)
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The array of UIImageViews of all the body parts
        imageViews = [UIImageView(image: UIImage(named: "head")), UIImageView(image: UIImage(named: "shoulder")), UIImageView(image: UIImage(named: "knee")), UIImageView(image: UIImage(named: "toe"))]
        
        // Assign the value of the tag to the imageViews. Head is 1, shoulders is 2, knees is 3 and toes is 4.
        for i in 0..<4 {
            imageViews[i].tag = i + 1
        }
        
        // Set up the dark grey background
        self.view.backgroundColor = UIColor(white: 0.25, alpha: 1)
        let frame = self.view.frame // the size of view on the screen
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
        
        // add the blocks to the base view
        addPalette(spacingToTop, frame: frame)
        
        // This is the width of the puzzle piece. The width and height will be 1.2 times of that in other levels, otherwise the images in the pieces look small
        let widthOfPuzzle = (frame.width - 50)/15 * 1.2
        
        // The width of the position views will be half of that of width of a puzzle piece
        let widthOfPositionView = widthOfPuzzle / 2
        
        // Set up the origin of the first available location.
        // Put the location pieces horizontally in the middle the second view. Put the center of the first piece the same height as the first piece in the block palette.Lo
        let spacingBtwPieces = (frame.height - spacingToTop - 20 - 5 * widthOfPuzzle) / 6
        let originXOfPositionView = 25 + 7.25 * widthOfPuzzle / 1.2
        var originYOfPositionView = spacingToTop + spacingBtwPieces + 0.25 * widthOfPuzzle
        
        // Programatically add all the position views until the bottom of the view, and append all of them into the positionViews array. Each will be widthOfPuzzle down the previous one. There will be same number of zeros in the filledValues and positionViews.
        while (originYOfPositionView < frame.height) {
            let newPos = UIView()
            newPos.frame = CGRectMake(originXOfPositionView, originYOfPositionView, widthOfPositionView, widthOfPositionView * 1.2)
            self.view.addSubview(newPos)
            positionViews.append(newPos)
            filledValues.append(0)
            originYOfPositionView += widthOfPuzzle
        }
        addDefaultPieces(frame)   // add the default pieces to the base view
        addArrowPositions()    // add the frames of the arrow to the base view
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
        view3 = UIView(frame: CGRect(x: 30 + 2 * view1!.frame.width, y: spacingToTop, width: view1!.frame.width, height: view1!.frame.height))
        view3!.backgroundColor = color
        view3!.layer.cornerRadius = spacingToTop/4
        view3!.clipsToBounds = true
        
        // add the person figure to the base view, in the same position as the third view
        personImage.frame = view3!.frame
        personImage.contentMode = UIViewContentMode.ScaleAspectFill
        
        // All the three views will be added to the base view.
        self.view.addSubview(view1!)
        self.view.addSubview(view2!)
        self.view.addSubview(view3!)
        self.view.addSubview(personImage)
    }
    

    /// This method adds the block palette to the left area.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    ///     - frame: The frame the base view, the same width and height as the screen.
    func addPalette(spacingToTop: CGFloat, frame : CGRect) {
        
        // shuffle the imageViews so that the sequence is random
        imageViews = imageViews.shuffle()
        
        // add the sequence of the tag values to paletteTag array (real value), reassign the tag (current position in the sequence), add the imageViews to unusedNumbers array and add the images to the images array
        for i in 0..<4 {
            paletteTag.append(imageViews[i].tag)
            imageViews[i].tag = i + 1
            images.append(imageViews[i].image!)
            imageViews[i].userInteractionEnabled = true
            unusedNumbers.append(imageViews[i])
        }
        
        // This is the width of the puzzle piece. The width and height will be 1.2 times of that in other levels, otherwise the images in the pieces look small
        let widthOfPuzzle = (frame.width - 50)/15 * 1.2
        // The pieces will be evenly distributed vertically
        let spacingBtwPieces = (frame.height - spacingToTop - 20 - 4 * widthOfPuzzle) / 5
        
        // put the pieces horizontally in the middle of the first block palette view
        let originX = 20 + 1.9 * widthOfPuzzle / 1.2
        var originY = spacingToTop + spacingBtwPieces
        
        // place the pieces onto the base view
        for i in 0..<4 {
            let newUIImageView = imageViews[i]
            newUIImageView.frame = CGRectMake(originX, originY, widthOfPuzzle, widthOfPuzzle * 1.1)
            originY += widthOfPuzzle + spacingBtwPieces
            self.view.addSubview(newUIImageView)
            frames.append(newUIImageView.frame)
            
        }
        
        // add pan gesture recognizers and tap gesture recognizers to all the imageViews
        for image in imageViews {
            addPanAndTapGestureRecognizer(image)
        }
    }
    
    /// This method adds the position locations of the arrows to the arrowFrames array, which would point the head, shoulders, knees and toes. The value was calculated using the figure image. The position and size of the arrow will be proportional to the dimension of the original personImage.
    func addArrowPositions() {
        
        // the ratio of the personImage is 5 : 8
        let imageFrame = personImage.frame
        let widthUnit = imageFrame.width / 500
        let heightUnit = imageFrame.height / 800
        
        let frame1 = CGRectMake(imageFrame.origin.x + 415 * widthUnit, imageFrame.origin.y + 150 * heightUnit, 80 * widthUnit, 50 * heightUnit)
        let frame2 = CGRectMake(imageFrame.origin.x + 415 * widthUnit, imageFrame.origin.y + 275 * heightUnit, 80 * widthUnit, 50 * heightUnit)
        let frame3 = CGRectMake(imageFrame.origin.x + 370 * widthUnit, imageFrame.origin.y + 550 * heightUnit, 80 * widthUnit, 50 * heightUnit)
        let frame4 = CGRectMake(imageFrame.origin.x + 370 * widthUnit, imageFrame.origin.y + 690 * heightUnit, 80 * widthUnit, 50 * heightUnit)
        
        // add the frames of the arrows to the array. The sequence will point to head, shoulders, knees, toes, knees and toes for easier reference when playing the song.
        arrowFrames = [frame1, frame2, frame3, frame4, frame3, frame4]
    }
    
    /// This method add the given default part to the view. They are going to be placed in the middle top part on the scripts area, centered at the first positionView.
    /// - Parameters:
    ///     - frame: The frame the base view, the same width and height as the screen.
    func addDefaultPieces(frame: CGRect) {
        let widthOfPuzzle = view2!.frame.width/5 * 1.2
        
        // the dotted outline of the position of the first puzzle block. It can't be moved and it's behind the other color pieces.        
        let dottedImageView = UIImageView(image: UIImage(named: "dotted"))
        dottedImageView.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        dottedImageView.center = positionViews[0].center
        dottedImageView.userInteractionEnabled = false
        
        // the first given part is the head
        given1 = UIImageView(image: UIImage(named: "head"))
        given1!.tag = paletteTag.indexOf(1)! + 1
        given1!.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        given1!.center = positionViews[0].center
        given1!.userInteractionEnabled = true
        addPanAndTapGestureRecognizer(given1!)
        
        // add the dotted outline and the given part are added to the base view
        self.view.addSubview(dottedImageView)
        self.view.addSubview(given1!)
        
        // set up the usedNumbers and filledViews array. set the filledPosition to be 1
        usedNumbers = [given1!]
        filledViews = [given1!]
        filledPosition = 1
        filledValues[0] = given1!.tag
    }
    
    // MARK: UIButton Set Up
    /// This method sets up the back button. The height and width will both be spacingToTop * 3 / 4. It will be horizontally placed in the space between and 20 from the left border of the screen. When pressed, it will segue to the first view.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    func addBackButton(spacingToTop : CGFloat) {
        let backButton = UIButton(frame: CGRect(x: 20, y: spacingToTop / 8, width: spacingToTop * 3 / 4, height: spacingToTop * 3 / 4))
        backButton.setImage(UIImage(named: "backButton"), forState: .Normal)
        backButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        backButton.addTarget(self, action: #selector(HSNTViewController.buttonSegue(_:)), forControlEvents: .TouchUpInside)
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
        playButton.addTarget(self, action: #selector(HSNTViewController.play), forControlEvents: .TouchUpInside)
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
        redoButton.addTarget(self, action: #selector(HSNTViewController.reset), forControlEvents: .TouchUpInside)
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
        helpButton.addTarget(self, action: #selector(HSNTViewController.help), forControlEvents: .TouchUpInside)
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
        NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: #selector(HSNTViewController.enableButtons), userInfo: nil, repeats: false)
    }

    
    // MARK: Gesture Recognizer
    /// This method is to add both pan gesture recognizer and tap gesture to the UIImageView.
    /// - Parameters:
    ///     - view: The UIImageView to add the gesture recognizers.
    func addPanAndTapGestureRecognizer(view: UIImageView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(HSNTViewController.handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        addTapGestureRecognizer(view)
    }
    
    /// This method is to add tap gesture recognizer to the UIImageView. When the view is tapped, handleTap method will be called.
    /// - Parameters:
    ///     - view: The UIImageView to add the gesture recognizers.
    func addTapGestureRecognizer(view: UIImageView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HSNTViewController.handleTap(_:)))
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
                filledPosition = filledViews.indexOf(recognizer.view!)!
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
                
                // the tag of the view is the value shown on the view
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
    
    /// This method will animate the puzzle block to grow in size of a factor of 1.2 and get back to normal. It will play the part of the song at the same time.
    /// - Parameters:
    ///     - view: The UIView to be animated.
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
    
    /// This method will animate all the puzzle blocks in the script. It will call the playIndividualEffect method of the views in the sequence one by one. At the same time, an arrow will appear and point to the corresponding part of the figure.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func playSequentEffect(index: Int) {
        
        // After all the pieces are animated, check if the sequence is correct. If so, play the whole song and animate the arrow to point to each part of the body.
        if (index >= self.filledViews.count) {
            if (checkWin()) {
                NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: #selector(HSNTViewController.playSong(_:)), userInfo: nil, repeats: false)
                NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: #selector(HSNTViewController.playSongParts(_:)), userInfo: nil, repeats: false)
                self.disableButtons(30)
            }
            return
        }
        
        // animate the block piece
        playIndividualEffect(filledViews[index])
        
        // point the arrow to the corresponding part of the figure
        let imageView = UIImageView(image: arrowImage)
        imageView.frame = self.arrowFrames[self.paletteTag[self.filledValues[index] - 1] - 1]
        imageView.alpha = 1
        self.view.addSubview(imageView)
    
        // take the arrow off the view when it's done, and start the next one
        UIView.animateWithDuration(seconds[self.paletteTag[self.filledValues[index] - 1] - 1], delay: 0, options: .CurveEaseIn, animations: {
            imageView.alpha = 0
            }, completion: {finished in
                UIView.animateWithDuration(0, animations: {
                    imageView.removeFromSuperview()
                    }, completion: {
                        finished in self.playSequentEffect(index + 1)
                })
            })
    }
    
    /// The method to place an arrow at each part of the body as sung in the song. This method will be called at the same time that the song is played.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func playSongParts(timer: NSTimer) {
        // place the arrow at the corresponding place
        let imageView = UIImageView(image: arrowImage)
        imageView.frame = self.arrowFrames[currIter % 6]
        imageView.alpha = 1
        self.view.addSubview(imageView)
        
        // after the some duration around the same as in the sound clip, remove the arrow
        UIView.animateWithDuration(seconds[currIter % 6], delay: 0, options: .CurveEaseIn, animations: {
            imageView.alpha = 0
            }, completion: {finished in
                UIView.animateWithDuration(0, animations: {
                    imageView.removeFromSuperview()})
        })
        
        // if it's not the last part, continue to the next, and increment the currIter
        if (currIter < secondsForSong.count - 1) {
            NSTimer.scheduledTimerWithTimeInterval(secondsForSong[currIter], target: self, selector: #selector(HSNTViewController.playSongParts(_:)), userInfo: nil, repeats: false)
            currIter = currIter + 1
        }
    }
    
    /// The method to play the whole song.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func playSong(timer: NSTimer) {
        soundManager.playSong()
    }

    /// This method calls the AVSpeechSynthesizer method to read out the string.
    func sayInstruction() {
        let string = "Drag the parts from the left to the middle area in the order as you sing in the song <Head, Shoulders, Knees and Toes>"
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
        helpingHand.alpha = 0.8
        helpingHand.frame = frames[2]   // the outbound of the hand will be the same as the puzzle pieces
        var pieceToMove : UIView?   // The next correct piece to move
        
        // if there are fewer than four views put into the scripts area, move the next correct piece to place
        if (filledPosition < 4) {
            sayInstruction()   // say the instruction again
            pieceToMove = unusedNumbers[paletteTag.indexOf(filledPosition + 1)!]  // paletteTag.indexOf(filledPosition + 1)! is the index of the next correct piece
            pieceToMove?.alpha = 0.8
            helpingHand.frame.origin.y = frames[0].height * 0.6   // the hand will point to the correspounding piece
            helpingHand.frame.origin.x = 0
            pieceToMove!.addSubview(helpingHand)
            self.view.addSubview(pieceToMove!)
            
            // animate the hand and the piece, put the piece back when it's done and remove the hand
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
            
        // if there are four or five views put into the scripts area, move the next correct piece to place
        else if (filledPosition < 6) {
            sayInstruction()   // say the instruction again
            pieceToMove = unusedNumbers[paletteTag.indexOf(filledPosition - 1)!]  // if there are four pieces in place, the next one is knees; if there are five pieces, the next one is toes.
            pieceToMove?.alpha = 0.8
            helpingHand.frame.origin.y = frames[0].height * 0.6   // the hand will point to the correspounding piece
            helpingHand.frame.origin.x = 0
            pieceToMove!.addSubview(helpingHand)
            self.view.addSubview(pieceToMove!)
            
            // animate the hand and the piece, put the piece back when it's done and remove the hand
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
            
        // if there are already at least six views in the scripts area, the hand will be animated to point to the play button
        else {
            helpingHand.center = CGPointMake((playButtonFrame?.midX)!, (playButtonFrame?.midY)!)
            helpingHand.center.y += frames[2].height/2
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
        unusedNumbers = imageViews
        addDefaultPieces(self.view.frame)
    }
    
    /// This method starts the animation of all the blocks in the script
    func play() {
        disableButtons(1 * Double(filledPosition)) // the duration of the animation
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        currIter = 0
        if (filledPosition > 0) {
            playSequentEffect(0)
        }
    }
    
    /// This method checks whether the sequence of blocks put in the script is Head, Shoulders, Knees, Toes, Knees and Toes.
    func checkWin() -> Bool {
        // can only be correct if the number of filledPosition is 6
        if (filledPosition == 6){
            // the first four pieces should be the same of the index of head, shoulders, knees and toes in the paletteTag array
            for i in 0..<4 {
                if (filledValues[i] != paletteTag.indexOf(i + 1)! + 1) {
                    return false
                }
            }
            // the fifth and sixth pieces should be the same of the index of knees and toes in the paletteTag array
            for i in 4..<6 {
                if (filledValues[i] != paletteTag.indexOf(i - 1)! + 1) {
                    return false
                }
            }
            return true
        }
        return false
    }

    /// The method to update the filledViews and filledValues arrays.
    func recalculate() {
        // reset filledViews and filledValues arrays
        filledValues = Array(count: filledValues.count, repeatedValue: 0)
        filledPosition = 0
        filledViews = [UIImageView]()
        
        // if the view in usedNumbers intersects with each positionView, put it into the filledViews and update the filledValue with the tag of the view
        for index in 0..<self.positionViews.count {
            var flag = false
            for view in self.usedNumbers {
                if (CGRectIntersectsRect(self.positionViews[index].frame, view.frame)) {
                    flag = true
                    filledPosition = index + 1
                    filledViews.append(view)
                    filledViews[index] = view
                    filledValues[index] = view.tag
                }
            }
            if (flag == false) {
                break
            }
        }
        
        // if there is any missing piece in the array, remove the rest after the missing one
        if (filledPosition < filledViews.count) {
            filledViews.removeRange(filledPosition..<filledViews.count)
        }
        
        if (filledPosition < filledValues.count) {
            for index in filledPosition+1..<filledValues.count {
                filledValues[index] = 0
            }
        }        
    }
}

/// To extend the UIGestureRecognizerDelegate that a gesture recongizer won't happen simultenously with another. The gesture recognizer should receive the touch on its descendant of the view.
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

/// To extend the array that we can randomly shuffle it.
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
