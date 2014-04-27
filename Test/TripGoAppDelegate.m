//
//  YCLAppDelegate.m
//  Test
//
//  Created by Y. Liu on 3/24/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import "TripGoAppDelegate.h"
#import "DatabaseAvailability.h"

@interface TripGoAppDelegate()

@property (nonatomic,strong) UIManagedDocument *document;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation TripGoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self initDatabase];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - getter setter
- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    // let everyone who might be interested know this context is available
    // this happens very early in the running of our application
    // it would make NO SENSE to listen to this radio station in a View Controller that was segued to, for example
    // (but that's okay because a segued-to View Controller would presumably be "prepared" by being given a context to work in)
    NSDictionary *userInfo = self.managedObjectContext ? @{ DatabaseAvailabilityContext : self.managedObjectContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:DatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - Database Preparation
- (void)initDatabase
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"TripGoDatabaseFile"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    self.document = document;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) [self documentIsReady];
            if (!success) NSLog(@"couldn’t open document at %@", url);
        }];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) [self documentIsReady];
              if (!success) NSLog(@"couldn’t create document at %@", url);
          }];
    }
}

- (void) documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) { // start using document
        self.managedObjectContext = self.document.managedObjectContext;
    }
}

@end
