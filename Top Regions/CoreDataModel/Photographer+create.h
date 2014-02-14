//
//  Photographer+create.h
//  Top Regions
//
//  Created by Susan Elias on 2/14/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (create)

+ (Photographer *)photographerWithName: (NSString *)name
                      inManagedContext:(NSManagedObjectContext *)context;

@end
