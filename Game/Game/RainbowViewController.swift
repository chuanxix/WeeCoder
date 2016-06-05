//
//  RainbowViewController.swift
//  Wee Coders
//
//  Created by Chuanxi Xiong on 5/4/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import UIKit
import AVFoundation

/// This is the view controller for the Draw a Rainbow game. All the elements in this view were added programatically instead of in the interface builder. Only the unwind segue is added in the interface builder.
class RainbowViewController: UIViewController {
    
    // MARK: Properties
    var filledPosition = 0    // The number of pieces that already put into the script.
    var positionViews = [UIView]()   // The array of views that are half of the length and width of the puzzle pieces. They mark the locations that the pieces should snap into.
    var filledViews = [UIView]()   // The array of views that are the puzzle pieces already in the script.
    var filledValues = [Int]()    // The array of integers that are the value of on the puzzle pieces put in the script.

    var imageViews = [UIImageView]()    // The array of all the color blocks
    var arcViews = [UIImageView]()    // The array of all the layers in the rainbow
    var given1: UIImageView?      // The first default color block
    var given2: UIImageView?      // The second default color block

    var colors = [UIColor]()    // The array of the colors of the blocks
    var colorStrings = [String]()    // The array of Strings that are the names of the colors
    
    // The UIImageViews of the hand and the sheep
    let helpingHand = UIImageView(image: UIImage(named: "hand"))
    let sheepView = UIImageView(image: UIImage(named: "sheep"))
    var frames = [CGRect]()   // This is an array of frames of pieces in the block palette area, to be set up in the viewDidLoad method. These will be used for putting pieces back to the original places.
    var images = [UIImage]()  // The array of UIImages in the color pieces

    var currIter = 0    // This is a global variable that mark the block in the script to be animated next when the play button is hit.
    let soundManager = SoundManager.sharedInstance   // This is an instance of the Singleton class SoundManager.
    var view2: UIView?   // The rounded rectangle in the middle, the scripts area.
    var view1: UIView?   // The rounded rectangle on the left, the block palette area
    var view3: UIView?   // The rounded rectangle on the right, the animation area.
    var usedNumbers = [UIView]()   // The array of the UIViews of the number blocks that are left in the second, scripts area.
    var buttons = [UIButton]()   // The array of all the buttons, the back button, help button, play button, and redo button.
    var unusedNumbers = [UIView]()   // The array of the UIViews of the numbers in the block palette area.
    var playButtonFrame: CGRect?   // The frame of the play button. It's used for locating the hand when giving hint.
    
