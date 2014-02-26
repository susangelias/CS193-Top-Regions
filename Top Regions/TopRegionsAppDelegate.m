//
//  TopRegionsAppDelegate.m
//  Top Regions
//
//  Created by Susan Elias on 2/12/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "TopRegionsAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Region+create.h"
#import "PlaceID.h"
#import "PhotoDatabaseAvailability.h"

// NOTIFICATION IDENTIFIERS
//NSString * const ContextReady = @"TopRegionsAppDelegateDidPrepareContextNotification";

// DICTIONARY KEYS
NSString * const placeIDKey = @"placeID";
NSString * const taskKey = @"taskKey";
// how long we'll wait for a Flickr fetch to return when we're in the background
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

@interface TopRegionsAppDelegate() <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) UIManagedDocument *topRegionsManagedDocument;

@property (nonatomic, strong) NSURLSession *flickrDownloadSession;
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (nonatomic, strong) NSTimer *flickrForegroundFetchPhotoTimer;
@property (nonatomic, strong) NSMutableArray *placeIDManagedObjectsWithoutRegionName;
@property (nonatomic, strong) NSMutableArray *placeIDManagedObjectsWaitingForRegionResults;
@property (nonatomic, strong) NSTimer *flickrForegroundFetchPlaceTimer;

@end

@implementation TopRegionsAppDelegate


#pragma mark    AppDelegate Methods

- (NSMutableArray *)placeIDManagedObjectsWaitingForRegionResults
{
    if (!_placeIDManagedObjectsWaitingForRegionResults) {
        _placeIDManagedObjectsWaitingForRegionResults = [[NSMutableArray alloc]init];
    }
    return _placeIDManagedObjectsWaitingForRegionResults;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // get the context for our photo database if it is ready otherwise asking for the managedDocument will kick off document creation
    // and the context will be set in the completion handler
    if (self.topRegionsManagedDocument.documentState == UIDocumentStateNormal)
    {
        NSLog(@"managedDocument Normal");
        self.context = self.topRegionsManagedDocument.managedObjectContext;
    }
    
    // set fetch interval for background fetching
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.flickrForegroundFetchPhotoTimer = nil;
    self.flickrForegroundFetchPlaceTimer = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // Get the initial data download going
    NSMutableDictionary *taskInfo = [[NSDictionary dictionaryWithObjectsAndKeys:FLICKR_PHOTO_TASK, @"taskKey", nil]mutableCopy];
    [self startFlickrFetchWithDescription:taskInfo];
    
    // set the timer for the periodic fetchs
    [self setupForegroundPhotoFetchTimer];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
   // From [iOS Developer library:  In iOS, when a background transfer completes or requires credentials, if your app is no longer running, iOS automatically relaunches your app in the background and calls the application:handleEventsForBackgroundURLSession:completionHandler: method on your app’s UIApplicationDelegate object. This call provides the identifier of the session that caused your app to be launched. Your app should store that completion handler, create a background configuration object with the same identifier, and create a session with that configuration object. The new session is automatically reassociated with ongoing background activity. Later, when the session finishes the last background download task, it sends the session delegate a URLSessionDidFinishEventsForBackgroundURLSession: message. Your session delegate should then call the stored completion handler.
        
        
    // this completionHandler, when called, will cause our UI to be re-cached in the app switcher
    // but we should not call this handler until we're done handling the URL whose results are now available
    // so we'll stash the completionHandler away in a property until we're ready to call it
    // (see flickrDownloadTasksMightBeComplete for when we actually call it)
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;

}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // better to do a non-background-session fetch here since background session fetches are discretionary
    // and the system can refuse to do it if the application is currently in the background (which it is
    // guaranteed to be in this case
    if (self.context)
    {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;    // WIRELESS ONLY - DON'T RUN UP DATA USAGE IN THE BACKGROUND
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT;  // KEEP REQUEST SHORT SO THAT WE DON'T TAKE UP TOO MUCH OF THE SYSTEM'S TIME
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                            if(error) {
                                                                NSLog(@"Flickr background fetch failed: %@", error.localizedDescription);
                                                                completionHandler(UIBackgroundFetchResultFailed);
                                                            }
                                                            else {
                                                                [self loadFlickrPhotosFromLocalURL:localFile
                                                                                       intoContext:self.context
                                                                               andThenExecuteBlock:^{
                                                                                   completionHandler(UIBackgroundFetchResultNewData);
                                                                               }];
                                                            }
                                                        }
                                          ];
        [task resume];
    }
    else {
        completionHandler(UIBackgroundFetchResultNoData);   // no app-switcher update if no database
    }
}



