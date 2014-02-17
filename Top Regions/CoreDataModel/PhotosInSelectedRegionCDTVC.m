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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];	// Do any additional setup after loading the view.
    
    // set title to the region name
    self.navigationItem.title = self.selectedRegion.name;
 /*
    NSSet *regionPhotos = [self.selectedRegion photos];
    NSSortDescriptor *byPhotographer = [NSSortDescriptor sortDescriptorWithKey:@"whoTook.name"
                                                                     ascending:YES
                                                                      selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                             ascending:YES
                                                              selector:@selector(localizedStandardCompare:)];
    
    NSArray *sortDescriptors = @[byPhotographer, byName];
    self.sortedPhotos = [regionPhotos sortedArrayUsingDescriptors:sortDescriptors];

    // Set up fetch request for this view from our core data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", self.selectedRegion.name];
   request.sortDescriptors = @[];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                       managedObjectContext:self.selectedRegion.managedObjectContext                                                                        sectionNameKeyPath:nil
                                                                                  cacheName:nil ];

    NSError *error;
    NSLog(@"number of photos in region %ul", [self.selectedRegion.managedObjectContext  countForFetchRequest:request error:&error]);
*/
}

#pragma mark UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.selectedRegion.photographers count];
}
/*

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    // Return title of sections
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES
                                                                      selector:@selector(localizedStandardCompare:)];

    NSArray *photographers = [self.selectedRegion.photographers
                              sortedArrayUsingDescriptors:@[byName]];
    return photographers;
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self photosInSection:section]count];
  //  return [self.selectedRegion.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Flickr Photo Cell"];
    
    // get photo out of model
 //   Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    Photo *photo = [[self photosInSection:indexPath.section ] objectAtIndex:indexPath.row];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", photo.subtitle];
    
    return cell;
}

- (NSArray *)photosInSection: (NSInteger)section {
    
    NSArray *photographersWork = nil;
    NSSortDescriptor *byPhotographer = [NSSortDescriptor sortDescriptorWithKey:@"whoTook.name"
                                                                     ascending:YES
                                                                      selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *byTitle = [NSSortDescriptor sortDescriptorWithKey:@"title"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)];
    
    NSArray *sortDescriptors = @[byPhotographer, byTitle];
    // create array of all this region's photos sorted by photographer then by title
    self.regionPhotos = [self.selectedRegion.photos sortedArrayUsingDescriptors:sortDescriptors ];
    NSLog(@"self.regionPhotos = %@", self.regionPhotos);
    NSLog(@"section %d", section);
    
    // create a derived array of only the photos by the photographer for this section
    Photo *photo = [self.regionPhotos objectAtIndex:section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"whoTook.name = %@", photo.whoTook.name];
    photographersWork = [self.regionPhotos filteredArrayUsingPredicate:predicate];
    NSLog(@"photographersWork = %@", photographersWork);
    
    return photographersWork;
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
        //            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    Photo *photo = [self.regionPhotos objectAtIndex:indexPath.row];
                    destination.imageURL = [NSURL URLWithString:photo.imageURL];
                   
                    // set the title of the destination controller with the title of the photo
                    destination.navigationItem.title = photo.title;
                }
            }
        }
    }
}


@end
