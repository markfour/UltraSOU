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
    
    NSLog(@"WebViewController viewDidLoad");
    
    _rankingView = [[UIWebView alloc] init];
    _rankingView.frame = self.view.frame;
//    _rankingView.delegate = self;
//    _rankingView.scalesPageToFit = YES;
    [self.view addSubview:_rankingView];
    
    NSURL *url = [NSURL URLWithString:_rankingURL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_rankingView loadRequest:req];
    
//    _loadView = [[UIActivityIndicatorView alloc] init];
//    _loadView.frame = CGRectMake(0, 0, 44, 44);
//    _loadView.center = CGPointMake(160, 1136/4);
//    _loadView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    [self.view addSubview:_loadView];
//    [_loadView startAnimating];
    
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
//    [_loadView stopAnimating];
//    _loadView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)loadRanking:(NSString *)url
{

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
