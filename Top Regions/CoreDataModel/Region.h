//
//  Region.h
//  Top Regions
//
//  Created by Susan Elias on 2/17/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberOfPhotographers;
@property (nonatomic, retain) NSString * placeID;
@property (nonatomic, retain) NSSet *photographers;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotographersObject:(Photographer *)value;
- (void)removePhotographersObject:(Photographer *)value;
- (void)addPhotographers:(NSSet *)values;
- (void)removePhotographers:(NSSet *)values;

@end
