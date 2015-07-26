//
//  WebViewController.m
//  MEMELib_RealTime
//
//  Created by HayashidaKazumi on 2015/07/26.
//  Copyright (c) 2015年 JINS MEME. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _rankingView = [[UIWebView alloc] init];
    _rankingView.frame = self.view.frame;
    _rankingView.delegate = self;
//    _rankingView.scalesPageToFit = YES;
    [self.view addSubview:_rankingView];
    
    NSURL *url = [NSURL URLWithString:_rankingURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_rankingView loadRequest:req];
    
    _indicatorView = [[UIActivityIndicatorView alloc] init];
    _indicatorView.frame = CGRectMake(0, 0, 44, 44);
    _indicatorView.center = CGPointMake(160, 1136/4);
    _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:_indicatorView];
    [_indicatorView startAnimating];

    {
        _debugCloseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_debugCloseButton addTarget:self action:@selector(dismissRanking) forControlEvents:UIControlEventTouchDown];
        [_debugCloseButton setTitle:@"" forState:UIControlStateNormal];
        _debugCloseButton.frame = CGRectMake(0, 0, 320, 88);
        [self.view addSubview:_debugCloseButton];
    }
    
    [self hideStatusBar];
}
//
- (void)dismissRanking {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [_indicatorView stopAnimating];
    _indicatorView.hidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return self.shouldBeHidingStatusBar;
}

- (IBAction)hideStatusBar
{
    self.shouldBeHidingStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
