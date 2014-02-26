//
//  PhotosInSelectedRegionCDTVC.h
//  Top Regions
//
//  Created by Susan Elias on 2/15/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PhotoCDTViewController.h"
#import "Region.h"


@interface PhotosInSelectedRegionCDTVC : PhotoCDTViewController

@property (nonatomic, strong) Region *selectedRegion;
@property (nonatomic, strong) NSArray *regionPhotos;

@end
