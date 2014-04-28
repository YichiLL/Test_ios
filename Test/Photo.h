//
//  Photo.h
//  TripGo
//
//  Created by Y. Liu on 4/28/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * assetURL;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSDate * takeDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * weather;

@end
