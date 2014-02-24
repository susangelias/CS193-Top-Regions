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


+ (void) loadRegionFromFlickr: (NSDictionary *)propertyListResults
           intoManagedContext: context
{
    Region *region = nil;
    
    if (context)
    {
        // fetch the information about a place from Flickr
        NSString *name = nil;
        
  //      NSLog(@"region property list %@", propertyListResults);
        
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
            
             NSArray *matches;
            NSError *error;
            matches = [context executeFetchRequest:request error:&error];
            
            if ((matches == nil) || ([matches count] > 1))
            {
                NSLog(@"UNABLE TO FETCH REGION");
            }
            else if ([matches count] == 0)
            {
                // region doesn't exist - create one
                region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                             inManagedObjectContext:context];
                region.name = name;
                NSLog(@"created region %@", name);
                /*
               Photographer *photographer = photo.whoTook;
                if (photographer) {
                    [region addPhotographersObject:photographer];
                    region.numberOfPhotographers= [NSNumber numberWithInt:(int)1];
                }
                photo.regionName = name;
                 */
            }
            else
            {
                // region exists 
                region = [matches firstObject];
                /*
                if (![region.photographers containsObject:photo.whoTook]) {     // photographer is not already on the regions list of photographers
                    Photographer *photographer = photo.whoTook;
                    if (photographer) {
                        [region addPhotographersObject:photographer];
                        region.numberOfPhotographers= [NSNumber numberWithInt:[region.numberOfPhotographers intValue] + (int)1];
                    }
                 */
               }
          //      photo.regionName = name;
            }

    }
    
}

-  (NSString *)regionNameFromPlaceID: (NSString *)placeID
{
    NSString *regionName   = nil;
    
    return regionName;
    
}

@end
