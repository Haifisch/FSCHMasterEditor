//
//  NDSCartridgeData.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/10/22.
//

#import <Foundation/Foundation.h>
#import "NDSCartridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface NDSBannerAnimation : NSObject

@property BOOL FlipVertial;
@property BOOL FlipHorizontal;

@property (strong) NSNumber *duration;
@property (strong) NSNumber *bitmapIndex;


@end

@interface NDSCartridgeData : NSObject {
    sNDSHeaderExt header;
    sNDSBannerExt banner;
}


- (instancetype)initWithHeaderData:(NSData *)databuffer fileHandle:(nonnull NSFileHandle *)handle;
- (sNDSHeaderExt *)rawHeader;
- (sNDSBannerExt *)banner;

@property (strong) NSString *GameTitle;
@property (strong) NSString *GameCode;
@property (strong) NSString *Makercode;
@property (strong) NSString *ROMSHA256;

@property (strong) NSData *romHeaderData;
@property (strong) NSImage *bannerIcon;
@property (strong) NSArray<NSImage *>* animatedBannerIcons;
@property (strong) NSArray<NDSBannerAnimation *>* bannerAnimation;

@property int bannerIconAnimationFramesMax;



@property UInt8 UnitCode;
@property UInt8 DeviceType;
@property UInt8 DeviceSize;
//@property UInt8 reserved1[9];
@property UInt8 RomVersion;
@property UInt8 Flags;

@property UInt32 HeaderSize;
@property UInt32 RomSize;


@property UInt32 Arm9romOffset;
@property UInt32 Arm9executeAddress;
@property UInt32 Arm9destination;
@property UInt32 Arm9binarySize;

@property UInt32 Arm7romOffset;
@property UInt32 Arm7executeAddress;
@property UInt32 Arm7destination;
@property UInt32 Arm7binarySize;

@property UInt16 HeaderCRC16;
@property UInt16 LogoCRC16;
@property UInt16 SecureCRC16;

@property UInt32 BannerOffset;

@property UInt16 RecalculatedHeaderCRC16;
@property BOOL RecalcChecksumMatchesHeader;

@property UInt16 RecalculatedSecureAreaCRC16;
@property BOOL RecalcSecureAreaChecksumMatchesHeader;

@property BOOL TWLAreasFound;

@property BOOL hasAnimatedBanner;

@end

NS_ASSUME_NONNULL_END
