//
//  MostRecentCDTVC.m
//  Top Regions
//
//  Created by Susan Elias on 2/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "MostRecentCDTVC.h"
#import "Photo.h"
#import "ImageViewController.h"
#import "TopRegionsAppDelegate.h"


@implementation MostRecentCDTVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Ask appDelegate for our managed context
    if (!self.context)
    {
        TopRegionsAppDelegate *appDelegate = (TopRegionsAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.context = appDelegate.context;
    }
    // Set up fetch request for this view from our core data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"viewedDate !=  nil" ];
    NSSortDescriptor *byViewedDate = [NSSortDescriptor sortDescriptorWithKey:@"viewedDate"
                                                                   ascending:NO
                                                                    selector:@selector(compare:)];
    request.fetchLimit = 50;
    request.sortDescriptors = @[byViewedDate];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                       managedObjectContext:self.context                                                                        sectionNameKeyPath:nil
                                                                                  cacheName:nil ];
    
}


@end
