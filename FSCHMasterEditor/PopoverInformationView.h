//
//  PopoverInformationView.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/23/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopoverInformationView : NSView

@property (strong) NSPopover *hostPopover;
@property (strong) IBOutlet NSTextField *titleLabel;
@property (strong) IBOutlet NSTextField *descriptionLabel;

- (void)setPopoverData:(id)dat title:(NSString *)titleStr;
- (void)setShowingSHASUM:(NSString *)shaValue;

@end

NS_ASSUME_NONNULL_END
