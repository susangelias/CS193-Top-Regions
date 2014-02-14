//
//  TopPlacesTVC.m
//  TopPlaces
//
//  Created by Susan Elias on 2/4/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "FlickrPlacesTVC.h"
#import "FlickrFetcher.h"
#import "SpecificPlacePhotosTVC.h"
#import "MostRecentPhotosTVC.h"

@interface FlickrPlacesTVC ()

@property (nonatomic, strong) NSMutableArray *countries;
@property (nonatomic, strong) NSDictionary *topPlaces;


@end

@implementation FlickrPlacesTVC

#pragma mark PROPERTY INITIALIZATIONS

// whenever our Model is set, must update our View

- (void)setPlaces:(NSArray *)places
{
    _places = places;
    [self.tableView reloadData];
}

- (NSMutableArray *)countries
{
    if (!_countries) {
        _countries = [[NSMutableArray alloc]init];
    }
    return _countries;
}

- (void) listCountries
{
    // get the list of countries with no duplicates
    // the country name will be the key into our topPlaces dictionary
    [[self.places valueForKeyPath:FLICKR_PLACE_NAME] enumerateObjectsUsingBlock:^(id cityTerritoryCountry, NSUInteger idx, BOOL *stop) {
        NSString *country = [self extractCountryName:cityTerritoryCountry];
        if (![self.countries containsObject:country] )
        {
            [self.countries addObject:country];
        }
    }];
    
 
    // CREATE ARRAY OF ALL THE PLACES FROM A GIVEN COUNTY
    NSMutableArray *placesArray = [[NSMutableArray alloc]init];
    [self.countries enumerateObjectsUsingBlock:^(id country, NSUInteger idx, BOOL *stop) {
        NSMutableArray  *countryPlaces = [[NSMutableArray alloc]init];
        [self.places enumerateObjectsUsingBlock:^(id place, NSUInteger idx, BOOL *stop) {
            NSString *keyName = [self extractCountryName:[place valueForKeyPath:FLICKR_PLACE_NAME]];
            if ([keyName isEqualToString:country])
            {
                [countryPlaces addObject:place];
            }
        }];
        [placesArray addObject:[countryPlaces copy]];
    }];

    
    // placesArray is an array, in order of the countries, of unsorted places
    // go through the placesArray and sort the places for each country
    NSMutableArray *sortedPlaces = [[NSMutableArray alloc]init];
    for (NSMutableArray *unsortedPlaces in placesArray)
    {
        // define a descriptor to sort these placeS
        NSSortDescriptor *lastDescriptor =
            //input a particular key in dictionary..
            [[NSSortDescriptor alloc] initWithKey:FLICKR_PLACE_NAME
                                        ascending:YES
                                         selector:@selector(caseInsensitiveCompare:)];
    
        NSArray *descriptors = [NSArray arrayWithObjects:lastDescriptor, nil];
        
        //input array containing dictionaries
        [sortedPlaces addObject:[unsortedPlaces sortedArrayUsingDescriptors:descriptors]];
    }
    self.topPlaces = [NSDictionary dictionaryWithObjects:sortedPlaces forKeys:self.countries];
 
 }

- (NSString *)extractCountryName:(NSString *)locationString
{
    NSString *country;
    country = [[locationString componentsSeparatedByString:@","]lastObject];
    return country;
}

- (NSString *)extractCityName:(NSString *)locationString
{
    NSString *city = [[NSString alloc]init];
    city = [[locationString componentsSeparatedByString:@","]objectAtIndex:0];
    return city;
}

- (NSString *)extractRegionName:(NSString *)locationString
{
    NSString *region;
    region = [[locationString componentsSeparatedByString:@","]objectAtIndex:1];
    return region;
}

#pragma mark VIEW LOADING

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self listCountries];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // GET THE NUMBER OF COUNTRIES IN THE LIST OF TOP PLACES ON FLICKR
    [self listCountries];
    // Return the number of sections.
    return [self.countries count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSUInteger numberOfRows = 0;
    NSString *country =  [self.countries objectAtIndex:section];
    numberOfRows = [[self.topPlaces objectForKey:country]count];
    
 //   NSLog(@"%@, ROWS %d", country, numberOfRows);
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.countries objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *country =  [self.countries objectAtIndex:indexPath.section];
    NSArray *places = [self.topPlaces objectForKey:country];
    if (indexPath.row < [places count]) {
        NSDictionary *place = [places objectAtIndex:indexPath.row];

        cell.textLabel.text = [self extractCityName:[place valueForKeyPath:FLICKR_PLACE_NAME]];
        cell.detailTextLabel.text = [self extractRegionName:[place valueForKeyPath:FLICKR_PLACE_NAME]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

// when a row is selected and we are in a UISplitViewController,
//   this updates the Detail ImageViewController (instead of segueing to it)
// knows how to find an ImageViewController inside a UINavigationController in the Detail too
// otherwise, this does nothing (because detail will be nil and not "isKindOfClass:" anything)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"FlicrPlacesTVC: didSelectRowAtIndexPath");
    id detail = self.splitViewController.viewControllers[1];
    if (detail)
    {
        // if Detail is a UINavigationController, look at its root view controller to find it
        if ([detail isKindOfClass:[UINavigationController class]]) {
            detail = [((UINavigationController *)detail).viewControllers firstObject];
        }
        
        NSLog(@"DETAIL = %@", [detail class]);

        // is the Detail is an SpecificPlacePhotosTVC?
        if ([detail isKindOfClass:[SpecificPlacePhotosTVC class]]) {
            NSString *country = [self.countries objectAtIndex:indexPath.section];
            NSArray *places = [self.topPlaces objectForKey:country];
            [self prepareSpecificPlacePhotos:detail toDisplayPhotos:[places objectAtIndex:indexPath.row]];
        }
    }
}

#pragma mark - Navigation

// Prepare the tableViewController that will display 50 photos of the selected place
- (void)prepareSpecificPlacePhotos:(SpecificPlacePhotosTVC *)destinationTVC
                   toDisplayPhotos:(NSDictionary *)place
{
    // set up the url
    NSString *placeID = [place valueForKey:FLICKR_PLACE_ID];
    destinationTVC.url = [FlickrFetcher URLforPhotosInPlace:placeID maxResults:50];
    // set up title
    destinationTVC.placeName = [place valueForKey:FLICKR_PLACE_NAME];
    destinationTVC.navigationController.title = destinationTVC.placeName;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    if ([sender isKindOfClass:[UITableViewCell class]])
    {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        if (indexPath) {
            // found it...are we doing the display 50 photos seque ?
            if ([segue.identifier isEqualToString:@"SpecificPlacePhotos"])
            {
                // yes... is it the destination a table view controller ?
                if ([segue.destinationViewController isKindOfClass:[SpecificPlacePhotosTVC class]])
                {
                    // yes.... then we know how to prepare for the segue
                    NSString *country = [self.countries objectAtIndex:indexPath.section];
                    NSArray *places = [self.topPlaces objectForKey:country];
                    [self prepareSpecificPlacePhotos:segue.destinationViewController
                                     toDisplayPhotos:[places objectAtIndex:indexPath.row]];
                }
            } else {
                NSAssert(NO, @"Unknown segue. All segues must be handled.");
            }
        }
    }
}




@end
