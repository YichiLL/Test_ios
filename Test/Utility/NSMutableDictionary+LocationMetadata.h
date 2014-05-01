//
//  NSMutableDictionary+LocationMetadata.h
//  TripGo
//
//  Created by Tom Hsu on 4/30/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

/*
 Referenced
 http://stackoverflow.com/questions/3884060/saving-geotag-info-with-photo-on-ios4-1
 https://github.com/gpambrozio/GusUtils/blob/master/GusUtils/NSMutableDictionary%2BImageMetadata.m
 */
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSMutableDictionary (LocationMetadata)

- (void)setUserComment:(NSString*)comment;
- (void)setDateOriginal:(NSDate *)date;
- (void)setDateDigitized:(NSDate *)date;
- (void)setMake:(NSString*)make model:(NSString*)model software:(NSString*)software;
- (void)setDescription:(NSString*)description;
- (void)setKeywords:(NSString*)keywords;
- (void)setImageOrientation:(UIImageOrientation)orientation;
- (void)setDigitalZoom:(CGFloat)zoom;
- (void)setHeading:(CLHeading*)heading;

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, assign) CLLocationDirection trueHeading;

@end
