//
//  PhotosInSelectedRegionCDTVC.m
//  Top Regions
//
//  Created by Susan Elias on 2/15/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "PhotosInSelectedRegionCDTVC.h"
#import "Photo.h"
#import "ImageViewController.h"
#import "Photographer.h"


@interface PhotosInSelectedRegionCDTVC ()

@property NSArray *sortedPhotos;

@end

@implementation PhotosInSelectedRegionCDTVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    // set title to the region name
    self.navigationItem.title = self.selectedRegion.name;
    
    // Set up fetch request for this view from our core data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY whereTook.region.name =  %@", self.selectedRegion.name   ];
    NSSortDescriptor *byTitle = [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *bySubTitle = [NSSortDescriptor sortDescriptorWithKey:@"subtitle"
                                                                 ascending:YES
                                                                  selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *byPhotographer = [NSSortDescriptor sortDescriptorWithKey:@"whoTook"
                                                                     ascending:YES
                                                                      selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[byTitle];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                       managedObjectContext:self.selectedRegion.managedObjectContext                                                                        sectionNameKeyPath:nil
                                                                                  cacheName:nil ];
    
//    NSError *error;
//    NSLog(@"number of photos in region %ul", [self.selectedRegion.managedObjectContext  countForFetchRequest:request error:&error]);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];	// Do any additional setup after loading the view.
    


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
