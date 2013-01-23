//
//  DRTZlibInflaterStream.m
//  DRTZlibStream
//
//  Created by Daniel Rodríguez Troitiño on 2013-01-20.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño
//

#import "DRTZlibInflaterStream.h"
#import "DRTZlibStreamErrors.h"

#include <zlib.h>

static const NSInteger kChunkSize = 512;

@interface DRTZlibInflaterStream ()

@property (nonatomic, assign) BOOL isEndOfStream;

@end

@implementation DRTZlibInflaterStream
{
  z_stream _stream;
  BOOL _isClosed;
}

- (id)init
{
  if ((self = [super init]))
  {
    _stream.zalloc = Z_NULL;
    _stream.zfree = Z_NULL;
    _stream.opaque = Z_NULL;
    _stream.total_in = 0;
    _stream.total_out = 0;

    if (inflateInit(&_stream) != Z_OK)
    {
      self = nil;
    }
  }

  return self;
}

- (void)dealloc
{
  [self close];
}

- (NSInteger)totalInputBytes
{
  return _stream.total_in;
}

- (NSInteger)totalOutputBytes
{
  return _stream.total_out;
}

- (NSData *)readFromData:(NSData *)inData
{
  return [self readFromData:inData error:nil];
}

- (NSData *)readFromData:(NSData *)inData error:(NSError *__autoreleasing *)error
{
  NSMutableData *outData = [[NSMutableData alloc] initWithCapacity:[inData length]];
  [self readFromData:inData into:outData error:nil];
  return [outData copy];
}

- (void)readFromData:(NSData *)inData into:(NSMutableData *)outData error:(NSError *__autoreleasing *)error
{
  NSError *theError = nil;
  _stream.avail_in = [inData length];
  _stream.next_in = (Bytef *)[inData bytes];

  while (!self.isEndOfStream)
  {
    if (_stream.avail_in == 0)
    {
        break;
    }

    uLong previousTotalOut = _stream.total_out;
    NSMutableData *buffer = [[NSMutableData alloc] initWithLength:kChunkSize];
    _stream.avail_out = kChunkSize;
    _stream.next_out = (Bytef *)[buffer mutableBytes];

    int err = Z_OK;
    while (theError == nil && err != Z_BUF_ERROR && _stream.avail_out > 0)
    {
      if (_stream.avail_in == 0)
      {
        break;
      }

      err = inflate(&_stream, Z_NO_FLUSH);
      switch (err)
      {
        case Z_NEED_DICT:
        case Z_ERRNO:
        case Z_DATA_ERROR:
        case Z_MEM_ERROR:
        case Z_VERSION_ERROR:
        case Z_STREAM_ERROR:
          // TODO: give more information in the userInfo?
          theError = [NSError errorWithDomain:DRTZlibStreamErrorDomain code:DRTErrorCodeInflate userInfo:nil];
          break;
        case Z_STREAM_END:
          self.isEndOfStream = YES;
          // fallthrough
        case Z_BUF_ERROR:
          break;
      }
    }

    if (theError == nil)
    {
      [buffer setLength:_stream.total_out - previousTotalOut];
      [outData appendData:buffer];
    }
  }
}

- (void)close
{
  if (!_isClosed)
  {
    _isClosed = YES;
    (void)inflateEnd(&_stream);
  }
}

@end
