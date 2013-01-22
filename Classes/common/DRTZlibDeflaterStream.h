//
//  DRTZlibDeflaterStream.h
//  DRTZlibStream
//
//  Created by Daniel Rodríguez Troitiño on 2013-01-20.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño
//

#import <Foundation/Foundation.h>

@interface DRTZlibDeflaterStream : NSObject

@property (nonatomic, assign, readonly) NSInteger totalInputBytes;
@property (nonatomic, assign, readonly) NSInteger totalOutputBytes;

- (id)initWithCompressionLevel:(int)level;

- (NSData *)writeData:(NSData *)inData;
- (NSData *)writeData:(NSData *)inData error:(NSError *__autoreleasing *)error;
- (void)writeData:(NSData *)inData into:(NSMutableData *)outData error:(NSError *__autoreleasing *)error;

- (NSData *)flush;
- (NSData *)flushWithError:(NSError *__autoreleasing *)error;
- (void)flushInto:(NSMutableData *)outData error:(NSError *__autoreleasing *)error;

- (NSData *)close;
- (NSData *)closeWithError:(NSError *__autoreleasing *)error;
- (void)closeInto:(NSMutableData *)outData error:(NSError *__autoreleasing *)error;

@end
