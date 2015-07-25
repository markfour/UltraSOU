//
//  MMViewController.m
//  
//
//  Created by JINS MEME on 8/11/14.
//  Copyright (c) 2014 JIN. All rights reserved.
//

#import "MMViewController.h"
#import <MEMELib/MEMELib.h>

@interface MMViewController ()

@property (nonatomic, strong) NSMutableArray *peripheralsFound;

@end

@implementation MMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [MEMELib sharedInstance].delegate = self;
    [[MEMELib sharedInstance] addObserver: self forKeyPath: @"centralManagerEnabled" options: NSKeyValueObservingOptionNew context:nil];
    
    self.peripheralsFound = @[].mutableCopy;
    
    self.title      = @"MEME Demo";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Scan" style:UIBarButtonItemStylePlain target: self action:@selector(scanButtonPressed:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString: @"centralManagerEnabled"]){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButtonPressed:(id)sender {
    // Start Scanning
    MEMEStatus status = [[MEMELib sharedInstance] startScanningPeripherals];
    [self checkMEMEStatus: status];
}

#pragma mark
#pragma mark MEMELib Delegates

- (void) memePeripheralFound: (CBPeripheral *) peripheral;
{
    [self.peripheralsFound addObject: peripheral];
    NSLog(@"peripheral found %@", [peripheral.identifier UUIDString]);
    [self.peripheralListTableView reloadData];
}

- (void) memePeripheralConnected: (CBPeripheral *)peripheral
{
    NSLog(@"MEME Device Connected!");
    
    self.navigationItem.rightBarButtonItem.enabled         = NO;
    self.peripheralListTableView.userInteractionEnabled = NO;
    [self performSegueWithIdentifier:@"DataViewSegue" sender: self];
    
    // Set Data Mode to Standard Mode
    [[MEMELib sharedInstance] changeDataMode: MEME_COM_STANDARD];
}

- (void) memePeripheralDisconnected: (CBPeripheral *)peripheral
{
    self.navigationItem.rightBarButtonItem.enabled       = YES;
    self.peripheralListTableView.userInteractionEnabled = YES;
    
    [self dismissViewControllerAnimated: YES completion: ^{
        self.dataViewCtl = nil;
        NSLog(@"MEME Device Disconnected");

    }];
}


- (void) memeStandardModeDataReceived: (MEMEStandardData *) data
{
    if (self.dataViewCtl) [self.dataViewCtl memeStandardModeDataReceived: data];
}


- (void) memeRealTimeModeDataReceived: (MEMERealTimeData *) data
{
    
}

- (void) memeDataModeChanged:(MEMEDataMode)mode
{
    
    
}

- (void) memeAppAuthorized:(MEMEStatus)status
{
    [self checkMEMEStatus: status];
}

#pragma mark
#pragma mark Peripheral List

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.peripheralsFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"DeviceListCellIdentifier"];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"DeviceListCellIdentifier"];
    }
    
    CBPeripheral *peripheral = [self.peripheralsFound objectAtIndex: indexPath.row];
    cell.textLabel.text = [peripheral.identifier UUIDString];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     CBPeripheral *peripheral = [self.peripheralsFound objectAtIndex: indexPath.row];
     MEMEStatus status = [[MEMELib sharedInstance] connectPeripheral: peripheral ];
    [self checkMEMEStatus: status];
    
    NSLog(@"Start connecting to MEME Device...");
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"DataViewSegue"]){
        UINavigationController *naviCtl = segue.destinationViewController;
        self.dataViewCtl                = (MMDataViewController *)naviCtl.topViewController;
    }
}

#pragma mark UTILITY

- (void) checkMEMEStatus: (MEMEStatus) status
{
    if (status == MEME_ERROR_APP_AUTH){
        [[[UIAlertView alloc] initWithTitle: @"App Auth Failed" message: @"Invalid Application ID or Client Secret " delegate: nil cancelButtonTitle: nil otherButtonTitles: @"OK", nil] show];
    } else if (status == MEME_ERROR_SDK_AUTH){
        [[[UIAlertView alloc] initWithTitle: @"SDK Auth Failed" message: @"Invalid SDK. Please update to the latest SDK." delegate: nil cancelButtonTitle: nil otherButtonTitles: @"OK", nil] show];
    } else if (status == MEME_OK){
        NSLog(@"Status: MEME_OK");
    }
}



@end