    // MARK: Segue
    /// The segue function of the back button. The unwind segue to "Exit" with the identifier "unwindToMainPageFromRainbow" is added in the interface builder.
    /// - Parameters:
    ///     - sender: The UIButton to trigger the unwind segue.
    @IBAction func buttonSegue(sender: UIButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        performSegueWithIdentifier("unwindToMainPageFromRainbow", sender: sender)
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The array of UIImageViews of all the color pieces
        imageViews = [UIImageView(image: UIImage(named: "color1")), UIImageView(image: UIImage(named: "color2")), UIImageView(image: UIImage(named: "color3")), UIImageView(image: UIImage(named: "color4")), UIImageView(image: UIImage(named: "color5")), UIImageView(image: UIImage(named: "color6")), UIImageView(image: UIImage(named: "color7")), UIImageView(image: UIImage(named: "color8")), UIImageView(image: UIImage(named: "color9")), UIImageView(image: UIImage(named: "color10"))]
        
        // The array of layers in the rainbow
        arcViews = [UIImageView(image: UIImage(named: "arc1")), UIImageView(image: UIImage(named: "arc2")), UIImageView(image: UIImage(named: "arc3")), UIImageView(image: UIImage(named: "arc4")), UIImageView(image: UIImage(named: "arc5")), UIImageView(image: UIImage(named: "arc6")), UIImageView(image: UIImage(named: "arc7")), UIImageView(image: UIImage(named: "arc8")), UIImageView(image: UIImage(named: "arc9")), UIImageView(image: UIImage(named: "arc10"))]
        
        // The array of the name of the colors
        colorStrings = ["purple", "pink", "red", "dark orange", "orange", "light orange", "yellow", "green", "turquoise", "blue"]
        
        // The array of colors as in the color pieces
        colors = [UIColor.init(red: 143/255, green: 41/255, blue: 255/255, alpha: 1), UIColor.init(red: 255/255, green: 38/255, blue: 244/255, alpha: 1), UIColor.init(red: 252/255, green: 54/255, blue: 50/255, alpha: 1), UIColor.init(red: 255/255, green: 106/255, blue: 38/255, alpha: 1), UIColor.init(red: 255/255, green: 168/255, blue: 37/255, alpha: 1), UIColor.init(red: 255/255, green: 216/255, blue: 53/255, alpha: 1), UIColor.init(red: 246/255, green: 255/255, blue: 52/255, alpha: 1), UIColor.init(red: 113/255, green: 255/255, blue: 68/255, alpha: 1), UIColor.init(red: 52/255, green: 221/255, blue: 221/255, alpha: 1), UIColor.init(red: 15/255, green: 125/255, blue: 244/255, alpha: 1)]
        
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
        
        // add the rainbow frames to the base view
        addRainbowFrames(spacingToTop, frame: frame)
        // add the blocks to the base view
        addPalette(spacingToTop, frame: frame)

        // This is the width of the puzzle piece. It will be 1/5 of the width of the three rounded-corner rectangle.
        let widthOfPuzzle = (frame.width - 50)/15
        
        // The width of the position views will be half of that of width of a puzzle piece
        let widthOfPositionView = widthOfPuzzle / 2
        
        // Set up the origin of the first available location.
        // 20 is the distance from the first rectangle to the border of the screen. 5 is the distance between rectangles. 5 * widthOfPuzzle is the width of the rectangle. 20 + 5 * widthOfPuzzle + 2.25 * widthOfPuzzle will make the position views vertically in the middle of the middle rectangle.
        let originXOfPositionView = 25 + 7.25 * widthOfPuzzle
        
        // The first puzzle piece is spacingToTop + 0.5 * widthOfPuzzle from the screen border. spacingToTop + 0.75 * widthOfPuzzle will make the puzzle piece fit to the next place.
        var originYOfPositionView = spacingToTop + 0.75 * widthOfPuzzle
        
        // Programatically add all the position views until the bottom of the view, and append all of them into the positionViews array. Each will be widthOfPuzzle down the previous one. There will be same number of zeros in the filledValues and positionViews.
        while (originYOfPositionView < frame.height) {
            let newPos = UIView()
            newPos.frame = CGRectMake(originXOfPositionView, originYOfPositionView, widthOfPositionView, widthOfPositionView * 1.1)
            self.view.addSubview(newPos)
            positionViews.append(newPos)
            filledValues.append(0)
            originYOfPositionView += widthOfPuzzle
        }
        addDefaultPieces(frame)
        
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

        // The third view will be 5 from the middle view, spacingToTop from the top, and 20 from the bottom, with a rounded corner of spacingToTop / 4 radius. It will be the background image.
        view3 = UIImageView(image: UIImage(named: "background"))
        view3!.layer.cornerRadius = spacingToTop/4
        view3!.frame = CGRectMake(30 + 2 * view1!.frame.width, spacingToTop, view1!.frame.width, view1!.frame.height)
        view3!.contentMode = UIViewContentMode.ScaleToFill
        view3!.clipsToBounds = true

        // All the three views will be added to the base view.
        self.view.addSubview(view1!)
        self.view.addSubview(view2!)
        self.view.addSubview(view3!)
    }
    
