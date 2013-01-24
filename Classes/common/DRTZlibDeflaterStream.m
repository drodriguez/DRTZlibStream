//
//  DRTZlibDeflaterStream.m
//  DRTZlibStream
//
//  Created by Daniel Rodríguez Troitiño on 2013-01-20.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño
//

#import "DRTZlibDeflaterStream.h"
#import "DRTZlibStreamErrors.h"

#include <zlib.h>

static const NSInteger kChunkSize = 512;

@interface DRTZlibDeflaterStream ()

@property (nonatomic, assign) BOOL isEndOfStream;

@end

@implementation DRTZlibDeflaterStream
{
  z_stream _stream;
  BOOL _isClosed;
}

- (NSInteger)totalInputBytes
{
  return _stream.total_in;
}

- (NSInteger)totalOutputBytes
{
  return _stream.total_out;
}

- (id)init
{
  return [self initWithCompressionLevel:Z_DEFAULT_COMPRESSION];
}

- (id)initWithCompressionLevel:(int)level
{
  if ((self = [super init]))
  {
    _stream.zalloc = Z_NULL;
    _stream.zfree = Z_NULL;
    _stream.opaque = Z_NULL;
    _stream.total_in = 0;
    _stream.total_out = 0;

    if (deflateInit(&_stream, level) != Z_OK)
    {
      self = nil;
    }
  }

  return self;
}

- (void)dealloc
{
  (void)[self close];
}

- (NSData *)writeData:(NSData *)inData
{
  return [self writeData:inData error:nil];
}

- (NSData *)writeData:(NSData *)inData error:(NSError *__autoreleasing *)error
{
  NSMutableData *outData = [NSMutableData dataWithCapacity:kChunkSize];
  [self writeData:inData into:outData error:error];
  return [outData copy];
}

- (void)writeData:(NSData *)inData into:(NSMutableData *)outData error:(NSError *__autoreleasing *)error;
{
  _stream.avail_in = (uInt) [inData length];
  _stream.next_in = (Bytef *)[inData bytes];

  while (_stream.avail_in > 0)
  {
    int err = [self deflateWithFlush:Z_NO_FLUSH into:outData error:error];
    if (err == Z_STREAM_END)
    {
      break;
    }
  }
}

- (NSData *)flush
{
  return [self flushWithError:nil];
}

- (NSData *)flushWithError:(NSError *__autoreleasing *)error
{
  NSMutableData *outData = [NSMutableData dataWithCapacity:kChunkSize];
  [self flushInto:outData error:error];
  return [outData copy];
}

- (void)flushInto:(NSMutableData *)outData error:(NSError *__autoreleasing *)error;
{
  while (YES)
  {
    _stream.avail_in = 0;
    uLong previousTotalOut = _stream.total_out;
    int ret = [self deflateWithFlush:Z_SYNC_FLUSH into:outData error:error];
    if (_stream.total_out > previousTotalOut &&
		_stream.total_out - previousTotalOut < kChunkSize)
    {
      break;
    }

    if (ret == Z_STREAM_END)
    {
      break;
    }
  }
}

- (NSData *)close
{
  return [self closeWithError:nil];
}

- (NSData *)closeWithError:(NSError *__autoreleasing *)error
{
  NSMutableData *outData = [[NSMutableData alloc] initWithCapacity:kChunkSize];
  [self closeInto:outData error:error];
  return [outData copy];
}

- (void)closeInto:(NSMutableData *)outData error:(NSError *__autoreleasing *)error
{
  if (!_isClosed)
  {
    _isClosed = YES;
    [self finishInto:outData error:error];
    (void)deflateEnd(&_stream);
  }
}

- (void)finishInto:(NSMutableData *)outData error:(NSError *__autoreleasing *)error
{
  _stream.avail_in = 0;
  while ([self deflateWithFlush:Z_FINISH into:outData error:error] != Z_STREAM_END)
  {
    // nothing, just go until Z_STREAM_END
  }
}

- (int)deflateWithFlush:(int)flush into:(NSMutableData *)outData error:(NSError *__autoreleasing *)error
{
  NSMutableData *buffer = [[NSMutableData alloc] initWithLength:kChunkSize];
  uLong previousTotalOut = _stream.total_out;
  _stream.next_out = [buffer mutableBytes];
  _stream.avail_out = kChunkSize;

  int err = deflate(&_stream, flush);
  switch (err)
  {
    case Z_OK:
    case Z_STREAM_END:
      break;
    case Z_BUF_ERROR:
      if (_stream.avail_in <= 0 && flush != Z_FINISH)
      {
        break;
      }
    default:
      if (error)
      {
        // TODO: we should provide more specific info
        *error = [NSError errorWithDomain:DRTZlibStreamErrorDomain code:DRTErrorCodeDeflate userInfo:nil];
      }
  }

  if (_stream.total_out > previousTotalOut)
  {
    [buffer setLength:_stream.total_out - previousTotalOut];
    [outData appendData:buffer];
  }

  return err;
}

@end
