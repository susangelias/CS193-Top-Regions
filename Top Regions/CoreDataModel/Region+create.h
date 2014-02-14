//
//  Region+create.h
//  Top Regions
//
//  Created by Susan Elias on 2/14/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Region.h"
#import "Photo.h"

@interface Region (create)

+ (void )regionWithPlaceID: (NSString *)name
                    withPhoto:(Photo *)photo;

@end
