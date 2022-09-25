//
//  PreferencePane.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/17/22.
//

#import "PreferencePane.h"
#import "PreferencesManager.h"

@interface PreferencePane () {
    NSColor *selectedColorA;
    NSColor *selectedColorB;
    NSColor *selectedColorC;
    NSColor *selectedColorD;
    NSInteger bytesToRead;
    PreferencesManager *prefsManager;
}

@end

@implementation PreferencePane

- (void)windowDidLoad {
    [super windowDidLoad];
    prefsManager = [PreferencesManager sharedManager];
    [self loadPrefs];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSString *)windowNibName
{
    return @"PreferencePane";
}

- (IBAction)selectColor:(id)sender {
    if (sender == self.colorPickerA) {
        selectedColorA = self.colorPickerA.color;
    } else if (sender == self.colorPickerB) {
        selectedColorB = self.colorPickerB.color;
    } else if (sender == self.colorPickerC) {
        selectedColorC = self.colorPickerC.color;
    } else if (sender == self.colorPickerD) {
        selectedColorD = self.colorPickerD.color;
    }
}

- (IBAction)savePrefs:(id)sender {
    selectedColorA = self.colorPickerA.color;
    selectedColorB = self.colorPickerB.color;
    selectedColorC = self.colorPickerC.color;
    selectedColorD = self.colorPickerD.color;
    [prefsManager setGradientColorArray:[NSArray arrayWithObjects:selectedColorA, selectedColorB, selectedColorC, selectedColorD, nil]];
    [prefsManager saveNumberOfHeaderBytesToRead:[[self bytesToReadField] integerValue]];
}

- (void)loadPrefs {
    bytesToRead = [prefsManager bytesToRead];
    if (bytesToRead == 0) {
        [prefsManager saveNumberOfHeaderBytesToRead:1024];
        [[self bytesToReadField] setStringValue:@"1024"];
    } else {
        [[self bytesToReadField] setStringValue:[NSString stringWithFormat:@"%li", (long)bytesToRead]];
    }
    
    NSArray *colorArry = [prefsManager gradientColors];
    selectedColorA = [colorArry objectAtIndex:0];
    selectedColorB = [colorArry objectAtIndex:1];
    selectedColorC = [colorArry objectAtIndex:2];
    selectedColorD = [colorArry objectAtIndex:3];
    self.colorPickerA.color = selectedColorA;
    self.colorPickerB.color = selectedColorB;
    self.colorPickerC.color = selectedColorC;
    self.colorPickerD.color = selectedColorD;
}

@end
