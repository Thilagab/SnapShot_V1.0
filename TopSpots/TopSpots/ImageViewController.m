//
//  ImageViewController.m
//  TopSpots
//
//  Created by Thilagawathy Duraisamy on 22/04/2014.
//  Copyright (c) 2014 Thilagawathy Duraisamy. All rights reserved.
//

#import "ImageViewController.h"
#import "FlickrFetcher.h"

@interface ImageViewController () < UIScrollViewDelegate >


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeProgressBar;

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (strong, nonatomic) UIImageView *imageView;


@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) setImageScrollView:(UIScrollView *)imageScrollView
{
    // Scroll view settings
    _imageScrollView = imageScrollView;
    _imageScrollView.minimumZoomScale = 0.2;
    _imageScrollView.maximumZoomScale = 2.0;
    _imageScrollView.delegate = self;
    self.imageScrollView.contentSize = self.photoImage ? self.photoImage.size : CGSizeZero;
    
    
}
- (UIImageView *) imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:self.photoImage];
    }
    
    return _imageView;
    
}

- (void) setPhotoImage:(UIImage *)photoImage
{
    
    // Photo settings
    self.imageScrollView.zoomScale = 1.0;
    
    self.imageView.image = photoImage;
    
    [self.imageView sizeToFit];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.imageScrollView.contentSize =  photoImage ? photoImage.size : CGSizeZero;

   
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}



- (void) startImageDownloading
{
    // Download the photo based on place
    self.activeProgressBar = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.imageView addSubview:self.activeProgressBar];
    [self.activeProgressBar startAnimating];
    
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:self.url
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@" error in downloading using session   %@",[error localizedDescription]);
                                                                
                                                            }
                                                            UIImage* tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                self.photoImage = tempImage;
                                                                [self.activeProgressBar stopAnimating];
                                                            });
                                                            
                                                        }];
    [downloadTask resume];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startImageDownloading];
    
	// Do any additional setup after loading the view.
    
    [self.imageScrollView addSubview:self.imageView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_imageScrollView setScrollEnabled:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
