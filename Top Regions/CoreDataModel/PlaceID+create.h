//
//  PlaceID+create.h
//  Top Regions
//
//  Created by Susan Elias on 2/21/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PlaceID.h"

@interface PlaceID (create)


+ (PlaceID *)placeWithID: (NSString *)placeID
                      inManagedContext:(NSManagedObjectContext *)context;

@end
