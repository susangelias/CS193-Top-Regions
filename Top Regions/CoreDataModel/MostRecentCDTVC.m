//
//  MostRecentCDTVC.m
//  Top Regions
//
//  Created by Susan Elias on 2/23/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "MostRecentCDTVC.h"
#import "Photo.h"
#import "ImageViewController.h"
#import "TopRegionsAppDelegate.h"


@implementation MostRecentCDTVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Ask appDelegate for our managed context
    if (!self.context)
    {
        TopRegionsAppDelegate *appDelegate = (TopRegionsAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.context = appDelegate.context;
    }
    // Set up fetch request for this view from our core data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"viewedDate !=  nil" ];
    NSSortDescriptor *byViewedDate = [NSSortDescriptor sortDescriptorWithKey:@"viewedDate"
                                                                   ascending:NO
                                                                    selector:@selector(compare:)];
    request.fetchLimit = 50;
    request.sortDescriptors = @[byViewedDate];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                       managedObjectContext:self.context                                                                        sectionNameKeyPath:nil
                                                                                  cacheName:nil ];
    
}

#pragma mark UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell"];
    
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
                }
            }
        }
    }
}

@end
