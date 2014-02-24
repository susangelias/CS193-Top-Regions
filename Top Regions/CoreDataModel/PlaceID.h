//
//  PlaceID.h
//  Top Regions
//
//  Created by Susan Elias on 2/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface PlaceID : NSManagedObject

@property (nonatomic, retain) NSString * placeID;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) NSSet *region;
@end

@interface PlaceID (CoreDataGeneratedAccessors)

- (void)addRegionObject:(Region *)value;
- (void)removeRegionObject:(Region *)value;
- (void)addRegion:(NSSet *)values;
- (void)removeRegion:(NSSet *)values;

@end
