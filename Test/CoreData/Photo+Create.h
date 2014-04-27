//
//  Photo+AssetLibrary.h
//  TripGo
//
//  Created by Tom Hsu on 4/26/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "Photo.h"

@interface Photo (Create)

+ (Photo *)photoWithAssetURL:(NSURL *)assetURL
  inManagedObejctContext:(NSManagedObjectContext *)context;

@end
