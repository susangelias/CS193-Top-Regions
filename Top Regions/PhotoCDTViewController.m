//
//  PhotoCDTVCViewController.m
//  Top Regions
//
//  Created by Susan Elias on 2/26/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PhotoCDTViewController.h"
#import "Photo.h"
#import "ImageViewController.h"
#import "TopRegionsAppDelegate.h"

@interface PhotoCDTViewController ()

@end

@implementation PhotoCDTViewController



#pragma mark UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    
    // get photo out of model
    __block Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", photo.subtitle];
    if (photo.thumbnail) {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    }
    else {
        // Fetch thumbnail image from server
        // create a non-main queue to do the fetch on
        if (photo.thumbnailURL)    // make sure I have a valid URL before starting
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photo.thumbnailURL]];
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                                if (!error)     // make sure there was no error during the download
                                                                {
                                                                    [photo setThumbnail:[NSData dataWithContentsOfURL:localFile]];
                                                                }
                                                            }];
            [task resume];
        }
        
    }
    
    return cell;
}


#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]])
    {
        // find out which row was selected
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if (indexPath)
        {
            // are we doing the selected Region segue
            if ([segue.identifier isEqualToString:@"Display Photo"])
            {
                // is destination a PhotosInSelectedRegion Controller ?
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]])
                {
                    // pass the selected imageURL to the destination controller
                    ImageViewController *destination = (ImageViewController *)segue.destinationViewController;
                    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    destination.imageURL = [NSURL URLWithString:photo.imageURL];
                    
                    // set the title of the destination controller with the title of the photo
                    destination.navigationItem.title = photo.title;
                    
                    // set the viewed Date
                    [photo setViewedDate:[NSDate date]];
                }
            }
        }
    }
}


@end
