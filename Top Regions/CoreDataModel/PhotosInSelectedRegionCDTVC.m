//
//  PhotosInSelectedRegionCDTVC.m
//  Top Regions
//
//  Created by Susan Elias on 2/15/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PhotosInSelectedRegionCDTVC.h"
#import "Photo.h"
#import "ImageViewController.h"
#import "Photographer.h"


@interface PhotosInSelectedRegionCDTVC ()

@property NSArray *sortedPhotos;

@end

@implementation PhotosInSelectedRegionCDTVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    if (self.selectedRegion) {
        // set title to the region name
        self.navigationItem.title = self.selectedRegion.name;
        
        // Set up fetch request for this view from our core data
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY whereTook.region.name =  %@", self.selectedRegion.name   ];
        NSSortDescriptor *byUploadDate = [NSSortDescriptor sortDescriptorWithKey:@"uploadDate"
                                                                  ascending:NO
                                                                   selector:@selector(compare:)];
        /*
        NSSortDescriptor *bySubTitle = [NSSortDescriptor sortDescriptorWithKey:@"subtitle"
                                                                     ascending:YES
                                                                      selector:@selector(localizedStandardCompare:)];
        NSSortDescriptor *byPhotographer = [NSSortDescriptor sortDescriptorWithKey:@"whoTook"
                                                                         ascending:YES
                                                                          selector:@selector(localizedStandardCompare:)];
         */
        request.sortDescriptors = @[byUploadDate];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                           managedObjectContext:self.selectedRegion.managedObjectContext                                                                        sectionNameKeyPath:nil
                                                                                      cacheName:nil ];
    }
    else {
        NSLog(@"Segue failed to set selectedRegion");
    }
    
}




@end
