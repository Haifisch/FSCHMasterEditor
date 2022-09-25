//
//  AddressTextView.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/19/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddressTextView : NSCollectionViewItem


@property NSString *addressString;
@property (strong) IBOutlet NSTextField *addressLabel;

@end

NS_ASSUME_NONNULL_END
