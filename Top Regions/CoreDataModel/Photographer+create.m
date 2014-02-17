//
//  Photographer+create.m
//  Top Regions
//
//  Created by Susan Elias on 2/14/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Photographer+create.h"


@implementation Photographer (create)

// check our core data for the photographer with the given name
// if the photographer doesn't exist yet - create it

+ (Photographer *)photographerWithName: (NSString *)name
                      inManagedContext:(NSManagedObjectContext *)context
{
    __block Photographer *photographer = nil;
    
    if (context)
    {
        // see if this photographer already exists
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        NSEntityDescription *description = [ NSEntityDescription entityForName:@"Photographer" inManagedObjectContext:context];
        [request setEntity:description];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        [request setPredicate:predicate];
        
        __block NSArray *matches;
        __block NSError *error;
        [context performBlock:^{
            matches = [context executeFetchRequest:request error:&error];
        
            if ((matches == nil) || ([matches count] > 1))
            {
                // handle error
            }
            else if ([matches count] == 0)
            {
                // photographer doesn't exist - create one
                photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer"
                                                             inManagedObjectContext:context];
                photographer.name = name;
            }
            else
            {
                // photographer exists
                photographer = [matches firstObject];
            }
        }];
        
    }
   
    return photographer;
    
}

@end