#pragma mark   UIManagedDocument Setup

- (UIManagedDocument *)topRegionsManagedDocument
{
    if (!_topRegionsManagedDocument)
    {
        
        // SET UP NAME, DIRECTORY AND PATH OF OUR MANAGED DOCUMENT
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] firstObject];
        NSString *documentName = @"TopRegionsManagedDocument";
        NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
        
        NSLog(@"url of managed document %@", url);
        
        // INSTANTIATE OUR MANAGED DOCUMENT IF NEEDED
        _topRegionsManagedDocument = [[UIManagedDocument alloc]initWithFileURL:url];
        
        // OPEN OR CREATE OUR MANAGED DOCUMENT
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        {   // open document (database)
            [_topRegionsManagedDocument openWithCompletionHandler:^(BOOL success) {
                if (success) [self managedDocumentIsReady];
                if (!success) NSLog(@"Couldn't open document at %@", url);
            }];
        } else
        {   // create document (database in our case)
            [_topRegionsManagedDocument saveToURL:url
                                 forSaveOperation:UIDocumentSaveForCreating
                                completionHandler:^(BOOL success) {
                                    if (success) [self managedDocumentIsReady];
                                    if (!success) NSLog(@"Couldn't create/open document at %@", url);
                                }];
        }
    }
    return _topRegionsManagedDocument;
}

- (void)managedDocumentIsReady
{
    if (self.topRegionsManagedDocument.documentState != UIDocumentStateNormal)
    {
        NSLog(@"managedDocumentIsReady failed: documentState = %lu", self.topRegionsManagedDocument.documentState);
    }
    else
    {
        self.context = self.topRegionsManagedDocument.managedObjectContext;
        
    //    NSLog(@"posting notitication that context is ready ");
        NSMutableDictionary *userInfo = [self.context ? @{PhotoDatabaseAvailabilityContext : self.context} : nil mutableCopy];
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                            object:self
                                                          userInfo:userInfo];
        
        // Get the initial data download going
        NSMutableDictionary *taskInfo = [[NSDictionary dictionaryWithObjectsAndKeys:FLICKR_PHOTO_TASK, @"taskKey", nil]mutableCopy];
        [self startFlickrFetchWithDescription:taskInfo];
        
        // set the timer for the periodic fetchs
        [self setupForegroundPhotoFetchTimer];
     }
}

- (void) setupForegroundPhotoFetchTimer
{
    // Set up a timer to keep PHOTO fetches going when we are in the foreground
    NSMutableDictionary *taskInfo = [[NSDictionary dictionaryWithObjectsAndKeys:FLICKR_PHOTO_TASK, @"taskKey", nil]mutableCopy];
    self.flickrForegroundFetchPhotoTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_PHOTO_FETCH_INTERVAL
                                                                            target:self
                                                                          selector:@selector(handlePhotoTimer:)
                                                                          userInfo:taskInfo
                                                                           repeats:YES];
   
}


#pragma mark Flickr Fetching

- (NSURLSession *)flickrDownloadSession // the NSURLSession we will use to fetch Flickr data in the background
{
    if (!_flickrDownloadSession)
    {   // SINGLETON
        static dispatch_once_t onceToken;   // need to read Grand Central Dispatch documentation to understand this
        dispatch_once(&onceToken, ^{
            // notice the configuration here is "backgroundSessionConfiguration:"
            // that means that we will (eventually) get the results even if we are not the foreground application
            // even if our application crashed, it would get relaunched (eventually) to handle this URL's results!
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self     // we MUST have a delegate for background configurations
                                                              delegateQueue:nil];   // nil means "a random, non-main-queue queue"
            
        });
    }
    
    return _flickrDownloadSession;
}

// Foreground fetch from the server
- (void) startFlickrFetchWithDescription: (NSDictionary*) taskInfo {
    // start a background download session - must use getTasksWithCompletionHandler when using a background session
    // our completion is handled by the URLSessionDelegate methods
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks)
    {
        if (![downloadTasks count])
        {
            NSURLSessionDownloadTask *task;
            NSString *taskType = [taskInfo valueForKey:@"taskKey"];
            if ([taskType isEqualToString:FLICKR_PHOTO_TASK]) {
                NSLog(@"starting photo download in background");
                task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            }
            else if ([taskType isEqualToString:FLICKR_PLACE_TASK]) {
          //      NSLog(@"starting placeInfo download in background");
                NSString *placeID = [taskInfo valueForKey:@"placeID"];
                task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:placeID]];
            }
            task.taskDescription = taskType;
            [task resume];
        }
        else
        {
            // ... we are working on a fetch (let's make sure it (they) is (are) running while we're here)
            for (NSURLSessionDownloadTask *task in downloadTasks)
            {
                [task resume];
            }
        }
    }];
}

