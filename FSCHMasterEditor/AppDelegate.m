//
//  AppDelegate.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/9/22.
//

#import "AppDelegate.h"
#import "ROMHeaderViewer.h"
#import "PreferencePane.h"
#import "PreferencesManager.h"

@interface AppDelegate () {
    PreferencePane *preferences;
    PreferencesManager *preferencesManager;
}
@property (readwrite,strong) NSWindowController *windowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.windowController = [[ROMHeaderViewer alloc] init];
    [self.windowController showWindow:self];
    
    preferencesManager = [PreferencesManager sharedManager];

    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (IBAction)openPrefsPane:(id)sender {
    preferences = [[PreferencePane alloc] init];
    [preferences showWindow:nil];
}

@end
