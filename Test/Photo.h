//
//  Photo.h
//  Test
//
//  Created by Y. Liu on 4/14/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * takeDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Photographer *whoTook;

@end
