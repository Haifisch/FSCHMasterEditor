//
//  NDSCartridgeData.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/10/22.
//
#import <Cocoa/Cocoa.h>
#import "NDSCartridgeData.h"
#import "PreferencesManager.h"
#include "colorspacehandler.h"
#include <CommonCrypto/CommonDigest.h>

#define ROM_ICON_WIDTH 32
#define ROM_ICON_HEIGHT 32

static uint16_t MODBUS_CRC16_v1( const unsigned char *buf, unsigned int len )
{
    uint16_t crc = 0xFFFF;
    char i = 0;

    while(len--)
    {
        crc ^= (*buf++);

        for(i = 0; i < 8; i++)
        {
            if( crc & 1 )
            {
                crc >>= 1;
                crc ^= 0xA001;
            }
            else
            {
                crc >>= 1;
            }
        }
    }
    return crc;
}

@implementation NDSBannerAnimation

- (instancetype)initWithDuration:(float)duration bitmapIndex:(int)index flipVertical:(BOOL)flipV flipHorizontal:(BOOL)flipH {
    if (self = [super init]) {
        self.duration = [NSNumber numberWithFloat:duration];
        self.bitmapIndex = [NSNumber numberWithInt:index];
        self.FlipVertial = flipV;
        self.FlipHorizontal = flipH;
    }
    return self;
}
@end

@implementation NDSCartridgeData

- (NSString *)sha256HashFor:(NSFileHandle *)inputFile
{
    [inputFile seekToFileOffset:0];
    CC_SHA256_CTX ctx;
    CC_SHA256_Init(&ctx);
    
    [inputFile seekToEndOfFile];
    int totalSize = (int)[inputFile offsetInFile];
    int offset = 0;
    while (offset < totalSize) {
        [inputFile seekToFileOffset:offset];
        CC_SHA256_Update(&ctx, [[inputFile readDataOfLength:16] bytes], 16);
        offset += 16;
    }
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256_Final(bytes, &ctx);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x", bytes[i]];
    }
    return ret;
}

