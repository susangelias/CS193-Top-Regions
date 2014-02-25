//
//  Photo+Flickr.m
//  Top Regions
//
//  Created by Susan Elias on 2/13/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+create.h"
#import "Region+create.h"
#import "PlaceID+create.h"


@implementation Photo (Flickr)

// called from the appDelegate from within a [context performBlock...

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext: (NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *photoID = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoID = %@", photoID];
    
    NSArray *matches;
    NSError *error;

    matches = [context executeFetchRequest:request error:&error];

    if (!matches || error || ([matches count] > 1))
    {
        NSLog(@"photoWithFlickrInfo: error in executeFetchRequest %@", error);
    }
    else if ([matches count])
    {
        photo = [matches firstObject];
    }
    else
    {   // only store photos that have placeIDs
        if ([photoDictionary valueForKeyPath:FLICKR_PLACE_ID])
        {
            photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            photo.photoID = photoID;
            photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
            photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
            photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge]absoluteString];
            photo.thumbnail = nil;
            photo.thumbnailURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatSquare]absoluteString];
            double uploadTime = [[photoDictionary valueForKey:FLICKR_PHOTO_UPLOAD_DATE]doubleValue];
      //      NSLog(@"upLoadDate %f",uploadTime);
            photo.uploadDate = [NSDate dateWithTimeIntervalSince1970:uploadTime];
      //      NSLog(@"photo.uploadDate %@", photo.uploadDate);
            
            NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
            photo.whoTook = [Photographer photographerWithName:photographerName inManagedContext:context];
            [photo.whoTook addPhotosObject:photo];
            
            photo.whereTook = [PlaceID placeWithID:[photoDictionary valueForKeyPath:FLICKR_PLACE_ID] inManagedContext:context];
            photo.whereTook.photo  = photo;
        }
    }

    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    // store every photo from the download into core data if it is not already in core data
    // Fetch all the photoIDs from core data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoID != nil"];
    NSArray *matches;
    NSError *error;
    matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error)
    {
        NSLog(@"loadPhotosFromFlickrArray: error in executeFetchRequest %@", error);
    }
    else if ([matches count])
    {
        // copy all the photoIDs into their own array
        NSMutableArray *coreDataPhotoIDs = [[NSMutableArray alloc]init];
        [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Photo *photo = obj;
            [coreDataPhotoIDs addObject:photo.photoID];
        }];
        NSString *photoID;
        for (NSDictionary *photo in photos)
        {
            photoID = [photo valueForKeyPath:FLICKR_PHOTO_ID];
            // check to see if the photoID from the downloaded photo is already in our list of core data photoIDs
            if (![coreDataPhotoIDs containsObject:photoID]) {
                [self photoWithFlickrInfo:photo inManagedObjectContext:context];
            }
            else {
                NSLog(@"already have photo in database");
            }
        }
    }
    NSLog(@"number of photos in database %ul", [matches count]);
}

@end
