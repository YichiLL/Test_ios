//
//  Photo.h
//  TripGo
//
//  Created by Tom Hsu on 4/30/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * assetURL;
@property (nonatomic, retain) NSNumber * gpsCourse;
@property (nonatomic, retain) NSNumber * gpsLatitude;
@property (nonatomic, retain) NSDate * locationTimeStamp;
@property (nonatomic, retain) NSNumber * gpsLongitude;
@property (nonatomic, retain) NSNumber * gpsSpeed;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSDate * takeDateUTC;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * weather;
@property (nonatomic, retain) NSString * takeTimeZone;
@property (nonatomic, retain) NSNumber * timeZoneOffsetInHour;

@end
