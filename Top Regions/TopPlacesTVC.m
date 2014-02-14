//
//  TopPlacesTVCViewController.m
//  TopPlaces
//
//  Created by Susan Elias on 2/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrFetcher.h"

@interface TopPlacesTVC ()


@end

@implementation TopPlacesTVC


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchPlaces];
}

- (void) fetchPlaces
{
    [self.refreshControl beginRefreshing];          // start the spinner
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    // create a non-main queue to do the fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetcher", NULL);
    dispatch_async(fetchQ, ^{
        // fetch the json data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        // put it into a property list
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                        options:0
                                                                        error:NULL];
        // Pull the place information out of the propertyList
        NSArray *places = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        // Update the model (and thus the UI) must be done in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];        // stop the spinner
            self.places = places;
        });

    });
  //  NSLog(@"Flickr results = %@", propertyListResults);
  //  NSLog(@"place results = %@", self.places);

}



@end
