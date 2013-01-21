//
//  DRTZlibDeflaterStream.m
//  DRTZlibStream
//
//  Created by Daniel Rodríguez Troitiño on 2013-01-20.
//  Copyright (c) 2013 Daniel Rodríguez Troitiño
//

#import "DRTZlibDeflaterStream.h"

#include <zlib.h>

static const NSInteger kChunkSize = 512;

@interface DRTZlibDeflaterStream ()

@property (nonatomic, assign) BOOL isEndOfStream;

@end

@implementation DRTZlibDeflaterStream
{
  z_stream _stream;
  BOOL _isClosed;
  NSMutableData *_buffer;
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
  NSMutableData *outData = [NSMutableData dataWithCapacity:kChunkSize];
  int ret;
  BOOL done = NO;

  _stream.avail_in = [inData length];
  _stream.next_in = (Bytef *)[inData bytes];

  do
  {
    ret = [self deflateWithFlush:Z_NO_FLUSH];
    switch (ret)
    {
      case Z_OK:
        [outData appendData:_buffer];
        break;
      case Z_STREAM_END:
      case Z_BUF_ERROR:
        if (_buffer)
        {
          [outData appendData:_buffer];
        }
        done = YES;
        break;
      case Z_NEED_DICT:
      case Z_ERRNO:
      case Z_DATA_ERROR:
      case Z_MEM_ERROR:
      case Z_VERSION_ERROR:
      case Z_STREAM_ERROR:
        done = YES;
        _buffer = nil;  // FIXME: maybe we can give some more info to the consumer
    }
  } while (!done);

  return outData;
}

- (NSData *)flush
{
  NSMutableData *outData = [NSMutableData dataWithCapacity:kChunkSize];
  while (YES)
  {
    _stream.avail_in = 0;
    int ret = [self deflateWithFlush:Z_SYNC_FLUSH];
    if (_buffer)
    {
      [outData appendData:_buffer];
    }
    if ((long long)_stream.total_out - (long long)_stream.avail_out < kChunkSize)
    {
      break;
    }
    if (ret == Z_STREAM_END)
    {
      break;
    }
  }

  return [outData copy];
}

- (NSData *)close
{
  NSData *result = nil;
  if (!_isClosed)
  {
    _isClosed = YES;
    result = [self finish];
    (void)deflateEnd(&_stream);
  }

  return result;
}

- (NSData *)finish
{
  _stream.avail_in = 0;
  (void)[self deflateWithFlush:Z_FINISH];
  return [_buffer copy];
}

- (int)deflateWithFlush:(int)flush
{
  _buffer = [[NSMutableData alloc] initWithLength:kChunkSize];
  int previousTotalOut = _stream.total_out;
  _stream.next_out = [_buffer mutableBytes];
  _stream.avail_out = kChunkSize;
  int ret = deflate(&_stream, flush);
  switch (ret)
  {
    case Z_OK:
    case Z_STREAM_END:
      break;
    case Z_BUF_ERROR:
      if (_stream.avail_in <= 0 && flush != Z_FINISH)
      {
        break;
      }
      // otherwise, fallthrough
    case Z_NEED_DICT:
    case Z_ERRNO:
    case Z_DATA_ERROR:
    case Z_MEM_ERROR:
    case Z_VERSION_ERROR:
    case Z_STREAM_ERROR:
      _buffer = nil;  // FIXME: maybe we can give some more info to the consumer
  }

  [_buffer setLength:_stream.total_out - previousTotalOut];

  return ret;
}

@end
