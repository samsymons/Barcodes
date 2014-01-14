//
//  SOSBrowserViewController.m
//  Barcodes
//
//  Created by Sam Symons on 1/14/2014.
//  Copyright (c) 2014 Sam Symons. All rights reserved.
//

#import "SOSBrowserViewController.h"

@interface SOSBrowserViewController ()

@property (nonatomic, copy) NSString *searchQuery;
@property (nonatomic, strong) UIWebView *webView;

- (void)searchWithQuery:(NSString *)query;
- (void)dismiss;

@end

@implementation SOSBrowserViewController

- (instancetype)initWithSearch:(NSString *)query
{
    if ([super initWithNibName:nil bundle:nil])
    {
        self.title = NSLocalizedString(@"Product Search", @"Product Search");
        
        _searchQuery = query;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
	self.navigationItem.rightBarButtonItem = doneButton;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [[self view] addSubview:self.webView];
    
    [self searchWithQuery:self.searchQuery];
}

#pragma mark - Private

- (void)searchWithQuery:(NSString *)query
{
    NSString *fullQueryString = [NSString stringWithFormat:@"https://duckduckgo.com/?q=%@", [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *searchURL = [NSURL URLWithString:fullQueryString];
    
    [[self webView] loadRequest:[NSURLRequest requestWithURL:searchURL]];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kShouldBeginCapturingMetadataNotification object:nil];
    }];
}

@end
