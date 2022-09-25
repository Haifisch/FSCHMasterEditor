//
//  ASCIITextView.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/20/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASCIITextView : NSCollectionViewItem

@property NSData *rawData;

@property (strong) IBOutlet NSTextField *ASCIIValueLabel;

- (void)setFontColor:(NSColor *)color;

@property BOOL isImportantByte;

@end

NS_ASSUME_NONNULL_END
