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
#define FLICKR_PHOTO_TASK @"Flickr photo fetch"
#define FLICKR_PLACE_TASK @"Flickr placeInfo fetch"

// how often (in seconds) we fetch new photos if we are in the foreground
#define FOREGROUND_FLICKR_PHOTO_FETCH_INTERVAL (20*60)
#define FOREGROUND_FLICKR_REGION_FETCH_INTERVAL (2*60)
#define LAUNCH_POPULATION_DELAY (0.5 * 60)

@interface TopRegionsAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end
