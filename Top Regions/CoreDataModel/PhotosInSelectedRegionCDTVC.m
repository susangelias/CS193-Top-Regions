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


@interface PhotosInSelectedRegionCDTVC ()

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];	// Do any additional setup after loading the view.
    
    // set title to the region name
    self.navigationItem.title = self.selectedRegion.name;

    // Set up fetch request for this view from our core data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"whereTook = %@", self.selectedRegion];
    NSSortDescriptor *byPhotographer = [NSSortDescriptor sortDescriptorWithKey:@"whoTook"
                                                                             ascending:YES
                                                                              selector:@selector(compare:)];
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                             ascending:YES
                                                              selector:@selector(localizedStandardCompare:)];
    
    request.sortDescriptors = @[byName];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                       managedObjectContext:self.selectedRegion.managedObjectContext                                                                        sectionNameKeyPath:nil
                                                                                  cacheName:nil ];

    NSError *error;
    NSLog(@"number of photos in region %ul", [self.selectedRegion.managedObjectContext  countForFetchRequest:request error:&error]);

}
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell"];
    
    // get photo out of model
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", photo.subtitle];
    
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
