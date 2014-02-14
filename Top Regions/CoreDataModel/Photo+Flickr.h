//
//  Photo+Flickr.h
//  Top Regions
//
//  Created by Susan Elias on 2/13/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext: (NSManagedObjectContext *)context;

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
