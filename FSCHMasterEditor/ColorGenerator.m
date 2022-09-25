//
//  ColorGenerator.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/16/22.
//

#import "ColorGenerator.h"
#import "PreferencesManager.h"

@implementation ColorGenerator {
    PreferencesManager *preferenceManager;
    NSGradient *sharedGradient;
}

- (instancetype)init {
    if (self = [super init]) {
        preferenceManager = [PreferencesManager sharedManager];
        CGFloat pos[5] = {0, 0.25, 0.5, 0.75, 1};
        sharedGradient = [[NSGradient alloc] initWithColors:preferenceManager.gradientColors atLocations:pos colorSpace:NSColorSpace.deviceRGBColorSpace];
    }
    return self;
}

- (NSColor *)colorFromGradient:(CGFloat)pos {
    NSColor *ret = [sharedGradient interpolatedColorAtLocation:pos];
    return ret;
}

@end
