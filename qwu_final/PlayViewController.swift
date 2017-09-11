//
//  PlayViewController.swift
//  qwu_final
//
//  Created by Atlas on 3/9/17.
//  Copyright © 2017 Qianru Wu. All rights reserved.
//

import UIKit

// shuffle method applied to array
extension Array {
    mutating func shuffle() {
        for _ in 0..<100 {
            sort {
                (_,_) in arc4random() < arc4random()
            }
        }
    }
}


class PlayViewController: UIViewController {

    @IBOutlet weak var countDown: UILabel!

    var count = 120       // countdown seconds
    var index : [Int] = [Int]()     // index of squares with images
    var allIndex : [Int] = [Int]()  // index of all squares
    let side = 35       // side length for each square
    var gameWin : Bool = false     // check if win
    var gameLose : Bool = false     // check if lose
    var perform : Bool = true      // check if gesture can be performed
    var p: [CGPoint] = []       // array of CGPoints to track gestures
    var first: CGPoint = CGPoint.zero       // first point of gesture
    var last : CGPoint = CGPoint.zero       // last point of gesture
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "endGameSegue", sender: self)
    }
    
    // shuffle (1...32) x 2 integers
    func shuffleIndex () {
        let a  = Array(1...32)
        let b  = a
        index = a + b
        index.shuffle()
    }
    
    // return initial location for all images
    func initLocation () -> CGPoint {
        // define size and position
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let xStart = (Int(screenWidth) - side * 10) / 2  // initial x position
        let yStart = (Int(screenHeight) - side * 10) / 2  // initial y position
        let point : CGPoint = CGPoint(x: xStart, y: yStart)
        return point
    }

    // return a full index array of all images, including gray image (boundaries)
    func getFullIndex () -> [Int] {
        var fullIndex = Array<Int>(repeating: -1, count: 100)
        for i in 0...99 {
            if i >= 11 && i <= 18 {
                fullIndex[i] = index[i - 11]
            } else if i >= 21 && i <= 28 {
                fullIndex[i] = index[i - 13]
            } else if i >= 31 && i <= 38 {
                fullIndex[i] = index[i - 15]
            } else if i >= 41 && i <= 48 {
                fullIndex[i] = index[i - 17]
            } else if i >= 51 && i <= 58 {
                fullIndex[i] = index[i - 19]
            } else if i >= 61 && i <= 68 {
                fullIndex[i] = index[i - 21]
            } else if i >= 71 && i <= 78 {
                fullIndex[i] = index[i - 23]
            } else if i >= 81 && i <= 88 {
                fullIndex[i] = index[i - 25]
            } else {
                fullIndex[i] = -1
            }
        }
        return fullIndex
    }
    
    // check in which square the given point is
    func checkLocation (point : CGPoint) -> Int {
        // get initial point location
        let initPoint = initLocation()
        let initX = Int(initPoint.x)
        let initY = Int(initPoint.y)
        var n = 0       // index of fullIndex
        let x = Int(point.x)
        let y = Int(point.y)
        let fullIndex = allIndex
        
        // only check points within the image area
        if (x < initX) || (x > initX + side * 10) || (y < initY) || (y > initY + side * 10) {
            return -99      // index that is not in the image area
        }
        // get distances in x and y
        let dx = Float(x) - Float(initX)
        let dy = Float(y) - Float(initY)
        let row = Int(dy / Float(side)) + 1
        let column = Int(dx / Float(side)) + 1
        n = (row - 1) * 10 + column - 1
        return fullIndex[n]
    }
    
    // check in which column the given point is in the fullIndex
    func getColumn (point : CGPoint) -> Int {
        let x = Float(point.x)
        let initPoint = initLocation()
        let initX = Int(initPoint.x)
        let dx = x - Float(initX)
        let column = Int(dx / Float(side)) + 1
        return column
    }
    
    // check in which row the given point is in the fullIndex
    func getRow (point : CGPoint) -> Int {
        let y = Float(point.y)
        let initPoint = initLocation()
        let initY = Int(initPoint.y)
        let dy = y - Float(initY)
        let row = Int(dy / Float(side)) + 1
        return row
    }
    
    // check if two points lie in the same square
    func checkSameSquare (p1 : CGPoint, p2 : CGPoint) -> Bool {
        let row1 = getRow(point: p1)
        let row2 = getRow(point: p2)
        let column1 = getColumn(point: p1)
        let column2 = getColumn(point: p2)
        if (row1 == row2) && (column1 == column2) { return true }
        return false
    }
    
    // Define square board
    func drawSquares () {
        let initPoint = initLocation()
        var x = Int(initPoint.x)
        var y = Int(initPoint.y)
        
        shuffleIndex()
        let fullIndex = getFullIndex()
        allIndex = fullIndex
        
        // draw images
        for i in 0...99 {
            // draw outer boundaries
            if fullIndex[i] == -1 {
                let imageName : String = "gray.png"
                let image = UIImage(named: imageName)
                let imageView = UIImageView(image: image!)
                imageView.frame = CGRect(x: x, y: y, width: side, height: side)
                imageView.backgroundColor = UIColor.gray
                imageView.layer.borderWidth = 1
                imageView.isUserInteractionEnabled = true
                imageView.isMultipleTouchEnabled = true
                view.addSubview(imageView)
            } else {
                // draw images
                let imageName : String = "square" + "\(fullIndex[i])" + ".png"
                let image = UIImage(named: imageName)
                let imageView = UIImageView(image: image!)
                imageView.frame = CGRect(x: x, y: y, width: side, height: side)
                imageView.backgroundColor = UIColor.gray
                imageView.layer.borderWidth = 1
                imageView.isUserInteractionEnabled = true
                imageView.isMultipleTouchEnabled = true
                view.addSubview(imageView)
            }
            // upadate after each square is drawn
            x = x + side
            if i % 10 == 9 {
                y = y + side
                x = Int(initPoint.x)
            }
        }
    }
   

