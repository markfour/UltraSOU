//
//  MMDataViewController.h
//  MEMELib_Sample
//
//  Created by JINS MEME on 2015/03/30.
//  Copyright (c) 2015 JINS MEME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MEMELib/MEMELib.h>

#import "MQTTKit.h"

@class MMViewController;

@interface MMDataViewController : UITableViewController
{
    bool isVertival;
    bool isMusicPlaying;
    
    NSTimer *bgmTimer;
    double gameTime;
    NSDate *stdate;
    
    MQTTClient *client;
}
- (void) memeRealTimeModeDataReceived: (MEMERealTimeData *)data;

@property (strong, nonatomic) AVAudioPlayer *auidoIntro;
@property (strong, nonatomic) AVAudioPlayer *audioHai;
@property (strong, nonatomic) UIView *debugView;
@property (strong, nonatomic) UIImageView *backgroundView;

@property BOOL shouldBeHidingStatusBar;

@end