- (instancetype)initWithHeaderData:(NSData *)databuffer fileHandle:(nonnull NSFileHandle *)handle {
    self = [super init];
    NSInteger romHeaderBytesToRead = [[PreferencesManager sharedManager] bytesToRead];
    self.ROMSHA256 = [self sha256HashFor:handle];
    [handle seekToFileOffset:0x0];

    [databuffer getBytes:&self->header length:sizeof(sNDSHeaderExt)];
    unsigned char *headerBuf = (unsigned char *)malloc(romHeaderBytesToRead);
    [databuffer getBytes:headerBuf length:romHeaderBytesToRead];
    self.RecalculatedHeaderCRC16 = MODBUS_CRC16_v1(headerBuf, 0x15e);
    free(headerBuf);
    
    [handle seekToFileOffset:0x0];
    self.romHeaderData = [handle readDataOfLength:romHeaderBytesToRead];
    [handle seekToFileOffset:self->header.bannerOffset];
    self->banner = *(sNDSBannerExt *)[[handle readDataOfLength:sizeof(sNDSBannerExt)] bytes];

    //NSLog(@"%@", [[[NSData alloc] initWithBytes:&banner.dsi_icon[0] length:512] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]);
    self.bannerIcon = [self getBannerIcon];
    if (self->banner.version >= 0x0103) {
        self.animatedBannerIcons = [self getAnimatedBannerIcons];
        self.hasAnimatedBanner = true;
    }
    
    NSMutableArray *animationArray = [[NSMutableArray alloc] init];
    for (int z = 0; z < 64; z++) {
        uint16_t frame1 = self->banner.dsi_seq[z];
        unsigned short frameLen = frame1 & 0xFF;
        unsigned short bitmapIndex = (frame1 >> 8) & 7;
        if (frameLen == 0) {
            self.bannerIconAnimationFramesMax = z;
            break;
        }
        [animationArray addObject:[[NDSBannerAnimation alloc] initWithDuration:frameLen bitmapIndex:bitmapIndex flipVertical:NO flipHorizontal:NO]];
    }
    self.bannerAnimation = [animationArray copy];
    
    [handle seekToFileOffset:0x230];
    NSData *twlEmagcode = [handle readDataOfLength:4];
    NSString *twlEmagcodeStr = [NSString stringWithCString:(const char*)[twlEmagcode bytes] encoding:NSASCIIStringEncoding];
    if ([twlEmagcodeStr length] > 0) {
        NSLog(@"found twl emagcode");
        //[handle seekToFileOffset:0x1BF];
        //NSData *twlFileflags = [handle readDataOfLength:1];
        //unsigned int fileFlags = *(unsigned int *)[twlFileflags bytes];
    }
    NSLog(@"RecalculatedHeaderCRC16: %x", self.RecalculatedHeaderCRC16);
    NSLog(@"header crc: %x", self->header.headerCRC16);
    
    NSLog(@"RecalculatedSecureAreaCRC16: %x", self.RecalculatedSecureAreaCRC16);
    NSLog(@"secureCRC16: %x", self->header.secureCRC16);
    
    self.RecalcChecksumMatchesHeader = (self.RecalculatedHeaderCRC16 == self->header.headerCRC16);
    if (!self.RecalcChecksumMatchesHeader) {
        NSLog(@"checksum mismatch!");
    }
    
    self.GameTitle = [NSString stringWithCString:self->header.gameTitle encoding:NSASCIIStringEncoding];
    self.GameCode = [NSString stringWithCString:self->header.gameCode encoding:NSASCIIStringEncoding];
    self.Makercode = [NSString stringWithCString:self->header.makercode encoding:NSASCIIStringEncoding];
    
    self.UnitCode = self->header.unitCode;
    self.DeviceType = self->header.deviceType;
    self.DeviceSize = self->header.deviceSize;
    self.RomVersion = self->header.romversion;
    self.Flags = self->header.flags;
    
    self.HeaderSize = self->header.headerSize;
    self.RomSize = self->header.romSize;
    
    self.Arm9romOffset = self->header.arm9romOffset;
    self.Arm9executeAddress = self->header.arm9executeAddress;
    self.Arm9destination = self->header.arm9destination;
    self.Arm9binarySize = self->header.arm9binarySize;
    
    self.Arm7romOffset = self->header.arm7romOffset;
    self.Arm7executeAddress = self->header.arm7executeAddress;
    self.Arm7destination = self->header.arm7destination;
    self.Arm7binarySize = self->header.arm7binarySize;
    
    self.HeaderCRC16 = self->header.headerCRC16;
    self.SecureCRC16 = self->header.secureCRC16;
    self.LogoCRC16 = self->header.logoCRC16;
    
    self.BannerOffset = self->header.bannerOffset;
    return self;
}

- (sNDSHeaderExt *)rawHeader {
    return &header;
}

- (sNDSBannerExt *)banner {
    return &banner;
}

- (NSImage *)getBannerIcon {
    NSImage *newImage = nil;
    
    newImage = [[NSImage alloc] initWithSize:NSMakeSize(32, 32)];
    if(newImage == nil)
    {
        return newImage;
    }
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                         pixelsWide:ROM_ICON_WIDTH
                                                                         pixelsHigh:ROM_ICON_HEIGHT
                                                                      bitsPerSample:8
                                                                    samplesPerPixel:4
                                                                           hasAlpha:YES
                                                                           isPlanar:NO
                                                                     colorSpaceName:NSCalibratedRGBColorSpace
                                                                        bytesPerRow:ROM_ICON_WIDTH * 4
                                                                       bitsPerPixel:32];
    
    if(imageRep == nil)
    {
        newImage = nil;
        return newImage;
    }
    
    uint32_t *bitmapData = (uint32_t *)[imageRep bitmapData];
    [self RomIconToRGBA8888:bitmapData iconPixelData:(uint32_t *)banner.icon paletteData:(uint16_t *)banner.palette];
    
    [newImage addRepresentation:imageRep];
    return newImage;
}

