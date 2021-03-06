//
//  DBActivity.h
//  TopSpots
//
//  Created by Thilagawathy Duraisamy on 27/04/2015.
//  Copyright (c) 2015 Baskaran Loganathan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

@interface DBActivity : NSObject


+(void) initRecordSave:(NSString *)name countryName:(NSString *)countryName cityName:(NSString *)cityName photo:(UIImage *) image;
+(void) saveRecord: (CKRecord *)record;

@end
