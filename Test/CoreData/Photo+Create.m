//
//  Photo+AssetLibrary.m
//  TripGo
//
//  Created by Tom Hsu on 4/26/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "Photo+Create.h"

@implementation Photo (Create)

+ (Photo *)photoWithAssetURL:(NSURL *)assetURL
      inManagedObejctContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"assetURL = %@", [assetURL absoluteString]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1)
    {
        // handle error
    } else if ([matches count])
    {
        photo = [matches firstObject];
    } else
    {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.assetURL = [assetURL absoluteString];
    }

    return photo;
}

+ (Photo *)emptyPhotoInManagedObejctContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    return photo;
}

@end
