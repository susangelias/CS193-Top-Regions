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
        NSLog(@"signing up to receiver context ready notification from app delegate");
        __block TopRegionsTVC *weakSelf = self;  // avoid a retain cycle
        [[NSNotificationCenter defaultCenter] addObserverForName:ContextReady
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          weakSelf.context = note.userInfo [PhotoDatabaseAvailabilityContext];
                                                          NSLog(@"received context from appDelegate %@", weakSelf.context);
                                                      }];
      }
    else
    {
        // REMOVE SELF FROM NOTIFICATION REGARDING CONTEXT READY
        // since I don't use any other notifications just remove from all notifications
#warning figure out when to remove self from notification center
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

}

- (void) setContext:(NSManagedObjectContext *)context
{
    _context = context;
    
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
@end
