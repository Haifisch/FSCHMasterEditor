//
//  ROMHeaderViewer.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/9/22.
//

#import "ROMHeaderViewer.h"

@interface ROMHeaderViewer () {
    RHMainWindow *romheaderView;
}

@property (strong) IBOutlet NSTextField *filenameLabel;

@end

@implementation ROMHeaderViewer

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSString *)windowNibName
{
    return @"ROMHeaderViewer";
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    return NSDragOperationGeneric;
}
- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    NSPasteboard* pbrd = [sender draggingPasteboard];
    // Do something here.
    NSURL *fileURL = [NSURL URLWithString:[pbrd stringForType:NSPasteboardTypeFileURL]];
    [self.filenameLabel setStringValue:[pbrd stringForType:NSPasteboardTypeFileURL]];
    romheaderView = [[RHMainWindow alloc] initWithPathToROM:fileURL delegate:self];
    [self.progressView startAnimation:nil];
    [self.progressView setHidden:FALSE];
    [romheaderView doReload];
    [[self window] orderOut:self];
    return YES;
}

- (IBAction)openFileDialog:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:NO];

    if ([openDlg runModal] == NSModalResponseOK )
    {
        NSURL* fileURL = [openDlg URL];
        if (fileURL != nil)
        {
            [self.filenameLabel setStringValue:[fileURL lastPathComponent]];
            romheaderView = [[RHMainWindow alloc] initWithPathToROM:fileURL delegate:self];
            [self.progressView startAnimation:nil];
            [self.progressView setHidden:FALSE];
            [romheaderView doReload];
            [[self window] orderOut:self];
        }
    }
}

- (void)didFinishLoadingROM {
    if (romheaderView == nil) return;
    [romheaderView showWindow:nil];
    [self.progressView stopAnimation:nil];
    [self.progressView setHidden:TRUE];
}

@end
