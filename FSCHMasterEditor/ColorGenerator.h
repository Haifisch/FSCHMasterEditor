//
//  ColorGenerator.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/16/22.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorGenerator : NSObject

- (NSColor *)colorFromGradient:(CGFloat)pos;

@end

NS_ASSUME_NONNULL_END