- (NSArray<NSImage *> *)getAnimatedBannerIcons {
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 8; i++) {
        NSImage *newImage = nil;
        newImage = [[NSImage alloc] initWithSize:NSMakeSize(32, 32)];
        if(newImage == nil)
        {
            return nil;
        }
        NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                             pixelsWide:ROM_ICON_WIDTH
                                                                             pixelsHigh:ROM_ICON_HEIGHT
                                                                          bitsPerSample:8
                                                                        samplesPerPixel:4
                                                                               hasAlpha:YES
                                                                               isPlanar:NO
                                                                         colorSpaceName:NSCalibratedRGBColorSpace
                                                                            bytesPerRow:ROM_ICON_WIDTH * 4
                                                                           bitsPerPixel:32];
        if(imageRep == nil)
        {
            newImage = nil;
            return nil;
        }
        uint32_t *bitmapData = (uint32_t *)[imageRep bitmapData];
        [self RomIconToRGBA8888:bitmapData iconPixelData:(uint32_t *)banner.dsi_icon[i] paletteData:(uint16_t *)banner.palette];
        [newImage addRepresentation:imageRep];
        
        [imageArray addObject:newImage];
    }
    return imageArray;
}



-(void)RomIconToRGBA8888:(uint32_t *)bitmapData iconPixelData:(uint32_t *)iconPixPtr paletteData:(uint16_t *)clut4
{
    if (bitmapData == NULL)
    {
        return;
    }
    
    //const RomBanner &ndsRomBanner = gameInfo.getRomBanner(); // Contains the memory addresses we need to get our read pointer locations.
    //const uint32_t *iconPixPtr = (uint32_t *)banner.icon; // Read pointer for the icon's pixel data.
    
    // Setup the 4-bit CLUT.
    //
    // The actual color values are stored with the ROM icon data in RGB555 format.
    // We convert these color values and store them in the CLUT as RGBA8888 values.
    //
    // The first entry always represents the alpha, so just set it to 0.
    //const uint16_t *clut4 = (uint16_t *)banner.palette;
    CACHE_ALIGN uint32_t clut32[16];
    ColorspaceConvertBuffer555To8888Opaque<false, true, BESwapNone>(clut4, clut32, 16);
    clut32[0] = 0x00000000;
    
    // Load the image from the icon pixel data.
    //
    // ROM icons are stored in 4-bit indexed color and have dimensions of 32x32 pixels.
    // Also, ROM icons are split into 16 separate 8x8 pixel tiles arranged in a 4x4
    // array. Here, we sequentially read from the ROM data, and adjust our write
    // location appropriately within the bitmap memory block.
    for (size_t y = 0; y < 4; y++)
    {
        for (size_t x = 0; x < 4; x++)
        {
            for (size_t p = 0; p < 8; p++, iconPixPtr++)
            {
                // Load an entire row of palette color indices as a single 32-bit chunk.
                const uint32_t palIdx = LE_TO_LOCAL_32(*iconPixPtr);
                
                // Set the write location. The formula below calculates the proper write
                // location depending on the position of the read pointer. We use a more
                // optimized version of this formula in practice.
                //
                // bitmapOutPtr = bitmapData + ( ((y * 8) + palIdx) * 32 ) + (x * 8);
                uint32_t *bitmapOutPtr = bitmapData + ( ((y << 3) + p) << 5 ) + (x << 3);
                *bitmapOutPtr = clut32[(palIdx & 0x0000000F) >> 0];
                
                bitmapOutPtr++;
                *bitmapOutPtr = clut32[(palIdx & 0x000000F0) >> 4];
                
                bitmapOutPtr++;
                *bitmapOutPtr = clut32[(palIdx & 0x00000F00) >> 8];
                
                bitmapOutPtr++;
                *bitmapOutPtr = clut32[(palIdx & 0x0000F000) >> 12];
                
                bitmapOutPtr++;
                *bitmapOutPtr = clut32[(palIdx & 0x000F0000) >> 16];
                
                bitmapOutPtr++;
                *bitmapOutPtr = clut32[(palIdx & 0x00F00000) >> 20];
                
                bitmapOutPtr++;
                *bitmapOutPtr = clut32[(palIdx & 0x0F000000) >> 24];
                
                bitmapOutPtr++;
                *bitmapOutPtr = clut32[(palIdx & 0xF0000000) >> 28];
            }
        }
    }
}

@end
