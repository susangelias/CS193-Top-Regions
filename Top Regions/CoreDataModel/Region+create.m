//
//  Region+create.m
//  Top Regions
//
//  Created by Susan Elias on 2/14/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Region+create.h"
#import "FlickrFetcher.h"



@implementation Region (create)


+ (void) regionWithPlaceID: (NSString *)placeID
                 withPhoto:(Photo *)photo
{
    __block Region *region = nil;
    NSManagedObjectContext *context = [photo managedObjectContext];
    
    if (context)
    {
        // fetch the information about a place from Flickr
        __block NSString *name = nil;
        
        NSURL *url = [FlickrFetcher URLforInformationAboutPlace:placeID];
        // create a non-main queue to do the fetch on
        dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Region Fetcher", NULL);
        dispatch_async(fetchQ, ^{
            // fetch the json data from Flickr
            NSData *jsonResults = [NSData dataWithContentsOfURL:url];
            // put it into a property list
            NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                                options:0
                                                                                  error:NULL];
            // Pull the place information out of the propertyList
            name = [FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResults];
            if (name)
            {
                // see if this region already exists
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
                NSEntityDescription *description = [ NSEntityDescription entityForName:@"Region" inManagedObjectContext:context];
                [request setEntity:description];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
                [request setPredicate:predicate];
                
                NSError *error;
                NSArray *matches = [context executeFetchRequest:request error:&error];
                
                if ((matches == nil) || ([matches count] > 1))
                {
                    // handle error
                }
                else if ([matches count] == 0)
                {
                    // region doesn't exist - create one
                    region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                                 inManagedObjectContext:context];
                    region.name = name;
                    region.photos = [NSSet setWithObject:photo];    // create a new set with 1 object
                    region.photographers = [NSSet setWithObject:photo.whoTook];
                }
                else
                {
                    // region exists - add more photos and photographers to its relationships
                    region = [matches firstObject];
                    [region.photos setByAddingObject:photo];    // create a new set by adding an object to the existing set
                    [region.photographers setByAddingObject:photo.whoTook];
                }
            }
        });

    }
    
    
}


@end
