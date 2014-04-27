//
//  DocumentHandler.h
//  Test
//
//  Created by Y. Liu on 4/13/14.
//  Copyright (c) 2014 Y. Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

typedef void (^OnDocumentReady) (UIManagedDocument *document);


@interface DocumentHandler : NSObject

@property (strong, nonatomic) UIManagedDocument *document;

+ (DocumentHandler *)sharedDocumentHandler;
- (void)performWithDocument:(OnDocumentReady)onDocumentReady;

@end
