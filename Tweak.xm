#import "/Users/tigra/Desktop/Coding/iphone-private-frameworks/PhotoLibrary/PLCameraButton.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AudioMaster.h"

static NSTimer *cdTimer; 
static SoundCtrl *snd; 
static int remainingSecs; 
static int remainingShots; 
static int totalSecs; 
static int totalShots; 
static UIButton * timeButton; 
static UIView * camBtn; 
static BOOL areWeOn; 
static BOOL areWeProgressing; 
static BOOL isSpringBoard=NO; 
static BOOL isCamera=NO; 
static UIToolbar * ourCountBar; 
static UILabel * ourCountLabel; 
static UIToolbar * bottomCamBar; 
#define PREF_FILE @"/var/mobile/Library/Preferences/com.vladkorotnev.camtime.plist" 
#define ABT_TITLE @"CamTime 4" 


static void updateCountdownView() { 
	[ourCountLabel setText: [NSString stringWithFormat:@"Seconds: %i out of %i\nShots: %i out of %i",remainingSecs,totalSecs,remainingShots,totalShots]];
}

static void animateCountViewIn() { 
		[ourCountBar setHidden:NO]; 
        void (^animations)(void) = nil; 
        animations = ^{
            [ourCountBar setAlpha:1.0f]; 
        };
        [UIView animateWithDuration:0.6 animations:animations]; 
}
static void animateCountViewOut() { 
        void (^animations)(void) = nil; 
        animations = ^{
            [ourCountBar setAlpha:0.0f];
        };
        [UIView animateWithDuration:0.6 animations:animations]; 
        
        [NSTimer scheduledTimerWithTimeInterval:0.6 target:camBtn selector:@selector(_hideOurBar) userInfo:nil repeats:FALSE];
}

static void nagScreen() { 
			NSMutableDictionary * pref = nil; 
			if([[NSFileManager defaultManager]fileExistsAtPath:PREF_FILE]) { 
				pref = [NSMutableDictionary dictionaryWithContentsOfFile:PREF_FILE]; 
			} else { 
				pref = [[NSMutableDictionary alloc]init]; 
			} 
			NSString * coStr = [pref objectForKey:@"CamTimedImageCounter"]; 
			int camTimeCount = [coStr intValue]; 
			camTimeCount = camTimeCount + 1; 
			
			[pref setValue: [NSString stringWithFormat:@"%i",camTimeCount] forKey:@"CamTimedImageCounter"];
			[pref writeToFile: PREF_FILE atomically:YES];
			
			if(camTimeCount == 1){ 
				[[[UIAlertView alloc] initWithTitle:ABT_TITLE message:@"Congrats on your first timed picture with CamTime! :)\n\nWould you please donate a little bit to support your favourite app? :)\n\n(C) vladkorotnev, 2012\nvladkorotnev.github.com" delegate:camBtn cancelButtonTitle:@"No!" otherButtonTitles:@"Donate",nil]show];
			} 
			if (camTimeCount % 100 == 0) { 
				[[[UIAlertView alloc] initWithTitle:ABT_TITLE message:[NSString stringWithFormat:@"It seems you like CamTime, as you've already made %i shots with it! :)\n\nWould you please donate a little bit to support your favourite app? :)\n\n(C) vladkorotnev, 2012\nvladkorotnev.github.com",camTimeCount] delegate:camBtn cancelButtonTitle:@"No!" otherButtonTitles:@"Donate",nil]show];
			} 
}

%hook PLCameraView
- (void)_shutterButtonClicked { 
	if(!areWeOn || areWeProgressing) {
		%orig; 
	} else {
		[camBtn andWeGo]; 
	}
}

- (void) viewDidAppear {
	%orig; 
	bottomCamBar = [self _bottomBar]; 
	
	
		ourCountBar = [[UIToolbar alloc]init]; 
		
		ourCountBar.frame = CGRectMake(0,0,bottomCamBar.frame.size.width,bottomCamBar.frame.size.height);
	
	[ourCountBar setBackgroundImage: [UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework/PLCameraButtonBarSilver.png"] forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
	ourCountBar.opaque = true; 
	NSMutableArray *items = [[NSMutableArray alloc] init]; 
	
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
		if(isCamera || isSpringBoard) 
		[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:camBtn action:@selector(timerStop)] autorelease]];
	[ourCountBar setItems:items animated:NO]; 
	[items release]; 
	ourCountLabel = [[UILabel alloc]init]; 
	
	ourCountLabel.frame = CGRectMake(5,5,bottomCamBar.frame.size.width-10,bottomCamBar.frame.size.height-10);
	ourCountLabel.opaque = false; 
	ourCountLabel.backgroundColor = [UIColor clearColor]; 
	ourCountLabel.lineBreakMode = UILineBreakModeWordWrap; 
	ourCountLabel.numberOfLines = 0; 
	[ourCountBar addSubview:ourCountLabel]; 
	[ourCountBar setAlpha:0.0f]; 
	[ourCountBar setHidden:true]; 
	[bottomCamBar addSubview:ourCountBar]; 
}
%end



