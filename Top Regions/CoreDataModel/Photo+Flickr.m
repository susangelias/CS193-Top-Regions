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


@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext: (NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSString *photoID = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"photoID = %@", photoID];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1))
    {
        // handle error
    }
    else if ([matches count])
    {
        photo = [matches firstObject];
 //       NSLog(@"photo found who = %@, where = %@", photo.whoTook, photo.whereTook);
    }
    else
    {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.photoID = photoID;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge]absoluteString];
        photo.thumbnail = nil;
        photo.thumbnailURL = nil;
        
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName inManagedContext:context];
        
        NSString *placeID = [photoDictionary valueForKeyPath:FLICKR_PLACE_ID];
        // tell the region entity that there is a photo from that region, it will take care of creating links to whereTook attribute
        [Region regionWithPlaceID:placeID withPhoto:photo];
        
   //     NSLog(@"created photo in core data %@", photo);
    }
    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos // of Flickr NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *photo in photos)
    {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
}

@end
