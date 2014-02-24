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
    for (NSDictionary *photo in photos)
    {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    NSError *error;
    NSLog(@"number of photos in database %ul", [context  countForFetchRequest:request error:&error]);
}

@end
