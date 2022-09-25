//
//  SyncScrollView.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/23/22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SyncScrollView : NSScrollView {
    NSScrollView* synchronizedScrollView; // not retained
}
 
- (void)setSynchronizedScrollView:(NSScrollView*)scrollview;
- (void)stopSynchronizing;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification;
 
@end

NS_ASSUME_NONNULL_END