- (void) handlePhotoTimer:(NSTimer *)theTimer {
    
    [self startFlickrFetchWithDescription:[theTimer userInfo]];
}

#pragma mark Region and place processing


- (void)handlePlaceTimer:(NSTimer *)timer
{
    [self fetchPlacesMissingRegionLink];
}

- (void) fetchPlacesMissingRegionLink {
    
    // query core data for any places that  do not have a region relationship yet
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"PlaceID"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY region = nil"];
        [request setPredicate:predicate];
        [request setFetchLimit:10];      // leaving this unlimited sends too many requests to the server and it stops responding to me
        TopRegionsAppDelegate *weakSelf  = self;
        [weakSelf.context performBlock:^{
            NSError *error;
            // Create a list of placeID managed objects that don't have regions assigned
            weakSelf.placeIDManagedObjectsWithoutRegionName = [[weakSelf.context executeFetchRequest:request error:&error]mutableCopy];
          //  NSLog(@"self.placeIDManagedObjectsWithoutRegionName  %@", weakSelf.placeIDManagedObjectsWithoutRegionName);
            // start up the first region download
            [weakSelf regionDownload];
        }];
}

- (void) regionDownload
{
    // if there are any photo managed objects on the queue, take off the first one
    if ([self.placeIDManagedObjectsWithoutRegionName count] > 0)
    {
        PlaceID *place = [self.placeIDManagedObjectsWithoutRegionName firstObject];
        // remove the place from the queue
        [self.placeIDManagedObjectsWithoutRegionName removeObject:place];
        
        //  request place information from server
        if (place.placeID)  // make sure the photo has a placeID as this is needed for the URL request to Flickr
        {
            NSDictionary *taskInfo = [NSDictionary dictionaryWithObjectsAndKeys:place.placeID, placeIDKey, FLICKR_PLACE_TASK, taskKey, nil];
            [self startFlickrFetchWithDescription:taskInfo];
            // add place to queue waiting for server results
            [self.placeIDManagedObjectsWaitingForRegionResults addObject:place];
        }
        else {
            NSLog(@"place missing placeID");
        }
    }
    else   // There are no more places to process so clear out array
    {
        [self.placeIDManagedObjectsWaitingForRegionResults removeAllObjects];
    //    NSLog(@"processed place batch of 5");
        // set up a timer to space out the requests to the server
        self.flickrForegroundFetchPlaceTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_REGION_FETCH_INTERVAL
                                                        target:self
                                                      selector:@selector(handlePlaceTimer:)
                                                      userInfo:nil
                                                       repeats:NO];

    }
    
}

// extra json place results into property list
- (NSDictionary *)flickrPlaceAtURL: (NSURL *)url
{
    // fetch the json data from Flickr
    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
    // put it into a property list
    NSDictionary *propertyListResults;
    if (jsonResults) {
        propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                              options:0
                                                                error:NULL];
    }
    return propertyListResults;
}

// load the region into coreData
- (void) loadFlickrRegionFromLocalURL:(NSURL *)localFile
                          intoContext:(NSManagedObjectContext *)context
                  andThenExecuteBlock:(void(^)())whenDone
{
    if (context)
    {
        NSDictionary *propertyListResults = [self flickrPlaceAtURL:localFile];
        [context performBlockAndWait:^{
            // SAVE THE REGION RESULTS INTO CORE DATA
            [Region loadRegionFromFlickr:propertyListResults intoManagedContext:context];
            if (whenDone) whenDone();
        }];
    } else {
        if (whenDone) whenDone();
    }
    
}



