//
//  TopRegionsAppDelegate.h
//  Top Regions
//
//  Created by Susan Elias on 2/12/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const ContextReady;
#define PhotoDatabaseAvailabilityContext @"Context"
#define FLICKR_FETCH @"Flickr just uploaded fetch"
// how often (in seconds) we fetch new photos if we are in the foreground
//#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)
// how often (in seconds) we fetch new photos if we are in the foreground
#define FOREGROUND_FLICKR_FETCH_INTERVAL (.5*60)

@interface TopRegionsAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end
