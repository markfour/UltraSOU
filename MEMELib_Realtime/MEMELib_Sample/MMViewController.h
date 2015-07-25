//
//  MMViewController.h
//  
//
//  Created by JINS MEME on 8/11/14.
//  Copyright (c) 2014 JIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MEMELib/MEMELib.h>

#import "MMDataViewController.h"

@interface MMViewController : UIViewController <MEMELibDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView  *peripheralListTableView;
@property (strong, nonatomic) MMDataViewController  *dataViewCtl;
@property (strong, nonatomic) UIView *debugView;

- (IBAction) scanButtonPressed:(id)sender;

@end
