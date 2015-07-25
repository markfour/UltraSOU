//
//  MMDataViewController.m
//  MEMELib_Sample
//
//  Created by JINS MEME on 2015/03/30.
//  Copyright (c) 2015 JINS MEME. All rights reserved.
//

#import "MMDataViewController.h"
#import <MEMELib/MEMELib.h>
#import <AudioToolbox/AudioServices.h>
#import "MMViewController.h"
#import <AVFoundation/AVFoundation.h>


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
    
    // Data Commmunication Indicator
    self.indicatorView                  = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 24, 24)];
    self.indicatorView.alpha            = 0.20;
    self.indicatorView.backgroundColor  = [UIColor whiteColor];
    self.indicatorView.layer.cornerRadius = self.indicatorView.frame.size.height * 0.5;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.indicatorView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Disconnect" style:UIBarButtonItemStylePlain target: self action:@selector(disconnectButtonPressed:)];
    
    _debugView = [[UIView alloc] init];
    [self.view addSubview:_debugView];
    
    {
        UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [nextButton addTarget:self action:@selector(mqttTest:) forControlEvents:UIControlEventTouchDown];
        [nextButton setTitle:@"MQTT" forState:UIControlStateNormal];
        nextButton.frame = CGRectMake(0, 0, 160, 44);
        [_debugView addSubview:nextButton];
    }
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton addTarget:self action:@selector(mqttTest:) forControlEvents:UIControlEventTouchDown];
    [nextButton setTitle:@"MQTT" forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(0, 44, 160, 44);
    [_debugView addSubview:nextButton];
    
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
        NSString *filePath = [mainBundle pathForResource:@"hi" ofType:@"mp3"];
        NSURL *fileUrl  = [NSURL fileURLWithPath:filePath];
        
        NSError* error = nil;
        _auidoIntro = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
        [_auidoIntro prepareToPlay];
    }
    
    // create the client with a unique client ID
    NSString *clientID = @"ultra-user";
    MQTTClient *client = [[MQTTClient alloc] initWithClientId:clientID];
    client.username = @"ultra-user";
    client.password = @"ultra-user";
    client.port = 16056;
    
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
    
    [client setMessageHandler:^(MQTTMessage *message) {
        //        NSString *text = [message.payloadString];
        NSLog(@"received message %@", message.payloadString);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _debugView.frame = CGRectMake(0, 0, 320, 88);
    
    [self.view bringSubviewToFront:_debugView];
}

- (IBAction)mqttTest:(id)sender {
//    [self performSegueWithIdentifier:@"DataViewSegue" sender: self];
}

- (void) disconnectButtonPressed:(id) sender
{
    [[MEMELib sharedInstance] disconnectPeripheral];
}

- (void) memeRealTimeModeDataReceived: (MEMERealTimeData *)data
{
    [self blinkIndicator];
    
    NSLog(@"RealTime Data Received %@", [data description]);
    self.latestRealTimeData = data;
    
    if (data.blinkStrength > 0) {
        NSLog(@"Ultra SOU!");
        [_auidoIntro stop];
        _auidoIntro.currentTime = 0;
        [_auidoIntro play];
    }
    
    if (data.roll > 8 && isVertival) {
        isVertival = false;
        [_auidoIntro stop];
        _auidoIntro.currentTime = 0;
        [_auidoIntro play];
    } else if (data.roll < 0) {
        isVertival = true;
        if ([_auidoIntro isPlaying]) {
            //            NSTimeInterval score = _auidoIntro.currentTime;
            //            NSLog(@"score %d");
            
            [_auidoIntro stop];
            
            _audioHai.currentTime = 0;
            [_audioHai play];
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


@end
