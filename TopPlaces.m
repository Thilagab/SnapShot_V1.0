//
//  TopPlaces.m
//  TopSpots
//
//  Created by Thilagawathy Duraisamy on 7/04/2014.
//  Copyright (c) 2014 Thilagawathy Duraisamy. All rights reserved.
//

#import "TopPlaces.h"
#import "FlickrFetcher.h"
#import "CityPhotosViewController.h"
#import "DBActivity.h"

@interface TopPlaces ()

//@property (strong, nonatomic) NSData *QueryData;
@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) NSURLSession *urlSession;
@property (strong, nonatomic) NSURLSessionConfiguration *urlSessionConfig;


@property (strong, nonatomic) NSDictionary *resultOfQuery;
@property (strong, nonatomic) NSArray *topPlaces;
@property (strong, nonatomic) NSMutableDictionary *dictionaryWithCountry;
@property (nonatomic) NSString *country;
@property (nonatomic) NSInteger *count;


@end

@implementation TopPlaces

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:@"nature.png"];
    [DBActivity initRecordSave:@"siteseeing" countryName:@"Europe" cityName:@"paris" photo:image];

    // Query the country top places
    self.url = [FlickrFetcher  URLforTopPlaces];
    
    self.urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.urlSession = [NSURLSession sessionWithConfiguration:self.urlSessionConfig
                                                    delegate:self
                                               delegateQueue:nil];
    
    NSURLSessionDownloadTask *downloadTask = [self.urlSession downloadTaskWithURL: self.url];
    
    [downloadTask resume];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@" didCompleteWithError:  %@",[error localizedDescription]);
        
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    
    // Download data for top 100 places and store it in.
    NSData *data1 = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultOfQuery = [NSJSONSerialization JSONObjectWithData:data1 options:0 error:Nil];
        
        self.topPlaces = [self.resultOfQuery valueForKeyPath:FLICKR_RESULTS_PLACES];
        
        self.dictionaryWithCountry = [[NSMutableDictionary alloc] init];
        
        self.topPlaces = [self collectingCountryAndCity];

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
    return [self.dictionaryWithCountry count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  
    int i=0;
    NSArray *key = [self.dictionaryWithCountry allKeys];
    NSSortDescriptor *des =[[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    key = [key sortedArrayUsingDescriptors:@[des]];
    
    NSString *strName = key[section];
   
    for (NSString *str in [self.topPlaces valueForKey:FLICKR_PLACE_NAME])
    {
        NSArray *Content = [str componentsSeparatedByString:@","];
            
        if ([strName isEqualToString:Content[2]])
            i++;
            
    }
    
    return i;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Sort in alphabtical order - based on country names
    NSArray *key = [self.dictionaryWithCountry allKeys];
    NSSortDescriptor *des =[[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    key = [key sortedArrayUsingDescriptors:@[des]];
  
    return key[section];
  }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Flickr Photo Cell"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
    }
   
    
    
    // Configure the cell...
    NSArray *key = [self.dictionaryWithCountry allKeys];
    NSSortDescriptor *des =[[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    key = [key sortedArrayUsingDescriptors:@[des]];
    NSString *strName;
    strName =   key[indexPath.section];
    
    if (indexPath.row == 0) {
        self.count = 0;
    }
    
    int match = 0;
    // Seperate the data using comma
    for (NSString *str in [self.topPlaces valueForKey:FLICKR_PLACE_NAME])
    {
        NSArray *content = [str componentsSeparatedByString:@","];
        
        if ([strName isEqualToString:content[2]])
        {
            if ( indexPath.row == match) {
                cell.textLabel.text = content[0];
                cell.detailTextLabel.text = content[1];
                self.count++;
                match++;
            }
            else
                match++;
        }
    }
    return cell;
}


- (NSMutableArray *) collectingCountryAndCity
{
    // Seperating country name and city name
    
    NSMutableArray *unsortedList = [self.topPlaces mutableCopy];
    NSMutableArray *sortedList = [[NSMutableArray alloc]  init];
    
    NSString *firstCountry;
    NSString *firstCity;
    NSString *secondCountry;
    NSString *secondCity;
    NSString *firstName;
    NSString *secondName;
    
    int i = 0;
    int j = 1;

    // Sorting the data in order
    while (unsortedList.count > 1)
    {
        i = 0;
        j = 1;
    
        firstName = [unsortedList[i] valueForKeyPath:FLICKR_PLACE_NAME];
        NSMutableArray *listOfFirstContent= (NSMutableArray*)[firstName componentsSeparatedByString:@","];
        
        secondName = [unsortedList[j] valueForKeyPath:FLICKR_PLACE_NAME];
        NSMutableArray *listOfSecondContent = (NSMutableArray*)[secondName componentsSeparatedByString:@","];
       
        while (j <  unsortedList.count)
        {
            if (listOfFirstContent.count == 3)
            {
                if(listOfSecondContent.count == 3)
                {
                    firstCountry = listOfFirstContent[2];
                    secondCountry = listOfSecondContent[2];
                    NSComparisonResult result = [firstCountry compare:secondCountry];
    
                    if ( result == NSOrderedSame )
                    {
                        firstCity = listOfFirstContent[0];
                        secondCity = listOfSecondContent[0];
                        result = [firstCity compare:secondCity];
                        
                        if (result == NSOrderedDescending)
                        {
                            listOfFirstContent = listOfSecondContent;
                            i = j;
                        }
                    
                        j++;
                        if (j < unsortedList.count)
                        {
                            secondName = [unsortedList[j] valueForKeyPath:FLICKR_PLACE_NAME];
                            listOfSecondContent = (NSMutableArray*)[secondName componentsSeparatedByString:@","];
                        }
                        else
                            NSLog(@" out of boundry %i",  j);
                    }
                    else if (result  ==  NSOrderedDescending)
                    {
                        listOfFirstContent = listOfSecondContent;
                        i = j;
                    }
                  
                    j++;
                    if (j < unsortedList.count)
                    {
                        secondName = [unsortedList[j] valueForKeyPath:FLICKR_PLACE_NAME];
                        listOfSecondContent = (NSMutableArray*)[secondName componentsSeparatedByString:@","];
                    }
                    else
                        NSLog(@" out of boundry %i",  j);
                }
                else
                {
                    [unsortedList removeObjectAtIndex:j];
                    if (j < unsortedList.count)
                    {
                        secondName = [unsortedList[j] valueForKeyPath:FLICKR_PLACE_NAME];
                        listOfSecondContent = (NSMutableArray*)[secondName componentsSeparatedByString:@","];
                    }
                    else
                        NSLog(@" out of boundry %i",  j);
                }
            }
            else if(listOfSecondContent.count == 3)
            {
                [unsortedList removeObjectAtIndex:i];
                listOfFirstContent = listOfSecondContent;
                i =j;
       
                j++;
                if (j < unsortedList.count)
                {
                    secondName = [unsortedList[j] valueForKeyPath:FLICKR_PLACE_NAME];
                    listOfSecondContent = (NSMutableArray*)[secondName componentsSeparatedByString:@","];
                }
            }
            else
            {
                if (j < unsortedList.count)
                {
                    [unsortedList removeObjectAtIndex:i];
                    [unsortedList removeObjectAtIndex:j];
               
                    firstName = [unsortedList[i] valueForKeyPath:FLICKR_PLACE_NAME];
                    listOfFirstContent = (NSMutableArray*)[firstName componentsSeparatedByString:@","];
                    
                    secondName = [unsortedList[j] valueForKeyPath:FLICKR_PLACE_NAME];
                    listOfSecondContent = (NSMutableArray*)[secondName componentsSeparatedByString:@","];
                }
            }
        }
        
            [sortedList addObject:unsortedList[i]];
            [self.dictionaryWithCountry setObject:unsortedList[i] forKey:listOfFirstContent[2]];
            [unsortedList removeObjectAtIndex:i];
     }
    
    return sortedList;
}



- (NSArray *) alphabeticalOrder
{
    // Sorting
    NSMutableArray *unsortedList = (NSMutableArray *)self.topPlaces;
    NSArray *sortedList;
    NSString *countryName = @"_content";
    NSSortDescriptor *countryList = [[NSSortDescriptor alloc] initWithKey:countryName ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSArray *alphabeticalCountry = [NSArray arrayWithObjects:countryList, nil];
    sortedList = [unsortedList sortedArrayUsingDescriptors:alphabeticalCountry];
    
    return sortedList;
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(NSString *) pickUpPhotoID:(NSString *) cityName
{
    // Based on the place select the photo id
    NSString *placeId;
    // BOOL found = FALSE;
    int i =0;
    
    for (NSString *str in [self.topPlaces valueForKey:FLICKR_PLACE_NAME])
    {
        NSDictionary  *pid = self.topPlaces[i];
        placeId = [pid valueForKey:FLICKR_PLACE_ID];
        NSArray *content = [str componentsSeparatedByString:@","];
        
        if ([cityName isEqualToString:content[0]])
        {
            //found = TRUE;
            break;
        }
        i++;
    }
    return placeId;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"City Photos List"] )
    {
        if ([[segue destinationViewController] isKindOfClass:[CityPhotosViewController class]] )
        {
            CityPhotosViewController *cityPhotos = [segue destinationViewController];
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cityPhotos.cityName = cell.textLabel.text;
            cityPhotos.placeId = [self pickUpPhotoID:cityPhotos.cityName];
            
         }
    }
}

@end