// link placeID to region
- (void) assignRegionToPlaceWithPlaceInfo:(NSURL *)localFile
{
    NSDictionary *propertyListResults = [self flickrPlaceAtURL:localFile];
    for (PlaceID *place in self.placeIDManagedObjectsWaitingForRegionResults)
    {
        NSString *placeName = [FlickrFetcher extractNameOfPlace:place.placeID fromPlaceInformation:propertyListResults];
        //   NSLog(@"NameOfPlace %@ for placeID %@", placeName, place.placeID);
        if (placeName)
        {
            // found the region where this place belongs
            //     NSLog(@"found region for place %@", place.placeID);
            // fetch region entity
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", [FlickrFetcher extractRegionNameFromPlaceInformation:propertyListResults]];
            [request setPredicate:predicate];
            [self.context performBlockAndWait:^{
                NSError *error = nil;
                NSArray *results = [self.context executeFetchRequest:request error:&error];
                if ((results) && ([results count] > 0)) {
                    // set link between placeID entity and region entity
                    Region *region = [results firstObject];
                    [place addRegionObject:region];
                    // set link in region to a photographer if this photographer is not already in the region's list of photographers
                    [region addPhotographersObject:place.photo.whoTook];
                    region.numberOfPhotographers = [NSNumber numberWithInt: [region.photographers count]];
                    NSLog(@"assigned place %@ to region %@", place.placeID, region.name);
                }
                
            }];
        }
    }
    
    
}


#pragma mark photo processing and downloading

// standard "get photo information from Flickr URL" code

- (NSArray *)flickrPhotosAtURL: (NSURL *)url
{
    // fetch the json data from Flickr
    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
    // put it into a property list
    NSDictionary *propertyListResults;
    if (jsonResults) {
        propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                        options:0
                                                                          error:NULL];
    }
    return [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

// gets the Flickr photo dictionaries out of the url and puts them into Core Data
// this was moved here after lecture to give you an example of how to declare a method that takes a block as an argument
// and because we now do this both as part of our background session delegate handler and when background fetch happens


- (void) loadFlickrPhotosFromLocalURL:(NSURL *)localFile
                          intoContext:(NSManagedObjectContext *)context
                  andThenExecuteBlock:(void(^)())whenDone
{
        if (context)
        {
            NSArray *photos = [self flickrPhotosAtURL:localFile];
           // NSLog(@"1 photo json %@", [photos firstObject]);
            [context performBlock:^{
                [Photo loadPhotosFromFlickrArray:photos
                        intoManagedObjectContext:context];
                if (whenDone) whenDone();
            }];
        } else {
            if (whenDone) whenDone();
        }
    
}



#pragma mark NSURLSessionDownloadDelegate

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // we don't support resuming an interrupted download task
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    // don't assume we are the only download going on
    if ([downloadTask.taskDescription isEqualToString:FLICKR_PHOTO_TASK])
    {
        NSLog(@"finished downloading Flick photos");
        [self loadFlickrPhotosFromLocalURL:localFile
                                intoContext:self.context
                        andThenExecuteBlock:^{
                            // kick off the download for new region info
                            // set up a timer to delay the first request while core data populates after launch
                            self.flickrForegroundFetchPlaceTimer = [NSTimer scheduledTimerWithTimeInterval:LAUNCH_POPULATION_DELAY
                                                                                                    target:self
                                                                                                  selector:@selector(handlePlaceTimer:)
                                                                                                  userInfo:nil
                                                                                                   repeats:NO];

                            [self flickrDownloadTasksMightBeComplete];
                        }];
    }
    else if ([downloadTask.taskDescription isEqualToString:FLICKR_PLACE_TASK])
    {
  //      NSLog(@"finished downloading Flick place info");
        [self loadFlickrRegionFromLocalURL:localFile
                               intoContext:self.context
                       andThenExecuteBlock:^{
                           [self assignRegionToPlaceWithPlaceInfo:localFile];      // link up placeID to the region created using the place results downloaded
                           [self regionDownload];
                           [self flickrDownloadTasksMightBeComplete];
                       }];
    }

}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // we don't report the progress of a download in our UI, but this is a cool method to do that with
}

// not required by the protocol, but we should definitely catch errors here
// so that we can avoid crashes
// and also so that we can detect that download tasks are (might be) complete
- (void)URLSession:(NSURLSession *)session
             task:(NSURLSessionTask *)task
    didCompleteWithError:(NSError *)error
{
        if (error && (session == self.flickrDownloadSession))
        {
            NSLog(@"Flickr background dowload session failed: %@", error.localizedDescription);
            [self flickrDownloadTasksMightBeComplete];
        }
}

- (void) flickrDownloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler)
    {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            // we're doing this check for other downloads just to be theoretically "correct"
            //  but we don't actually need it (since we only ever fire off one download task at a time)
            // in addition, note that getTasksWithCompletionHandler: is ASYNCHRONOUS
            //  so we must check again when the block executes if the handler is still not nil
            //  (another thread might have sent it already in a multiple-tasks-at-once implementation)

            if (![downloadTasks count]) // any more Flickr downloads left?
            {
                // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler)
                {
                    completionHandler();
                }
            } // else other downloads going, so let them call this method when they finish
        }];
    }
}

@end
