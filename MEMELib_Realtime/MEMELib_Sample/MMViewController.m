//
//  MMViewController.m
//
//
//  Created by JINS MEME on 8/11/14.
//  Copyright (c) 2014 JIN. All rights reserved.
//

#import "MMViewController.h"


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
    
    _debugView = [[UIView alloc] init];
    _debugView.backgroundColor = [UIColor grayColor];
    _debugView.alpha = 0.8;
    [self.view addSubview:_debugView];
    
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] init];
    ai.frame = CGRectMake(160 - 22, 0, 44, 44);
    ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_debugView addSubview:ai];
    [ai startAnimating];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton addTarget:self action:@selector(nextButtonTap:) forControlEvents:UIControlEventTouchDown];
    [nextButton setTitle:@"Next" forState:UIControlStateNormal];
    nextButton.frame = CGRectMake(0, 44, 320, 44);
    [_debugView addSubview:nextButton];
    
    [[MEMELib sharedInstance] disconnectPeripheral];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _debugView.frame = CGRectMake(0, 60, 320, 88);
    
    [self.view bringSubviewToFront:_debugView];
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


- (IBAction)nextButtonTap:(id)sender {
    [self performSegueWithIdentifier:@"DataViewSegue" sender: self];
}

- (IBAction)scanButtonPressed:(id)sender {
    // Start Scanning
    [_peripheralsFound removeAllObjects];
    
    MEMEStatus status = [[MEMELib sharedInstance] startScanningPeripherals];
    [self checkMEMEStatus: status];
}

#pragma mark
#pragma mark MEMELib Delegates

- (void) memePeripheralFound: (CBPeripheral *) peripheral;
{
    [self.peripheralsFound addObject: peripheral];
//    NSLog(@"peripheral found %@", [peripheral.identifier UUIDString]);
    [self.peripheralListTableView reloadData];
    
    if ([[peripheral.identifier UUIDString] isEqualToString:@"D32FB8FC-3EBF-639D-C664-8DD0C19CB6D6"]) {
        NSLog(@"My device found start connect");
        MEMEStatus status = [[MEMELib sharedInstance] connectPeripheral: peripheral];
        [self checkMEMEStatus: status];
    }
}

- (void) memePeripheralConnected: (CBPeripheral *)peripheral
{
    NSLog(@"MEME Device Connected!");
    
    self.navigationItem.rightBarButtonItem.enabled         = NO;
    self.peripheralListTableView.userInteractionEnabled = NO;
    [self performSegueWithIdentifier:@"DataViewSegue" sender: self];
    
    // Set Data Mode to Standard Mode
    [[MEMELib sharedInstance] changeDataMode: MEME_COM_REALTIME];
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
}


- (void) memeRealTimeModeDataReceived: (MEMERealTimeData *) data
{
    if (self.dataViewCtl) [self.dataViewCtl memeRealTimeModeDataReceived: data];
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
