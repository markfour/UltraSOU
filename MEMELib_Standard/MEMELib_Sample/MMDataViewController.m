//
//  MMDataViewController.m
//  MEMELib_Sample
//
//  Created by JINS MEME on 2015/03/30.
//  Copyright (c) 2015 JINS MEME. All rights reserved.
//

#import "MMDataViewController.h"
#import <MEMELib/MEMELib.h>
#import "MMViewController.h"

@interface MMDataViewController ()

@property (nonatomic, strong) UIView    *indicatorView;

@property (strong, nonatomic) MEMEStandardData *latestStandardData;

@end

@implementation MMDataViewController
{
    NSDateFormatter  *dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title      = @"Standard Data";
    
    // Data Commmunication Indicator
    self.indicatorView                  = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 24, 24)];
    self.indicatorView.alpha            = 0.20;
    self.indicatorView.backgroundColor  = [UIColor whiteColor];
    self.indicatorView.layer.cornerRadius = self.indicatorView.frame.size.height * 0.5;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.indicatorView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Disconnect" style:UIBarButtonItemStylePlain target: self action:@selector(disconnectButtonPressed:)];
    
    // Date formatter for timestamp
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

}

- (void) disconnectButtonPressed:(id) sender
{
    [[MEMELib sharedInstance] disconnectPeripheral];
}

- (void) memeStandardModeDataReceived: (MEMEStandardData *)data
{
    [self blinkIndicator];
    
    NSLog(@"Standard Data Received %@", [data description]);
    self.latestStandardData = data;
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
    return 47;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DataCellIdentifier" forIndexPath:indexPath];
    
    NSString *label = @"";
    NSString *value = @"";
  
    MEMEStandardData *data = self.latestStandardData;
    
    switch (indexPath.row) {
        case 0:
            label = @"Focus Level";
            value = FORMAT_INT(data.focus);
            break;
        case 1:
            label = @"Sleepiness Level";
            value = FORMAT_INT(data.sleepy);
            break;
        case 2:
            label = @"Is EOG Valid";
            value = FORMAT_INT(data.isEOGValid);
            break;
        case 3:
            label = @"Blink Strength";
            value = FORMAT_INT(data.blinkStrength);
            break;
            
        case 4:
            label = @"Blink Speed";
            value = FORMAT_INT(data.blinkSpeed);
            break;
            
        case 5:
            label = @"# of Blink";
            value = FORMAT_INT(data.numBlinks);
            break;
            
        case 6:
            label = @"# of Blink Burst";
            value = FORMAT_INT(data.numBlinksBurst);
            break;
            
        case 7:
            label = @"Foot Fold Left";
            value = FORMAT_INT(data.footholdLeft);
            break;
            
        case 8:
            label = @"Foot Fold Right";
            value = FORMAT_INT(data.footholdRight);
            break;
            
        case 9:
            label = @"Pitch Diff";
            value = FORMAT_FLOAT(data.pitchDiff);
            break;
            
        case 10:
            label = @"Pitch Average";
            value = FORMAT_FLOAT(data.pitchAvg);
            break;
            
        case 11:
            label = @"Roll Diff";
            value = FORMAT_FLOAT(data.rollDiff);
            break;
            
        case 12:
            label = @"Roll Average";
            value = FORMAT_FLOAT(data.rollAvg);
            break;
            
        case 13:
            label = @"# of Steps (280)";
            value = FORMAT_INT(data.numSteps280);
            break;
        case 14:
            label = @"# of Steps (310)";
            value = FORMAT_INT(data.numSteps310);
            break;
        case 15:
            label = @"# of Steps (340)";
            value = FORMAT_INT(data.numSteps340);
            break;
        case 16:
            label = @"# of Steps (370)";
            value = FORMAT_INT(data.numSteps370);
            break;
        case 17:
            label = @"# of Steps (400)";
            value = FORMAT_INT(data.numSteps400);
            break;
        case 18:
            label = @"# of Steps (430)";
            value = FORMAT_INT(data.numSteps430);
            break;
        case 19:
            label = @"# of Steps (460)";
            value = FORMAT_INT(data.numSteps460);
            break;
        case 20:
            label = @"# of Steps (500)";
            value = FORMAT_INT(data.numSteps500);
            break;
        case 21:
            label = @"# of Steps (530)";
            value = FORMAT_INT(data.numSteps530);
            break;
        case 22:
            label = @"# of Steps (560)";
            value = FORMAT_INT(data.numSteps560);
            break;
        case 23:
            label = @"# of Steps (590)";
            value = FORMAT_INT(data.numSteps590);
            break;
        case 24:
            label = @"# of Steps (620)";
            value = FORMAT_INT(data.numSteps620);
            break;
        case 25:
            label = @"# of Steps (650)";
            value = FORMAT_INT(data.numSteps650);
            break;
        case 26:
            label = @"# of Steps (680)";
            value = FORMAT_INT(data.numSteps680);
            break;
        case 27:
            label = @"# of Steps (710)";
            value = FORMAT_INT(data.numSteps710);
            break;
        case 28:
            label = @"# of Steps (750)";
            value = FORMAT_INT(data.numSteps750);
            break;
        case 29:
            label = @"# of Steps (780)";
            value = FORMAT_INT(data.numSteps780);
            break;
        case 30:
            label = @"# of Steps (810)";
            value = FORMAT_INT(data.numSteps810);
            break;
        case 31:
            label = @"# of Steps (840)";
            value = FORMAT_INT(data.numSteps840);
            break;
        case 32:
            label = @"# of Steps (870)";
            value = FORMAT_INT(data.numSteps870);
            break;
        case 33:
            label = @"# of Steps (900)";
            value = FORMAT_INT(data.numSteps900);
            break;
        case 34:
            label = @"# of Steps (930)";
            value = FORMAT_INT(data.numSteps930);
            break;
        case 35:
            label = @"# of Steps (960)";
            value = FORMAT_INT(data.numSteps960);
            break;
        case 36:
            label = @"# of Steps (1000)";
            value = FORMAT_INT(data.numSteps1000);
            break;
        case 37:
            label = @"Body Vertical Move";
            value = FORMAT_INT(data.bodyMoveVertical);
            break;
        case 38:
            label = @"cadence";
            value = FORMAT_INT(data.cadence);
            break;
        case 39:
            label = @"Vertical Eye Move";
            value = FORMAT_INT(data.eyeMoveVertical);
            break;
            
        case 40:
            label = @"Horizontal Eye Move";
            value = FORMAT_INT(data.eyeMoveHorizontal);
            break;
            
        case 41:
            label = @"Big Vertical Eye Move";
            value = FORMAT_INT(data.eyeMoveBigVertical);
            break;
            
        case 42:
            label = @"Big Horizontal Eye Move";
            value = FORMAT_INT(data.eyeMoveBigHorizontal);
            break;
            
        case 43:
            label = @"Power Left";
            value = FORMAT_INT(data.powerLeft);
            break;
            
        case 44:
            label = @"Fit Status";
            value = FORMAT_INT(data.fitError);
            break;
            
        case 45:
            label = @"EOG Noise Duration";
            value = FORMAT_INT(data.EOGNoiseDuration);
            break;
            
        case 46:
            label = @"Timestamp";
            value = [dateFormatter stringFromDate: data.capturedAt];
            break;
        default:
            break;
    }
    
    cell.textLabel.text = label;
    cell.detailTextLabel.text = value;
    
    return cell;
}


@end
