//
//  Photo.h
//  Top Regions
//
//  Created by Susan Elias on 2/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, PlaceID;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * uploadDate;
@property (nonatomic, retain) NSDate * viewedDate;
@property (nonatomic, retain) PlaceID *whereTook;
@property (nonatomic, retain) Photographer *whoTook;

@end
