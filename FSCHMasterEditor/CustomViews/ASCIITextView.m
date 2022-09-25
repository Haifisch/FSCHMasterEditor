//
//  ASCIITextView.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/20/22.
//

#import "ASCIITextView.h"

@interface ASCIITextView () {
    NSColor *fontColor;
    NSColor *bgColor;
}

@end

@implementation ASCIITextView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ASCIIValueLabel = [[self view] viewWithTag:6];
    if (self.rawData != nil && self.ASCIIValueLabel != nil) {
        NSString *asciiString = [NSString stringWithCString:[self.rawData bytes] encoding:NSASCIIStringEncoding];
        NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSCharacterSet *controlSet = [NSCharacterSet controlCharacterSet];
        if ([asciiString rangeOfCharacterFromSet:whitespaceSet].location != NSNotFound || [asciiString rangeOfCharacterFromSet:controlSet].location != NSNotFound || [asciiString length] == 0) {
            asciiString = @".";
        }
        [self.ASCIIValueLabel setStringValue:asciiString];
    }
    if (fontColor)
    {
        [[self ASCIIValueLabel] setTextColor:fontColor];
    }
    self.view.wantsLayer = true;
    // Do view setup here.
}

- (NSNibName)nibName {
    return @"ASCIITextView";
}

- (void)setFontColor:(NSColor *)color {
    fontColor = color;
    CGFloat r,g,b;
    r = 1.0f - fontColor.redComponent;
    g = 1.0f - fontColor.greenComponent;
    b = 1.0f - fontColor.blueComponent;
    bgColor = [NSColor colorWithRed:r green:g blue:b alpha:0.6f];
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
