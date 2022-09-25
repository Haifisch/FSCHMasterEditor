//
//  PopoverInformationView.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/23/22.
//

#import "PopoverInformationView.h"
#import "NSString+WordCount.h"

@implementation PopoverInformationView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)acceptsFirstResponder {
    return TRUE;
}
- (BOOL)canBecomeKeyView {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    // todo hide on esc, probably not this way.
}

- (void)setPopoverData:(id)dat title:(NSString *)titleStr {
    NSInteger words = [titleStr wordCount];
    if (words >= 4) {
        [self.titleLabel setFont:[[NSFontManager sharedFontManager] fontWithFamily:@"IBM Plex Mono" traits:NSFontWeightBold weight:0 size:10]];
    } else if (words > 2) {
        [self.titleLabel setFont:[NSFont fontWithName:@"IBM Plex Mono" size:12]];
    } else {
        [self.titleLabel setFont:[NSFont fontWithName:@"IBM Plex Mono" size:14]];
    }
    self.titleLabel.stringValue = titleStr;
    
    NSData *selectedData = dat[@"data"];
    NSString *dataFormatType = dat[@"type"];
    NSString *selectedValue = @"";
    if ([dataFormatType isEqualToString:@"string"]) {
        selectedValue = [NSString stringWithCString:(const char*)[selectedData bytes] encoding:NSASCIIStringEncoding];
    } else if ([dataFormatType isEqualToString:@"hex"]) {
        selectedValue = [NSString stringWithFormat:@"0x%02x", *(unsigned int*)[selectedData bytes]];
    }
    self.descriptionLabel.stringValue = [NSString stringWithFormat:@"OFFSET @ 0x%02X\nSIZE %i\n%@", [dat[@"offset"] intValue], [dat[@"size"] intValue], selectedValue];
}

- (void)setShowingSHASUM:(NSString *)shaValue {
    
}

@end