/*
     override gesture funcs
 */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        perform = true
        if let touch = touches.first {
            first = touch.location(in: view)
            last = first
            p.removeAll(keepingCapacity: true)
            p.append(first)
            
            // if starting point not in the image area, don't perform
            let firstIndex = checkLocation(point: first)
            if (firstIndex == -99) {
                perform = false
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            last = touch.location(in: view)
            p.append(last)
            
            // while moving, if not in the gray area or not in the same image index, don't perform
            let firstIndex = checkLocation(point: first)
            let lastIndex = checkLocation(point: last)
            if (firstIndex != lastIndex) && (lastIndex != -1) {
                perform = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            last = touch.location(in: view)
            p.append(last)
            
            // if the first and last squares are the same square (not moving outside one square), don't perform
            let ifSame = checkSameSquare(p1: first, p2: last)
            if (ifSame == true) || (checkLocation(point: last) < 0) {
                perform = false
            }
            

            // replace the first and last squares with gray image
            if perform == true {
                let initXY = initLocation()
                let imageViewFirst = UIImageView(image: UIImage(named: "gray.png")!)
                let imageViewLast = UIImageView(image: UIImage(named: "gray.png")!)
                
                let firstSquareX = Int(first.x) - Int(first.x - initXY.x) % side
                let firstSquareY = Int(first.y) - Int(first.y - initXY.y) % side
                let lastSquareX = Int(last.x) - Int(last.x - initXY.x) % side
                let lastSquareY = Int(last.y) - Int(last.y - initXY.y) % side
                
                imageViewFirst.frame = CGRect(x: firstSquareX, y: firstSquareY, width: side, height: side)
                imageViewLast.frame = CGRect(x: lastSquareX, y: lastSquareY, width: side, height: side)
                
                imageViewFirst.backgroundColor = UIColor.gray
                imageViewFirst.layer.borderWidth = 1
                imageViewFirst.isUserInteractionEnabled = true
                imageViewFirst.isMultipleTouchEnabled = true
                view.addSubview(imageViewFirst)
                
                imageViewLast.backgroundColor = UIColor.gray
                imageViewLast.layer.borderWidth = 1
                imageViewLast.isUserInteractionEnabled = true
                imageViewLast.isMultipleTouchEnabled = true
                view.addSubview(imageViewLast)
                
                // update fullIndex array
                let row_f = getRow(point: first)
                let row_l = getRow(point: last)
                let col_f = getColumn(point: first)
                let col_l = getColumn(point: last)
                allIndex[(row_f - 1 ) * 10 + col_f - 1] = -1
                allIndex[(row_l - 1 ) * 10 + col_l - 1] = -1
            }
            
            // check if game over after every move
            checkGameOver()
            if (gameWin == true) {
                
            }
            if (gameLose == true) {
                
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    
    // check if win or lose at game over
    func checkGameOver () {
        gameWin = false     // set to false before check
        gameLose = false
        var n = 0
        // check if there is any image not removed
        for i in allIndex {
            if i != -1 {
                n += 1
            }
        }
        if (count != 0) && (n == 0) {
            gameWin = true
        } else if (count == 0) && (n > 0) {
            gameLose = true
        }
    }
    
    func updateCounter() {
        if (count > 0) && (gameWin == false) {
            countDown.text = "\(count)"
            count -= 1
        } else if (count > 0) && (gameWin == true) {
            self.performSegue(withIdentifier: "winSegue", sender: self)
        } else if (count == 0) && (gameLose == true) {
            self.performSegue(withIdentifier: "loseSegue", sender: self)
        }
    }
        
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Draw squares on the view
        drawSquares()
        
        // countdown
        countDown.text = "\(count)"
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