%hook PLCameraButton
- (id) initWithDefaultSize { 
	NSLog(@"This is CamTime by vladkorotnev. 100% pure objective-c, 100% genuine!"); 
	NSString* appID = [[NSBundle mainBundle] bundleIdentifier]; 
	isSpringBoard=[appID isEqualToString:@"com.apple.springboard"]; 
		isCamera=[appID isEqualToString:@"com.apple.camera"]; 
	%orig; 
	camBtn = self; 
	timeButton = [UIButton buttonWithType:UIButtonTypeCustom]; 
	[timeButton setFrame:CGRectMake(self.frame.origin.x - self.frame.size.height-5,self.frame.origin.y,self.frame.size.height,self.frame.size.height)];
	[timeButton setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/CamTime/time.png"] forState:UIControlStateNormal];
     [timeButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework/PLCameraButtonSilver.png"] forState:UIControlStateNormal];	
	[timeButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework/PLCameraButtonSilverPressed.png"] forState:UIControlStateHighlighted];
	[self addSubview: timeButton]; 
	snd = [[SoundCtrl alloc]init]; 
	areWeOn = false; 
	areWeProgressing = false; 
	[timeButton addTarget:self action:@selector(camlol) forControlEvents:UIControlEventTouchUpInside];
	return self; 
}

%new 
- (void) camlol { 
if (!areWeOn) { 
	UIAlertView * setTimeAlert = nil; 
	if(isCamera || isSpringBoard) { 
	
	setTimeAlert = [[UIAlertView alloc] initWithTitle:@"Set the timer" message:@"Enter the delay and how much pictures to take" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
	[setTimeAlert setAlertViewStyle: UIAlertViewStylePlainTextInput];
	[[setTimeAlert textFieldAtIndex:0]setKeyboardType:UIKeyboardTypeNumberPad];
	[[setTimeAlert textFieldAtIndex:0]setPlaceholder:@"Delay in seconds"]; 
	[setTimeAlert addTextFieldWithValue:nil label:@"Picture count, default 1"]; 
	[[setTimeAlert textFieldAtIndex:1]setKeyboardType:UIKeyboardTypeNumberPad];
	} else {
	
	setTimeAlert = [[UIAlertView alloc] initWithTitle:@"Set the timer" message:@"Enter the delay" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
	[setTimeAlert setAlertViewStyle: UIAlertViewStylePlainTextInput];
	[[setTimeAlert textFieldAtIndex:0]setKeyboardType:UIKeyboardTypeNumberPad];
	[[setTimeAlert textFieldAtIndex:0]setPlaceholder:@"Delay in seconds"]; 
	}
	[setTimeAlert show]; 
	} else { 
	
	UIAlertView * canc = [[UIAlertView alloc] initWithTitle:@"Cancel the timer?" message:@"" delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yes",nil];
	[canc show];
	} 
}

%new 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{ 
    if([alertView.title isEqualToString:@"Set the timer"] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"])
    { 
        remainingSecs = [[alertView textFieldAtIndex:0].text intValue]; 
        if(isCamera || isSpringBoard) 
        	remainingShots = [[alertView textFieldAtIndex:1].text intValue]; 
    	 else 
        	remainingShots = 1; 
        if (remainingShots <= 0) 
        	remainingShots = 1; 
        if (remainingSecs <= 0) 
        	return; 
        totalSecs = remainingSecs; 
        totalShots = remainingShots; 
        areWeOn = true; 
        
		[timeButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework/PLCameraButtonSilverPressed.png"] forState:UIControlStateNormal];	
    }
    if([alertView.title isEqualToString:@"Cancel the timer?"] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"])
    {  
        areWeOn = false; 
		[timeButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework/PLCameraButtonSilver.png"] forState:UIControlStateNormal];	
    }

    if([alertView.title isEqualToString:ABT_TITLE] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Donate"])
		 [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http:
}

%new
- (void) andWeGo { 
	remainingSecs = totalSecs; 
        remainingShots = totalShots; 
    	updateCountdownView(); 
    	animateCountViewIn(); 
    	cdTimer = nil; 
    	cdTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
		areWeProgressing = true; 
}
%new
- (void) countdown { 
	if (remainingSecs > 1) { 
		remainingSecs = remainingSecs - 1; 
		updateCountdownView(); 
		if(remainingSecs >2) 
			[snd playSystemSoundAtPath: @"/Library/Application Support/CamTime/tick.wav"];
		else 
			[snd playSystemSoundAtPath: @"/Library/Application Support/CamTime/shot.wav"];
		areWeProgressing = true; 
	} else { 
		[cdTimer invalidate]; 
			[self sendActionsForControlEvents: UIControlEventTouchUpInside]; 
		if (remainingShots > 1) { 
			areWeProgressing = true; 
			remainingShots = remainingShots - 1; 
			remainingSecs = totalSecs; 
			cdTimer = nil; 
    		cdTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
		} else { 
			animateCountViewOut(); 
			areWeProgressing = false; 
			remainingSecs = totalSecs; 
        	remainingShots = totalShots; 
			nagScreen(); 
		}
	}
}

%new
-(void)timerStop { 
	[cdTimer invalidate]; 
	animateCountViewOut(); 
			areWeProgressing = false; 
			remainingSecs = totalSecs; 
        	remainingShots = totalShots;
        	nagScreen(); 
} 

%new
-(void) _hideOurBar { 
	[ourCountBar setHidden:YES];
}
%end



