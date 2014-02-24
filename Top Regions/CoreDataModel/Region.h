//
//  Region.h
//  Top Regions
//
//  Created by Susan Elias on 2/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, PlaceID;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfPhotographers;
@property (nonatomic, retain) NSSet *photographers;
@property (nonatomic, retain) NSSet *placeIDs;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotographersObject:(Photographer *)value;
- (void)removePhotographersObject:(Photographer *)value;
- (void)addPhotographers:(NSSet *)values;
- (void)removePhotographers:(NSSet *)values;

- (void)addPlaceIDsObject:(PlaceID *)value;
- (void)removePlaceIDsObject:(PlaceID *)value;
- (void)addPlaceIDs:(NSSet *)values;
- (void)removePlaceIDs:(NSSet *)values;

@end
