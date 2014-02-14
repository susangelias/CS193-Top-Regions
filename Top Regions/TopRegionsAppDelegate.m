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



NSString * const ContextReady = @"TopRegionsAppDelegateDidPrepareContextNotification";

@interface TopRegionsAppDelegate() <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) UIManagedDocument *topRegionsManagedDocument;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSURLSession *flickrDownloadSession;
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();


@end

@implementation TopRegionsAppDelegate


#pragma mark    AppDelegate Methods

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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
        
        // INSTANTIATE OUR MANAGED DOCUMENT IF NEEDED
        _topRegionsManagedDocument = [[UIManagedDocument alloc]initWithFileURL:url];
        
        // OPEN OR CREATE OUR MANAGED DOCUMENT
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        {
            [_topRegionsManagedDocument openWithCompletionHandler:^(BOOL success) {
                if (success) [self managedDocumentIsReady];
                if (!success) NSLog(@"Couldn't open document at %@", url);
            }];
        } else
        {
            [_topRegionsManagedDocument saveToURL:url
                                 forSaveOperation:UIDocumentSaveForCreating
                                completionHandler:^(BOOL success) {
                                    if (success) [self managedDocumentIsReady];
                                    if (!success) NSLog(@"Couldn't open document at %@", url);
                                }];
        }
    }
    return _topRegionsManagedDocument;
}

- (void)managedDocumentIsReady
{
    if (self.topRegionsManagedDocument.documentState != UIDocumentStateNormal)
    {
        NSLog(@"managedDocumentIsReady failed: documentState = %u", self.topRegionsManagedDocument.documentState);
    }
    else
    {
        self.context = self.topRegionsManagedDocument.managedObjectContext;
        
        // Send the joyful proclamation that the context is ready for prime time!
        NSLog(@"posting notitication that context is ready ");
        NSDictionary *userInfo = self.context ? @{PhotoDatabaseAvailabilityContext : self.context} : nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:ContextReady
                                                            object:self
                                                          userInfo:userInfo];
        
        // Get the initial data download going
        [self startFlickrFetch];
    }
}

#pragma mark Flickr Fetching

- (void) startFlickrFetch
{
    // start a background download session - musjt use getTalksWithCompletionHandler when using a background session
    // our completion is handled by the URLSessionDelegate methods
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count])
        {
            NSLog(@"starting FlickrFetch download in background");
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
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


- (NSURLSession *)flickrDownloadSession // the NSURLSession we will use to fetch Flickr data in the background
{
    if (!_flickrDownloadSession)
    {
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

// standard "get photo information from Flickr URL" code

- (NSArray *)flickrPhotosAtURL: (NSURL *)url
{
    // fetch the json data from Flickr
    NSData *jsonResults = [NSData dataWithContentsOfURL:url];
    // put it into a property list
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                        options:0
                                                                          error:NULL];
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
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH])
    {
        NSLog(@"finished downloading Flick photos");
        [self loadFlickrPhotosFromLocalURL:localFile
                                intoContext:self.context
                        andThenExecuteBlock:^{
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
