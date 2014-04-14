//
//  Photo.h
//  Test
//
//  Created by Y. Liu on 4/11/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * takeDate;
@property (nonatomic, retain) Photographer *whoTook;

@end
