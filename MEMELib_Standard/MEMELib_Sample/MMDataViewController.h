//
//  MMDataViewController.h
//  MEMELib_Sample
//
//  Created by JINS MEME on 2015/03/30.
//  Copyright (c) 2015 JINS MEME. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MEMELib/MEMELib.h>

@class MMViewController;

@interface MMDataViewController : UITableViewController

- (void) memeStandardModeDataReceived: (MEMEStandardData *)data;

@end
