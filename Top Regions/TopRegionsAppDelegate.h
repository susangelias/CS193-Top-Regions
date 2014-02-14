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

@interface TopRegionsAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end
