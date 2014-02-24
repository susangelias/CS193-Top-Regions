//
//  PlaceID+create.m
//  Top Regions
//
//  Created by Susan Elias on 2/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PlaceID+create.h"

@implementation PlaceID (create)

+ (PlaceID *)placeWithID: (NSString *)placeID
        inManagedContext:(NSManagedObjectContext *)context
{
    PlaceID *place = nil;
  
    // see if this placeID already exists in coredata
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PlaceID"];
    NSEntityDescription *description = [ NSEntityDescription entityForName:@"PlaceID" inManagedObjectContext:context];
    [request setEntity:description];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeID = %@", placeID];
    [request setPredicate:predicate];
    
    NSArray *matches;
    NSError *error;
    
    matches = [context executeFetchRequest:request error:&error];
    
    if ((matches == nil) || ([matches count] > 1))
    {
        NSLog(@"unable to fetch PlaceID");
    }
    else if ([matches count] == 0)
    {
        // placeID doesn't exist - create one
        place = [NSEntityDescription insertNewObjectForEntityForName:@"PlaceID"
                                                     inManagedObjectContext:context];
        place.placeID = placeID;
  //      NSLog(@"created entitity place %@", place);
    }
    else
    {
        // place exists
        place = [matches firstObject];
    }

    return  place;

}

@end
