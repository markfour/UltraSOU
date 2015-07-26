//
//  MMDataViewController.m
//  MEMELib_Sample
//
//  Created by JINS MEME on 2015/03/30.
//  Copyright (c) 2015 JINS MEME. All rights reserved.
//

#import "MMDataViewController.h"
#import "MMViewController.h"

@interface MMDataViewController ()

@property (nonatomic, strong) UIView    *indicatorView;

@property (strong, nonatomic) MEMERealTimeData *latestRealTimeData;

@end

@implementation MMDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"RealTime Data";
    
    isVertival = true;
    isMusicPlaying = false;
    
    // Data Commmunication Indicator
    self.indicatorView                  = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 24, 24)];
    self.indicatorView.alpha            = 0.20;
    self.indicatorView.backgroundColor  = [UIColor whiteColor];
    self.indicatorView.layer.cornerRadius = self.indicatorView.frame.size.height * 0.5;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.indicatorView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Disconnect" style:UIBarButtonItemStylePlain target: self action:@selector(disconnectButtonPressed:)];
    
    _backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial.jpg"]];
    [self.view addSubview:_backgroundView];
    
    _debugView = [[UIView alloc] init];
    _debugView.backgroundColor = [UIColor whiteColor];
    _debugView.alpha = 0.8;
    [self.view addSubview:_debugView];
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(mqttTest:) forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"MQTT" forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, 160, 44);
        [_debugView addSubview:button];
    }
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(playBGM) forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"Play Sound" forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 44, 160, 44);
        [_debugView addSubview:button];
    }
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(stopBGM) forControlEvents:UIControlEventTouchDown];
        [button setTitle:@"Stop Sound" forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 88, 160, 44);
        [_debugView addSubview:button];
    }
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath = [mainBundle pathForResource:@"hi" ofType:@"mp3"];
        NSURL *fileUrl  = [NSURL fileURLWithPath:filePath];
        
        NSError* error = nil;
        _audioHai = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
        [_audioHai prepareToPlay];
    }
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *filePath = [mainBundle pathForResource:@"us" ofType:@"mp3"];
        NSURL *fileUrl  = [NSURL fileURLWithPath:filePath];
        
        NSError* error = nil;
        _auidoIntro = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
        [_auidoIntro prepareToPlay];
    }
    
    NSString *clientID = @"ultra-user";
    client = [[MQTTClient alloc] initWithClientId:clientID];
    client.username = @"ultra-user";
    client.password = @"ultra-user";
    client.port = 16056;
    
//    [client connectToHost:@"m01.mqtt.cloud.nifty.com"
//        completionHandler:^(NSUInteger code) {
//            if (code == ConnectionAccepted) {
//                // when the client is connected, send a MQTT message
//                [client publishString:publichString
//                              toTopic:@"music"
//                              withQos:AtMostOnce
//                               retain:NO
//                    completionHandler:^(int mid) {
//                        NSLog(@"message has been delivered");
//                    }];
//            }
//        }];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self hideStatusBar];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    _backgroundView.frame = CGRectMake(0, 0, 320, 568);
    [self.view bringSubviewToFront:_backgroundView];
    
    _debugView.frame = CGRectMake(0, 0, 320, 146);
    [self.view bringSubviewToFront:_debugView];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)playBGM
{
    NSLog(@"Play BGM %f", _auidoIntro.duration);
    isVertival = false;
    
    isMusicPlaying = true;
    [_auidoIntro stop];
    _auidoIntro.currentTime = 0;
    [_auidoIntro play];
    
    [self mqttSend:@"on"];
    
    bgmTimer = [NSTimer
                scheduledTimerWithTimeInterval:0.01
                target:self
                selector:@selector(timer:)
                userInfo:nil
                repeats:YES];
    
    //スタート時間の取得
    stdate = [NSDate date];
}

