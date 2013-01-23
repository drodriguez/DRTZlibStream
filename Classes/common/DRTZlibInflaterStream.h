//
//  DRTZlibInflaterStream.h
//  DRTZlibStream
//
//  Created by Daniel Rodríguez Troitiño on 2013-01-20.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño
//

#import <Foundation/Foundation.h>

@interface DRTZlibInflaterStream : NSObject

@property (nonatomic, assign, readonly) BOOL isEndOfStream;
@property (nonatomic, assign, readonly) NSInteger totalInputBytes;
@property (nonatomic, assign, readonly) NSInteger totalOutputBytes;

- (NSData *)readFromData:(NSData *)inData;
- (NSData *)readFromData:(NSData *)inData error:(NSError *__autoreleasing *)error;
- (void)readFromData:(NSData *)inData into:(NSMutableData *)outData error:(NSError *__autoreleasing *)error;

- (void)close;

@end
