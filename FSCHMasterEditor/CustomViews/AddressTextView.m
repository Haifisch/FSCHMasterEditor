//
//  AddressTextView.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/19/22.
//

#import "AddressTextView.h"

@interface AddressTextView ()

@end

@implementation AddressTextView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addressLabel = [[self view] viewWithTag:2];
    if (self.addressLabel != nil) {
        [self.addressLabel setStringValue:self.addressString];
    }
    // Do view setup here.
}

@end
