//
//  WebViewController.h
//  MEMELib_RealTime
//
//  Created by HayashidaKazumi on 2015/07/26.
//  Copyright (c) 2015年 JINS MEME. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (retain, nonatomic) NSString *rankingURL;
@property (retain, nonatomic) UIWebView *rankingView;
@property (retain, nonatomic) UIButton *debugCloseButton;
@property (retain, nonatomic) UIActivityIndicatorView *indicatorView;

@property BOOL shouldBeHidingStatusBar;

@end
