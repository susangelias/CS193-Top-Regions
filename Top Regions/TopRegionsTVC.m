//
//  TopRegionsViewController.m
//  Top Regions
//
//  Created by Susan Elias on 2/12/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "TopRegionsTVC.h"
#import "TopRegionsAppDelegate.h"

@interface TopRegionsTVC ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation TopRegionsTVC



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // get our application's shared managed context via a notification from the appDelegate when it is ready to go
    if (!self.context)
    {
        // context not set up yet so sign up to receive notification when it is ready
        NSLog(@"signing up to receiver context ready notification from app delegate");
        __block TopRegionsTVC *weakSelf = self;  // avoid a retain cycle
        [[NSNotificationCenter defaultCenter] addObserverForName:ContextReady
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          weakSelf.context = note.userInfo [PhotoDatabaseAvailabilityContext];
                                                          NSLog(@"received context from appDelegate %@", weakSelf.context);
                                                      }];
      }
    else
    {
        // REMOVE SELF FROM NOTIFICATION REGARDING CONTEXT READY
        // since I don't use any other notifications just remove from all notifications
#warning figure out when to remove self from notification center
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
