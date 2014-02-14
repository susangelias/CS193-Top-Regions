//
//  PlacePhotosTVC.m
//  TopPlaces
//
//  Created by Susan Elias on 2/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "SpecificPlacePhotosTVC.h"
#import "FlickrFetcher.h"

@implementation SpecificPlacePhotosTVC

#pragma mark   TableViewController DataSource

- (void) fetchPhotos
{
    [self.refreshControl beginRefreshing];          // start the spinner

    // create a non-main queue to do the fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetcher", NULL);
    dispatch_async(fetchQ, ^{
        // fetch the json data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:self.url];
        // put it into a property list
        NSDictionary *propertyListResults;
        if (jsonResults) {
            propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        }
        
        // Pull the place information out of the propertyList
        NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        // Update the model (and thus the UI) must be done in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];        // stop the spinner
            self.photos = photos;
        });
        
    });
    //  NSLog(@"Flickr results = %@", propertyListResults);
    //  NSLog(@"place results = %@", self.places);
    
}

#pragma mark TableViewController Delegate

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchPhotos];
    
    // display custom navigation title
    self.navigationItem.title = self.placeName;
    
}


@end