    /// This method adds the block palette to the left area.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    ///     - frame: The frame the base view, the same width and height as the screen.
    func addPalette(spacingToTop: CGFloat, frame : CGRect) {
        
        // This is the width of the puzzle piece. It will be 1/5 of the width of the three rounded-corner rectangle.
        let widthOfPuzzle = (frame.width - 50)/15
        let spacingBtwPieces = (frame.height - spacingToTop - 20 - 5 * widthOfPuzzle) / 6  // evenly distribute the piece vertically
        
        // The first column of blocks is widthOfPuzzle away from the left border of the block palette.
        var originX = 20 + widthOfPuzzle
        var originY = spacingToTop + spacingBtwPieces
        
        // assign values to the imageViews, add them to unusedNumbers array and add the images to the images array
        for i in 0..<10 {
            imageViews[i].tag = i + 1
            images.append(imageViews[i].image!)
            imageViews[i].userInteractionEnabled = true
            unusedNumbers.append(imageViews[i])
        }
        
        // arrange the first five pieces on to the block palette and add the frames of the UIImageViews to the frames array
        for i in 0..<5 {
            let newUIImageView = imageViews[i]
            newUIImageView.frame = CGRectMake(originX, originY, widthOfPuzzle, widthOfPuzzle * 1.1)
            originY += widthOfPuzzle + spacingBtwPieces
            self.view.addSubview(newUIImageView)
            frames.append(newUIImageView.frame)
        }
        
        // the second column of blocks is 2 * widthOfPuzzle to the right of the first column, and it's widthOfPuzzle from the right border of the block palette
        originX += 2 * widthOfPuzzle
        originY = spacingToTop + spacingBtwPieces
        for i in 5..<10 {
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
    
    /// This method adds all the rainbow frames to the view. They are rendered as template. The color of them are transparent now.
    /// - Parameters:
    ///     - spacingToTop: The space between the top of the three views to the margin.
    ///     - frame: The frame the base view, the same width and height as the screen.
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
    
    /// This method add the given default colors to the view. They are going to be placed in the middle top part on the scripts area, centered at the first and second positionViews.
    /// - Parameters:
    ///     - frame: The frame the base view, the same width and height as the screen.
    func addDefaultPieces(frame: CGRect) {
        let widthOfPuzzle = view2!.frame.width/5
        
        // the dotted outline of the position of the first puzzle block. It can't be moved and it's behind the other color pieces.
        let dottedImageView = UIImageView(image: UIImage(named: "dotted"))
        dottedImageView.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        dottedImageView.center = positionViews[0].center
        dottedImageView.userInteractionEnabled = false
        
        // the first given color is purple
        given1 = UIImageView(image: UIImage(named: "color1"))
        given1!.tag = 1
        given1!.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        given1!.center = positionViews[0].center
        given1!.userInteractionEnabled = true
        addPanAndTapGestureRecognizer(given1!)

        // the second given color is red
        given2 = UIImageView(image: UIImage(named: "color3"))
        given2!.tag = 3
        given2!.frame = CGRectMake(0, 0, widthOfPuzzle, 1.1 * widthOfPuzzle)
        given2!.center = positionViews[1].center
        given2!.userInteractionEnabled = true
        addPanAndTapGestureRecognizer(given2!)

        // add the dotted outline and the given colors are added to the base view
        self.view.addSubview(dottedImageView)
        self.view.addSubview(given1!)
        self.view.addSubview(given2!)
        
        // set up the usedNumbers and filledViews array. set the filledPosition to be 2
        usedNumbers = [given1!, given2!]
        filledViews = [given1!, given2!]
        filledPosition = 2
        filledValues[0] = 1
        filledValues[1] = 3
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
        backButton.addTarget(self, action: #selector(RainbowViewController.buttonSegue(_:)), forControlEvents: .TouchUpInside)
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
        playButton.addTarget(self, action: #selector(RainbowViewController.play), forControlEvents: .TouchUpInside)
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
        redoButton.addTarget(self, action: #selector(RainbowViewController.reset), forControlEvents: .TouchUpInside)
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
        helpButton.addTarget(self, action: #selector(RainbowViewController.help), forControlEvents: .TouchUpInside)
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
        NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: #selector(RainbowViewController.enableButtons), userInfo: nil, repeats: false)
    }

    // MARK: Gesture Recognizer
    /// This method is to add both pan gesture recognizer and tap gesture to the UIImageView.
    /// - Parameters:
    ///     - view: The UIImageView to add the gesture recognizers.
    func addPanAndTapGestureRecognizer(view: UIImageView) {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(RainbowViewController.handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        addTapGestureRecognizer(view)
    }
    
    /// This method is to add tap gesture recognizer to the UIImageView. When the view is tapped, handleTap method will be called.
    /// - Parameters:
    ///     - view: The UIImageView to add the gesture recognizers.
    func addTapGestureRecognizer(view: UIImageView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RainbowViewController.handleTap(_:)))
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
        
        // update the filled Position is a puzzle put in the chain is moved, so that it can still snap to the original place
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
    
    /// This method will animate the puzzle block to grow in size of a factor of 1.2 and get back to normal. It will call out the name of the color at the same time.
    /// - Parameters:
    ///     - view: The UIView to be animated.
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
    
    /// This method will animate all the puzzle blocks in the script. It will call the playIndividualEffect method of the views in the sequence one by one. At the same time, the corresponding layer of the rainbow will be colored.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func playSequentEffect(timer: NSTimer) {
        
        // animate each color block one by one and color the rainbow at the same time
        if (currIter < filledViews.count) {
            playIndividualEffect(filledViews[currIter])
            UIView.animateWithDuration(1.5, animations: {
                self.arcViews[self.currIter].tintColor = self.colors[self.filledValues[self.currIter] - 1]
            })
        }
        currIter = currIter + 1
        
        // after all the colors in the script are animated, the playMagic method will be called
        if (currIter == filledViews.count) {
            timer.invalidate()
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(RainbowViewController.playMagic(_:)), userInfo: nil, repeats: false)
        }
    }
    
    /// This method calls the AVSpeechSynthesizer method to read out the string.
    func sayInstruction() {
        let string = "Drag the colors from the left to the middle area to draw a rainbow"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
    }
    
    /// This method play the sound effect and start animating the sheep.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func playMagic(timer: NSTimer) {
        soundManager.playMagic()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RainbowViewController.showSheep(_:)), userInfo: nil, repeats: false)
    }
    
    /// This method to show the sheep and animate it to jump up and down.
    /// - Parameters:
    ///     - timer: The NSTimer that triggers the method.
    func showSheep(timer: NSTimer) {
        // after all the blocks are animated, the sheep will be shown on the screen
        if (currIter == filledViews.count) {
            let screen = self.view.frame
            sheepView.frame = CGRect(x: (screen.width - 50) / 15 * 13 , y: screen.height - 3 * (screen.width - 50) / 15, width: (screen.width - 50) / 15, height: (screen.width - 50) / 15)
            self.view.addSubview(sheepView)
            view.alpha = 1
        }
        
        // after animating the sheep for three times, removes it
        if (currIter == self.filledViews.count + 3) {
            self.sheepView.removeFromSuperview()
            return
        }
        
        // animate the sheep to move up, and call this method again
        let frame = sheepView.frame
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
            self.sheepView.frame.origin.y -= self.sheepView.frame.height / 2
            self.soundManager.playJump()
            }, completion: {finished in UIView.animateWithDuration(0.5, delay:0, options:.CurveEaseIn, animations: {
                self.sheepView.frame = frame
                }, completion: {finished in
                if (self.currIter < self.filledViews.count + 3) {
                    self.currIter = self.currIter + 1
                    NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(RainbowViewController.showSheep(_:)), userInfo: nil, repeats: false)
                }
            })
        })
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
        
        // if there are fewer than three views put into the scripts area, move the first color to the next available place
        if (filledPosition < 3) {
            sayInstruction()   // say the instruction again
            pieceToMove = unusedNumbers[0]
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
                        pieceToMove!.frame = self.frames[0]
                        pieceToMove?.alpha = 1
                        self.helpingHand.removeFromSuperview()

                })
            }
        }
            
        // if there are already at least five views in the scripts area, the hand will be animated to point to the play button
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
    
    /// - Attributions: http://nshipster.com/avspeechsynthesizer/
    func callColor(index: Int) {
        let string = colorStrings[index]
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speakUtterance(utterance)
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
        clearAllRainbowColors()
    }
    
    /// This method starts the animation of all the blocks in the script
    func play() {
        clearAllRainbowColors()
        disableButtons(1.5 * Double(filledPosition))
        dispatch_async(dispatch_get_main_queue()) {
            self.soundManager.playTap()
        }
        currIter = 0
        if (filledPosition > 0) {
            NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(RainbowViewController.playSequentEffect(_:)), userInfo: nil, repeats: true)
        }
    }
    
    /// The method to color all the layers of the rainbow to be clear.
    func clearAllRainbowColors() {
        for imageView in arcViews {
            imageView.tintColor = UIColor.clearColor()
        }
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
