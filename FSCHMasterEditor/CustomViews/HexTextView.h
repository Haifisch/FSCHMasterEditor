//
//  HexTextView.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/18/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface HexTextView : NSCollectionViewItem

@property NSData *rawData;

@property (strong) IBOutlet NSTextField *hexValueLabel;

- (void)setFontColor:(NSColor *)color;

@property BOOL isImportantByte;

@end

NS_ASSUME_NONNULL_END
