# DRTZlibStream

DRTZlibStream allows you to easily compress or uncompress network streams using [zlib](http://zlib.net/) (included by default in Mac OS X and iOS). Many networking protocols use or allow zlib compression for their streams, like HTTP 1.1, SSH, TLS, rsync, PPP, IP…

## How to use

### Installing

#### Using CocoaPods

1. Include the following line in your `Podfile`:
   ```
   pod 'DRTZlibStream', :git => 'https://github.com/drodriguez/DRTZlibStream'
   ```
2. Run `pod install`

#### Manually

1. Clone, add as a submodule or [download](https://github.com/drodriguez/DRTZlibStream/zipball/master) DRTZlibStream.
2. Add all the files under `Classes/common` to your project.
3. Add `libz.dylib` to your target “Link Binary with Libraries” phase.
4. Look at the Requirements section if you are not using ARC.

### Using

DRTZlibStream provides an _umbrella_ header `DRTZlibStream.h` that you should prefer to `#import` over the more specific ones.

Depending on what you need to do, you will either use `DRTZlibDeflaterStream` (compress) or `DRTZlibInflaterStream` (uncompress).

Supposing that `nextChunk` give us the next chunk available to be sent to the network, the following code will compress the data, and flush after each chunk.

``` objective-c
DRTZlibDeflaterStream *deflater = [[DRTZlibDeflaterStream alloc] init];
NSData *chunk = nil;
while ((chunk = [self nextChunk]))
{
  NSData *deflated = [deflater writeData:chunk];
  [self sendToSocket:deflated];
  NSData *flushed = [deflater flush];
  [self sendToSocket:flushed];
}
```

Similarly, supposing `receiveFromSocket` provides us with the data as it comes from the network, if we want to uncompress the data in the receiver side, we will do the following.

``` objective-c
DRTZlibInflaterStream *inflater = [[DRTZlibInflaterStream alloc] init];
NSData *chunk = nil;
while ((chunk = [self receiveFromSocket]))
{
  NSData *inflated = [inflater readFromData:chunk];
  [parser parseData:inflated];
}
```

Explore the project headers, there are more configurable versions of the read and write methods that maybe fit better your project.

## Requirements

DRTZlibStream should work in any iOS version and any Mac OS X version (64 bits), but have only been tested in iOS 5.0 and higher and Mac OS X 10.8.

DRTZlibStream uses ARC, so if you use it in a non-ARC project, and you are not using CocoaPods, you will need to use `-fobjc-arc` compiler flag on every DRTZlibStream source file.

To set a compiler flag in Xcode, go to your desidered target and select the “Build Phases” tab. Select all DRTZlibStream source files, press Enter, add `-fobjc-arc` and then “Done” to enable ARC for DRTZlibStream.

## Credits & Contact

DRTZlibStream was created by [Daniel Rodríguez Troitiño](http://github.com/drodriguez). You can follow me on Twitter [@yonosoytu](http://twitter.com/yonosoytu).

## License

DRTZlibStream is available under the MIT license. See LICENSE file for more info.
