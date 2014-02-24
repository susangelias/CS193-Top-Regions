//
//  TopRegionsViewController.m
//  Top Regions
//
//  Created by Susan Elias on 2/12/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "TopRegionsTVC.h"
#import "TopRegionsAppDelegate.h"
#import "Region.h"
#import "PhotosInSelectedRegionCDTVC.h"

@interface TopRegionsTVC ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation TopRegionsTVC



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // get our application's shared managed context via a notification from the appDelegate when it is ready to go
    if (!self.context)
    {
        // context not set up yet so sign up to receive notification when it is ready
        __block TopRegionsTVC *weakSelf = self;  // avoid a retain cycle
        [[NSNotificationCenter defaultCenter] addObserverForName:ContextReady
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          weakSelf.context = note.userInfo [PhotoDatabaseAvailabilityContext];
                                                      //    NSLog(@"received context from appDelegate %@", weakSelf.context);
                                                      }];
      }

}

- (void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
    // REMOVE SELF FROM NOTIFICATION REGARDING CONTEXT READY
    // since I don't use any other notifications just remove from all notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Set up fetch request for this view from our core data
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    NSSortDescriptor *byNumberOfPhotograhers = [NSSortDescriptor sortDescriptorWithKey:@"numberOfPhotographers"
                                                               ascending:NO
                                                                selector:@selector(compare:)];
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                               ascending:YES
                                                                selector:@selector(localizedStandardCompare:)];

    request.sortDescriptors = @[byNumberOfPhotograhers, byName];
    request.fetchLimit = 50;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                       managedObjectContext:_context
                                                                         sectionNameKeyPath:nil
                                                                                  cacheName:nil ];
    
 }

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Flickr Region Cell"];
    
    // get region out of model
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = region.name;
    NSString *photographerText = nil;
    NSInteger numberOfPhotographers = [region.numberOfPhotographers integerValue];
    if (numberOfPhotographers > 1) {
        photographerText = @"Photographers";
    }
    else {
        photographerText = @"Photographer";
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@", numberOfPhotographers, photographerText];
    
    return cell;
}



#pragma mark - Navigation

- (void) na:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]])
    {
        // find out which row was selected
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if (indexPath)
        {
            // are we doing the selected Region segue
            if ([segue.identifier isEqualToString:@"RegionSelected"])
            {
                // is destination a PhotosInSelectedRegion Controller ?
                if ([segue.destinationViewController isKindOfClass:[PhotosInSelectedRegionCDTVC class]])
                {
                    // pass the selected region to the destination controller
                    PhotosInSelectedRegionCDTVC *destination = (PhotosInSelectedRegionCDTVC *)segue.destinationViewController;
                    destination.selectedRegion = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    
                }
            }
        }
    }
}



- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // ADDED THIS BECAUSE THE DIRECT SEGUE METHOD ABOVE STOPPED BEING CALLED
    [self na:segue sender:sender];
    
}


@end
