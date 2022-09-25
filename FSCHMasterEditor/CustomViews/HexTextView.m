//
//  HexTextView.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/18/22.
//

#import "HexTextView.h"

@interface HexTextView () {
    NSColor *fontColor;
    NSColor *bgColor;
}

@end

@implementation HexTextView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hexValueLabel = [[self view] viewWithTag:8];
    if (self.rawData != nil && self.hexValueLabel != nil) {
        [self.hexValueLabel setStringValue:[NSString stringWithFormat:@"%02x", *(unsigned int*)[self.rawData bytes]]];
    }
    if (fontColor)
    {
        [[self hexValueLabel] setTextColor:fontColor];
    }
    self.view.wantsLayer = true;
    // Do view setup here.
}

- (void)setFontColor:(NSColor *)color {
    fontColor = color;
    CGFloat r,g,b;
    r = 1.0f - fontColor.redComponent;
    g = 1.0f - fontColor.greenComponent;
    b = 1.0f - fontColor.blueComponent;
    bgColor = [NSColor colorWithRed:r green:g blue:b alpha:0.6f];
}

- (NSNibName)nibName {
    return @"HexTextView";
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected && self.isImportantByte) {
        [[[self view] layer] setBackgroundColor:bgColor.CGColor];
    } else {
        [[[self view] layer] setBackgroundColor:[NSColor clearColor].CGColor];
    }
}

- (BOOL)wantsUpdateLayer {
   return YES;
}

@end
