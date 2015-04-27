//
//  DBActivity.m
//  TopSpots
//
//  Created by Thilagawathy Duraisamy on 27/04/2015.
//  Copyright (c) 2015 Baskaran Loganathan. All rights reserved.
//

#import "DBActivity.h"

@implementation DBActivity

-(void) initRecordSave:(NSString *)name countryName:(NSString *)countryName cityName:(NSString *)cityName photo:(UIImage *) image
{
    // Prepare the record
    CKRecordID *rID = [[CKRecordID alloc] initWithRecordName:@"ph"];
    CKRecord *photoRecord = [[CKRecord alloc] initWithRecordType:@"SanpShot" recordID:rID];
    
    photoRecord[@"Name"] = name;
    photoRecord[@"CountryName"] = countryName;
    photoRecord[@"CityName"] = cityName;
    
    NSData *data = UIImagePNGRepresentation(image);
    photoRecord[@"Photo"]= data;
    
    [self saveRecord:photoRecord];
}

     
-(void) saveRecord: (CKRecord *)record
{
    //Save the record in default container cloud kit
    
    CKContainer *defalutContainer = [CKContainer defaultContainer];
    CKDatabase *publicDatabase = [defalutContainer publicCloudDatabase];
    
    [publicDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        
        if (!error) {
            NSLog(@"Record saved");
        }
        else
        {
            NSLog(@"Failed to save record");
        }
    }];
     
}

-(void) deleteRecord
{
    
}

-(void) readRecord
{
    
}


@end
