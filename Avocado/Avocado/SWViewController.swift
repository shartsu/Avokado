import UIKit

class SWViewController: UIViewController {

    var timer:NSTimer = NSTimer()

    @IBOutlet var displayTimeLabel: UILabel!
    @IBOutlet weak var avokado: UIImageView!
    @IBOutlet weak var suspendButton: UIButton!
    
    //NSTimeInterval == Double
    var startTime = NSTimeInterval()
    var elapsedTime = NSTimeInterval()
    
    //Frame
    var viewFrame = CGRect ()
    var frameChangedTime = NSTimeInterval()
    var frameChangedFlag = Int()
    
    //Class StateMachine
    let stateTimer = StateTimer();
    
    //Class ShowTimer
    let showTimer = ShowTimer();

    override func viewDidLoad() {
        super.viewDidLoad()

        displayTimeLabel.textColor = UIColor.whiteColor();
        
        //Move frame start point
        avokado.frame.origin.x = screenSize().width - CGRectGetWidth(avokado.frame);
        
        //Firstly set statement to 2
        let buttonText = stateTimer.reset();
        suspendButton.setTitle(buttonText, forState: UIControlState.Normal);

        // Do any additional setup after loading the view.
        self.view.addSubview(avokado);
    }

    //suspend function
    @IBAction func control(sender: AnyObject) {
        print("stateTimer.statecheck()", stateTimer.statecheck());
        var buttonText:String = String();
        
        if (stateTimer.statecheck() == 1) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true);
            startTime = NSDate.timeIntervalSinceReferenceDate();
            
            //Set statement to 2
            buttonText = stateTimer.start();
            suspendButton.setTitle(buttonText, forState: UIControlState.Normal);
            
        } else if(stateTimer.statecheck() == 2){
            timer.invalidate();
            
            //Set statement to 3
            buttonText = stateTimer.suspend();
            suspendButton.setTitle(buttonText, forState: UIControlState.Normal);
            
        } else if (stateTimer.statecheck() == 3) {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTime", userInfo: nil, repeats: true);
            startTime = NSDate.timeIntervalSinceReferenceDate() - elapsedTime;
            
            //Set statement to 2
            buttonText = stateTimer.start();
            suspendButton.setTitle(buttonText, forState: UIControlState.Normal);
        }
    }

    @IBAction func reset(sender: AnyObject) {

        timer.invalidate();
        
        let buttonText = stateTimer.reset();
        suspendButton.setTitle(buttonText, forState: UIControlState.Normal);
        displayTimeLabel.textColor = UIColor.whiteColor();
        
        //Replace to first position
        avokado.frame.origin.x = screenSize().width - CGRectGetWidth(avokado.frame);
        
        //Reset Timer
        elapsedTime = 0;

        displayTimeLabel.text = showTimer.reset();
    }

    func updateTime() {

        let currentTime = NSDate.timeIntervalSinceReferenceDate();
        var countDown =  NSTimeInterval();

        /* --- There are three cases considered below implementation --- */
        //1, ONLY suspend button pressed
        //2, suspend button pressed THEN frame changed
        //3, ONLY frame changed

        print("stateTimer.statecheck()", stateTimer.statecheck());

        if(frameChangedFlag == 1) {
            startTime = currentTime - (1500.0 - frameChangedTime);
        }
        
        //Calcurate elapsedTime then subtract it from 1500 (for 25 minutes countdown)
        elapsedTime = currentTime - startTime;
        countDown = 1500.0 - elapsedTime;

        if(countDown < 0.0) {
        //if counter over 00:00:00, then COUNTUP start
            displayTimeLabel.textColor = UIColor.redColor();
            countDown = elapsedTime - 1500.0;
            avokado.frame.origin.x = 0;
        } else {
        //Otherwise (Normal function)
            displayTimeLabel.textColor = UIColor.whiteColor();
            avokado.frame.origin.x = CGFloat(countDown * (Double(screenSize().width - CGRectGetWidth(avokado.frame)) / 1500.0));
        }

        //Alter timer values
        displayTimeLabel.text = showTimer.setTimer(countDown);

        //Reset flags
        frameChangedFlag = 0;
        print("elapsedTime:finally", elapsedTime);
    }
    
    
    func screenSize() -> CGSize {
        let screenSize = UIScreen.mainScreen().bounds.size;
        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1
            && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
                return CGSizeMake(screenSize.height, screenSize.width)
        }
        return screenSize
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /*
        UIView.animateWithDuration(0.06,
            animations: { () -> Void in
                self.avokado.transform = CGAffineTransformMakeScale(0.9, 0.9)
            })
            { (Bool) -> Void in
        }
        
*/
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // Get touchevent
        let touchEvent = touches.first!
        
        // Get valuables how long distance moved
        let preDx = touchEvent.previousLocationInView(self.view).x;
        let preDy = touchEvent.previousLocationInView(self.view).y;
        let newDx = touchEvent.locationInView(self.view).x;
        let dx = newDx - preDx;
        
        print("preDy", preDy);
    
        //Apply it to the frame
        if(preDy < 130) {avokado.frame.origin.x += dx;}
        
        //Set statement to 3
        let buttonText = stateTimer.suspend();
        suspendButton.setTitle(buttonText, forState: UIControlState.Normal);
        
        //Set White Color
        displayTimeLabel.textColor = UIColor.whiteColor();
        
        // Stop move over their frame
        if(avokado.frame.origin.x < (screenSize().width - CGRectGetWidth(avokado.frame))) {
            avokado.frame.origin.x = screenSize().width - CGRectGetWidth(avokado.frame)
        } else if(avokado.frame.origin.x > 0) {
            avokado.frame.origin.x = 0
        }
  
        //FLAG and show changed time value
        timer.invalidate();
        frameChangedFlag = 1;
        frameChangedTime = Double(avokado.frame.origin.x) * (1500.0 / Double(screenSize().width - CGRectGetWidth(avokado.frame)))
        
        //Replace timer to nearby exact minutes
        if ((frameChangedTime % 60.0) > 30.0) {
            frameChangedTime =  frameChangedTime + 60.0 - (frameChangedTime % 60.0)
        } else {
            frameChangedTime =  frameChangedTime - (frameChangedTime % 60.0)
        }
        
        //Show Timer
        displayTimeLabel.text = showTimer.setTimerOnlyMin(frameChangedTime);
        
        //Replace also value
        elapsedTime = 1500.0 - frameChangedTime;
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        

        //Replace frame to nearby exact positions
        avokado.frame.origin.x = CGFloat((frameChangedTime / 60.0) * (-36.0));

        
        /*
        UIView.animateWithDuration(0.1,
            animations: { () -> Void in
                self.avokado.transform = CGAffineTransformMakeScale(0.4, 0.4)
                self.avokado.transform = CGAffineTransformMakeScale(1.0, 1.0)
            })
            { (Bool) -> Void in
                
        }
*/

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}