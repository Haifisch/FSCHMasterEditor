//
//  ROMHeaderViewer.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/9/22.
//

#import <Cocoa/Cocoa.h>
#import "RHMainWindow.h"

NS_ASSUME_NONNULL_BEGIN

@interface ROMHeaderViewer : NSWindowController <RHMainWindowDelegate>
@property (strong) IBOutlet NSProgressIndicator *progressView;
@end

NS_ASSUME_NONNULL_END
