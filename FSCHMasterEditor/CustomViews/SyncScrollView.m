//
//  SyncScrollView.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/23/22.
//

#import "SyncScrollView.h"

@implementation SyncScrollView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.hasHorizontalScroller = FALSE;
        self.hasVerticalScroller = FALSE;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setSynchronizedScrollView:(NSScrollView*)scrollview
{
    NSView *synchronizedContentView;
 
    // stop an existing scroll view synchronizing
    [self stopSynchronizing];
 
    // don't retain the watched view, because we assume that it will
    // be retained by the view hierarchy for as long as we're around.
    synchronizedScrollView = scrollview;
 
    // get the content view of the
    synchronizedContentView=[synchronizedScrollView contentView];
 
    // Make sure the watched view is sending bounds changed
    // notifications (which is probably does anyway, but calling
    // this again won't hurt).
    [synchronizedContentView setPostsBoundsChangedNotifications:YES];
 
    // a register for those notifications on the synchronized content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                         selector:@selector(synchronizedViewContentBoundsDidChange:)
                         name:NSViewBoundsDidChangeNotification
                           object:synchronizedContentView];
}

- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification
{
    // get the changed content view from the notification
    NSClipView *changedContentView=[notification object];
 
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;;
 
    // get our current origin
    NSPoint curOffset = [[self contentView] bounds].origin;
    NSPoint newOffset = curOffset;
 
    // scrolling is synchronized in the vertical plane
    // so only modify the y component of the offset
    newOffset.y = changedBoundsOrigin.y;
 
    // if our synced position is different from our current
    // position, reposition our content view
    if (!NSEqualPoints(curOffset, changedBoundsOrigin))
    {
    // note that a scroll view watching this one will
    // get notified here
    [[self contentView] scrollToPoint:newOffset];
    // we have to tell the NSScrollView to update its
    // scrollers
    [self reflectScrolledClipView:[self contentView]];
    }
}

- (void)stopSynchronizing
{
    if (synchronizedScrollView != nil) {
    NSView* synchronizedContentView = [synchronizedScrollView contentView];
 
    // remove any existing notification registration
    [[NSNotificationCenter defaultCenter] removeObserver:self
                            name:NSViewBoundsDidChangeNotification
                              object:synchronizedContentView];
 
    // set synchronizedScrollView to nil
    synchronizedScrollView=nil;
    }
}

- (void)scrollWheel:(NSEvent *)event {
    if ([[self identifier] isEqualToString:@"ASCIIScrollview"]) {
        [super scrollWheel:event];
    }
}
@end
