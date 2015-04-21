//
//  CityPhotosViewController.h
//  TopSpots
//
//  Created by Thilagawathy Duraisamy on 16/04/2014.
//  Copyright (c) 2014 Thilagawathy Duraisamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityPhotosViewController : UITableViewController <NSURLSessionDelegate , NSURLSessionDownloadDelegate>


@property (nonatomic) NSString *placeId;
@property (nonatomic) NSString *cityName;

@end
