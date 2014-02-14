//
//  PlacePhotosTVC.h
//  TopPlaces
//
//  Created by Susan Elias on 2/5/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrPhotosTVC.h"

@interface SpecificPlacePhotosTVC : FlickrPhotosTVC 

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSArray *photos;      // Flickr photos of a specific place    
@end