- (void)stopBGM
{
    isMusicPlaying = false;
    
    [_auidoIntro stop];
    
    [self hey];
    
    double score = 0;
    
    if (_auidoIntro.currentTime == 0) {
        //BGMは既に再生済み
        score = _auidoIntro.duration - (gameTime - _auidoIntro.duration);
    } else {
        //BGMはまだ再生中
        score = gameTime;
    }
    
    NSString *scoreStr = [NSString stringWithFormat:@"%.4f", score];
    scoreStr = [scoreStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    [self mqttSend:@"off"];
    
    [self displayRanking:scoreStr];
    
//    NSLog(@"@%.4f - @%.4f", _auidoIntro.currentTime, gameTime);
//    NSLog(@"score %@", scoreStr);
}

- (void)displayRanking:(NSString *)score
{
    NSLog(@"displayRanking");
    WebViewController *vc = [[WebViewController alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@%@", @"http://cef098l-ate-app000.c4sa.net/index_test.php?id=xxxxxx&score=", score];
    vc.rankingURL = url;
    [self presentViewController:vc animated:YES completion:nil];
}

//- (void)dismissRanking {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (void)hey
{
    _audioHai.currentTime = 0;
    [_audioHai play];
}


-(void)timer:(NSTimer *)timer{
    NSDate *now=[NSDate date];    //現在の時間を取得
    
    //開始時間と現在時間の差分を、少数点以下2桁で表示
    NSString *floatString = [NSString stringWithFormat:@"%.2f",[now timeIntervalSinceDate:stdate]];
    gameTime = floatString.doubleValue;
    
    if (!isMusicPlaying) {
        if ([bgmTimer isValid]) {
            [bgmTimer invalidate];
        }
    }
}

- (void)mqttSend:(NSString *)publichString {
    // create the client with a unique client ID
    
    [client connectToHost:@"m01.mqtt.cloud.nifty.com"
        completionHandler:^(NSUInteger code) {
            if (code == ConnectionAccepted) {
                // when the client is connected, send a MQTT message
                [client publishString:publichString
                              toTopic:@"music"
                              withQos:AtMostOnce
                               retain:NO
                    completionHandler:^(int mid) {
                        NSLog(@"message has been delivered");
                    }];
            }
        }];
}

- (IBAction)mqttTest:(id)sender{
    // connect to the MQTT server
    [client connectToHost:@"m01.mqtt.cloud.nifty.com"
        completionHandler:^(NSUInteger code) {
            if (code == ConnectionAccepted) {
                // when the client is connected, send a MQTT message
                [client publishString:@"on"
                              toTopic:@"music"
                              withQos:AtMostOnce
                               retain:NO
                    completionHandler:^(int mid) {
                        NSLog(@"message has been delivered");
                    }];
            }
        }];
}

- (void) disconnectButtonPressed:(id) sender
{
    [[MEMELib sharedInstance] disconnectPeripheral];
}

- (void) memeRealTimeModeDataReceived: (MEMERealTimeData *)data
{
    [self blinkIndicator];
    
    //    NSLog(@"RealTime Data Received %@", [data description]);
    self.latestRealTimeData = data;
    
    if (data.roll > 8 && isVertival) {
        [self playBGM];
        
    } else if (data.roll < 0) {
        isVertival = true;
        if (isMusicPlaying) {
            [self stopBGM];
        }
    }
    
    [self.tableView reloadData];
}

- (void) blinkIndicator
{
    [UIView animateWithDuration: 0.05 animations:  ^{
        self.indicatorView.backgroundColor  = [UIColor redColor]; } completion:^(BOOL finished){
            [UIView animateWithDuration: 0.05 delay:0.25 options: 0 animations: ^{
                self.indicatorView.backgroundColor  = [UIColor whiteColor]; }  completion: nil];
        }];
}

#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataCellIdentifier" forIndexPath:indexPath];
    
    NSString *label = @"";
    NSString *value = @"";
    
    MEMERealTimeData *data = self.latestRealTimeData;
    switch (indexPath.row) {
        case 0:
            label = @"Fit Status";
            value = FORMAT_INT(data.fitError);
            break;
            
        case 1:
            label = @"Walking";
            value = FORMAT_INT(data.isWalking);
            break;
            
        case 2:
            label = @"Power Left";
            value = FORMAT_INT(data.powerLeft);
            break;
            
        case 3:
            label = @"Eye Move Up";
            value = FORMAT_INT(data.eyeMoveUp);
            break;
            
        case 4:
            label = @"Eye Move Down";
            value = FORMAT_INT(data.eyeMoveDown);
            break;
            
        case 5:
            label = @"Eye Move Left";
            value = FORMAT_INT(data.eyeMoveLeft);
            break;
            
        case 6:
            label = @"Eye Move Right";
            value = FORMAT_INT(data.eyeMoveRight);
            break;
            
        case 7:
            label = @"Blink Streangth";
            value = FORMAT_INT(data.blinkStrength);
            break;
            
        case 8:
            label = @"Blink Speed";
            value = FORMAT_INT(data.blinkSpeed);
            break;
            
        case 9:
            label = @"Roll";
            value = FORMAT_FLOAT(data.roll);
            break;
            
        case 10:
            label = @"Pitch";
            value = FORMAT_FLOAT(data.pitch);
            break;
            
        case 11:
            label = @"Yaw";
            value = FORMAT_FLOAT(data.yaw);
            break;
            
        case 12:
            label = @"Acc X";
            value = FORMAT_INT(data.accX);
            break;
            
        case 13:
            label = @"Acc Y";
            value = FORMAT_INT(data.accY);
            break;
            
        case 14:
            label = @"Acc Z";
            value = FORMAT_INT(data.accZ);
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = label;
    cell.detailTextLabel.text = value;
    
    return cell;
}

#pragma mark

- (BOOL)prefersStatusBarHidden
{
    return self.shouldBeHidingStatusBar;
}

- (IBAction)hideStatusBar
{
    self.shouldBeHidingStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
