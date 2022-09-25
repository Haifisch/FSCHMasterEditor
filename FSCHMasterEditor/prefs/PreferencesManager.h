//
//  PreferencesManager.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/17/22.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesManager : NSObject

@property (nonatomic, retain) NSArray<NSColor *> *gradientColors;

+ (id)sharedManager;

- (void)setGradientColorArray:(NSArray<NSColor *> *)gradientColors;

- (NSInteger)bytesToRead;
- (void)saveNumberOfHeaderBytesToRead:(NSInteger)num;

@end

NS_ASSUME_NONNULL_END
