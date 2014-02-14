//
//  MostRecentPhotosTVCViewController.m
//  TopPlaces
//
//  Created by Susan Elias on 2/9/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "MostRecentPhotosTVC.h"
#import "FlickrFetcher.h"

@interface MostRecentPhotosTVC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *iPadNav;

@end

@implementation MostRecentPhotosTVC

#pragma  mark Initializations



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // get our list of recent photos
 
    // set our segment control "navigator" to the correct highlight
    [self.iPadNav setSelectedSegmentIndex:1];
    
}


#pragma mark - Table view data source



#pragma mark - Navigation



@end
