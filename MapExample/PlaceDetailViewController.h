//
//  PlaceDetailViewController.h
//  MapExample
//
//  Created by Erick Bennett on 1/26/15.
//  Copyright (c) 2015 Erick Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface PlaceDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property NSString *urlString;

@end
