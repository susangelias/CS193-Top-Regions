//
//  ImageViewController.m
//  TopPlaces
//
//  Created by Susan Elias on 2/3/14.
//  Copyright (c) 2014 GriffTech. All rights reserved.
//

#import "ImageViewController.h"
#import "TopPlacesTVC.h"
#import "MostRecentPhotosTVC.h"

@interface ImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end 

@implementation ImageViewController

#pragma mark    PROPERTY INITIALIZATIONS

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    [self setContentSize];
}

- (void) setContentSize
{
    self.scrollView.contentSize = self.image ? self.image.size: CGSizeZero;
    
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

// image is not instantiated, setter is used to make sure that the image gets inialized the way we need it to every time
- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    [self.imageView sizeToFit];
    
    // zoom to show as much of image as possible
    self.imageView.frame = self.scrollView.bounds;

    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.zoomScale = 1.0;

    [self setContentSize];
    
    [self.spinner stopAnimating];
}

-(void)viewDidLayoutSubviews
{
   
    self.imageView.frame = self.view.frame;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;  // this fixes squishing or expansion problems with the image when rotated
    self.scrollView.frame = self.view.frame;

    if  ( (self.image.size.width > self.image.size.height) && (self.view.frame.size.width > self.view.frame.size.height) )
    {
        // wide image going into wide frame:  this ratio looks good
        self.scrollView.maximumZoomScale = self.imageView.image.size.height / self.view.frame.size.width;
    }
    else if  ((self.image.size.width < self.image.size.height) && (self.view.frame.size.width < self.view.frame.size.height) )
    {
        // narrow image going into narrow frame:
        self.scrollView.maximumZoomScale = self.imageView.image.size.width / self.view.frame.size.height;
    }
    
    else if ( (self.image.size.width < self.image.size.height) && (self.view.frame.size.width > self.view.frame.size.height) )
    {
        // narrow image going into wide frame:
        self.scrollView.maximumZoomScale = self.imageView.image.size.width / self.view.frame.size.height;
    }
    else if ( (self.image.size.width > self.image.size.height) && (self.view.frame.size.width < self.view.frame.size.height) )
    {
        // wide image going into narrow frame:
        self.scrollView.maximumZoomScale =  self.view.frame.size.height / self.imageView.image.size.width;
    }
   
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self startDownLoadingImage];
}

#pragma mark    REQUEST DATA FROM MODEL

- (void)startDownLoadingImage
{
    self.image = nil;     // clear out the old image before the down load start
    if (self.imageURL)    // make sure I have a valid URL before starting
    {
        [self.spinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                if (!error)     // make sure there was no error during the download
                {
                    if ([request.URL isEqual:self.imageURL])    // make sure the user still wants this particular downloaded object
                    {
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];  // this is completing in a thread other than the main thread but is okay because it is just storing a local variable
                        [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];  // this is updating UI stuff so has to happen on main thread
                        
                    }
                }
            }];
        [task resume];
    }
}



#pragma VIEW SETUP

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView   addSubview:self.imageView];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

#pragma mark SplitViewController Delegate

- (BOOL) splitViewController:(UISplitViewController *)svc
    shouldHideViewController:(UIViewController *)vc
               inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
 //   return NO;
}

- (void) splitViewController:(UISplitViewController *)sender
      willHideViewController:(UIViewController *)master
           withBarButtonItem:(UIBarButtonItem *)barButtonItem
        forPopoverController:(UIPopoverController *)popover
{

    barButtonItem.title = master.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;

}

- (void) splitViewController:(UISplitViewController *)svc
      willShowViewController:(UIViewController *)aViewController
   invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}


@end
