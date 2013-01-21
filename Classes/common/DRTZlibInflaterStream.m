//
//  DRTZlibInflaterStream.m
//  DRTZlibStream
//
//  Created by Daniel Rodríguez Troitiño on 2013-01-20.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño
//

#import "DRTZlibInflaterStream.h"

#include <zlib.h>

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
  NSMutableData *outData = [NSMutableData dataWithLength:[inData length]];
  int ret;
  int previousTotalOut = _stream.total_out;
  _stream.avail_in = [inData length];
  _stream.next_in = (Bytef *)[inData bytes];
  BOOL done = NO;

  do
  {
    if (_stream.avail_in == 0)
    {
      [outData setLength:_stream.total_out - previousTotalOut];
      done = YES;
      break;
    }

    if (_stream.total_out - previousTotalOut >= [outData length])
    {
      [outData increaseLengthBy:[inData length] / 2];
    }
    _stream.next_out = [outData mutableBytes] + _stream.total_out - previousTotalOut;
    _stream.avail_out = [outData length] - _stream.total_out + previousTotalOut;

    ret = inflate(&_stream, Z_NO_FLUSH);
    switch (ret)
    {
      case Z_STREAM_END:
        self.isEndOfStream = YES;
        // fallthrough
      case Z_BUF_ERROR:
        [outData setLength:_stream.total_out - previousTotalOut];
        done = YES;
        break;
      case Z_NEED_DICT:
      case Z_ERRNO:
      case Z_DATA_ERROR:
      case Z_MEM_ERROR:
      case Z_VERSION_ERROR:
      case Z_STREAM_ERROR:
        self.isEndOfStream = YES;
        done = YES;
        outData = nil; // FIXME: maybe we can give some more info to the consumer
        break;
    }
  } while (!done);

  return [outData copy];
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
