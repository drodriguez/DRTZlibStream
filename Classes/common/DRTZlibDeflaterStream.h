//
//  DRTZlibDeflaterStream.h
//  DRTZlibStream
//
//  Created by Daniel Rodríguez Troitiño on 2013-01-20.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño
//

#import <Foundation/Foundation.h>

@interface DRTZlibDeflaterStream : NSObject

@property (nonatomic, assign, readonly) BOOL isEndOfStream;
@property (nonatomic, assign, readonly) NSInteger totalInputBytes;
@property (nonatomic, assign, readonly) NSInteger totalOutputBytes;

- (id)initWithCompressionLevel:(int)level;
- (NSData *)writeData:(NSData *)inData;
- (NSData *)flush;
- (NSData *)close;

@end
