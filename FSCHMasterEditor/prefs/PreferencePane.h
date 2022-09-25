//
//  PreferencePane.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/17/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreferencePane : NSWindowController
@property (strong) IBOutlet NSColorWell *colorPickerA;
@property (strong) IBOutlet NSColorWell *colorPickerB;
@property (strong) IBOutlet NSColorWell *colorPickerC;
@property (strong) IBOutlet NSColorWell *colorPickerD;

@property (strong) IBOutlet NSTextField *bytesToReadField;

- (IBAction)selectColor:(id)sender;

@end

NS_ASSUME_NONNULL_END
