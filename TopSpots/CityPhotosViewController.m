//
//  CityPhotosViewController.m
//  TopSpots
//
//  Created by Thilagawathy Duraisamy on 16/04/2014.
//  Copyright (c) 2014 Thilagawathy Duraisamy. All rights reserved.
//

#import "CityPhotosViewController.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"

@interface CityPhotosViewController ()

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) NSDictionary *resultOfQuery;
@property (strong, nonatomic) NSArray *ArrayOfCityPhotos;
@property (strong, nonatomic) NSMutableDictionary *dictionaryWithCountry;
@property (strong, nonatomic) UIImage* smallphotoImage;
@property (strong, nonatomic) NSMutableArray *thumpnailPhotoArray;

@property (strong, nonatomic) NSURLSession *urlSession;
@property (strong, nonatomic) NSURLSessionConfiguration *urlSessionConfig;


@end

@implementation CityPhotosViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
      
    });

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.thumpnailPhotoArray = [[ NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Query the country top places
    self.url = [FlickrFetcher  URLforPhotosInPlace:self.placeId maxResults:100];
    
    self.urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.urlSession = [NSURLSession sessionWithConfiguration:self.urlSessionConfig
                                                    delegate:self
                                               delegateQueue:nil];
    
    
    NSURLSessionDownloadTask *downloadTask = [self.urlSession downloadTaskWithURL: self.url];
    [downloadTask resume];

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    NSData *data1 = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        self.resultOfQuery = [NSJSONSerialization JSONObjectWithData:data1 options:0 error:Nil];
        
        self.ArrayOfCityPhotos = [self.resultOfQuery valueForKeyPath:FLICKR_RESULTS_PHOTOS];

        [self.tableView reloadData];
        
    });
    
}




-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.ArrayOfCityPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"City Photos";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
  
    
    // Configure the cell...
  /*  NSArray *key = [self.dictionaryWithCountry allKeys];
    NSSortDescriptor *des =[[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    key = [key sortedArrayUsingDescriptors:@[des]];
    NSString *strName;
    strName =   key[indexPath.section];
  */
    self.smallphotoImage = nil;
  //  cell.imageView.image = nil;
    
    
    // Download data
    NSArray *photoArray = [self.ArrayOfCityPhotos valueForKeyPath:FLICKR_PHOTO_TITLE];
    __block NSArray *photoDescArray = [self.ArrayOfCityPhotos valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
  

    self.url = [FlickrFetcher  URLforPhoto:[self.ArrayOfCityPhotos objectAtIndex:indexPath.row] format:FlickrPhotoFormatSquare];
    
    NSURLSession* session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:self.url
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            if (error) {
                                                                NSLog(@" Error  in session download : %@",[error localizedDescription]);
                                                                
                                                            }
                                                            
                                                            UIImage* tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                                            self.smallphotoImage = tempImage;

                                                          /*  if (tempImage == nil) {
                                                                NSLog(@"image is not there");
                                                            }
                                                            */
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                
                                                                if (photoArray[indexPath.row])
                                                                {
                                                                    cell.textLabel.text = photoArray[indexPath.row];
                                                                    cell.imageView.image = self.smallphotoImage;
                                                                    
                                                                    NSString *descriptionOfCity = photoDescArray[indexPath.row];
                                                                    if (descriptionOfCity)
                                                                        cell.detailTextLabel.text = descriptionOfCity;
                                                                    else
                                                                        cell.detailTextLabel.text = @"Unknown";
                                                                }
                                                                else
                                                                {
                                                                    photoDescArray = [self.ArrayOfCityPhotos valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
                                                                    cell.imageView.image = self.smallphotoImage;
                                                                    
                                                                    if (photoDescArray[indexPath.row])
                                                                    {
                                                                        cell.textLabel.text = photoDescArray[indexPath.row];
                                                                        cell.detailTextLabel.text = @"Unknown";
                                                                    }
                                                                    else
                                                                    {
                                                                        cell.textLabel.text = @"Unknown";
                                                                        cell.detailTextLabel.text = @"Unknown";
                                                                    }
                                                                    
                                                                }
                                                            });
                                                            
                                                        }];
     [downloadTask resume];
     return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Image Segue"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[ImageViewController class]] )
        {
            ImageViewController *cityImage = [segue destinationViewController];
            NSIndexPath* path = [self.tableView indexPathForSelectedRow];
            
            NSDictionary *tempDic = [ self.ArrayOfCityPhotos objectAtIndex:path.row];
            cityImage.url = [FlickrFetcher  URLforPhoto:tempDic format:FlickrPhotoFormatLarge];
            //NSString *title = [tempDic valueForKeyPath:FLICKR_PHOTO_TITLE];
        

        }
    }
    
}


@end
