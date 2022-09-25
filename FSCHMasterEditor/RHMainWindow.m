//
//  RHMainWindow.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/9/22.
//

#import "RHMainWindow.h"
#import "NDSCartridge.h"
#import "NDSCartridgeData.h"
#import "ColorGenerator.h"
#import "HexTextView.h"
#import "AddressTextView.h"
#import "ASCIITextView.h"
#import "PopoverInformationView.h"
#include <objc/runtime.h>

@implementation NSColor (NSColor_Random)

+ (NSColor *)randomColor  {
    int r,g,b;
    r = arc4random_uniform(255);
    g = arc4random_uniform(255);
    b = arc4random_uniform(255);
    return [NSColor colorWithRed:r green:g blue:b alpha:1];
}

@end

@implementation NSData (NSData_Conversion)

#pragma mark - String Conversion
- (NSString *)hexadecimalString {
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */

    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];

    if (!dataBuffer)
        return [NSString string];

    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx ", (unsigned long)dataBuffer[i]]];

    return [NSString stringWithString:hexString];
}

@end

@interface RHMainWindow () {
    NSURL *romFilePath;
    NSFileHandle *romFileHandle;
    NSMutableDictionary *romHeaderInfo;
    NSMutableArray *addressesArray;
    NDSCartridgeData *cartridgeData;
    ColorGenerator *colorGen;
    BOOL is3DSTypeROM;
    BOOL isCollectionViewDataReady;
    NSSet<NSIndexPath *> *previousSelectionSet;
    int bannerFrame;
    BOOL popoverIsShown;
}
@property (strong) IBOutlet NSTableView *tableView;

@end

@implementation RHMainWindow

- (instancetype)initWithPathToROM:(NSURL *)romPath delegate:(id <RHMainWindowDelegate>)ndelegate {
    self = [super init];
    addressesArray = [[NSMutableArray alloc] init];
    colorGen = [[ColorGenerator alloc] init];
    romHeaderInfo = [[NSMutableDictionary alloc] init];
    isCollectionViewDataReady = false;
    self.delegate = ndelegate;
    [self setROMPath:romPath];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self tableView] setDelegate:self];
    [[self tableView] setDataSource:self];
    [[self window] setTitle:[romFilePath lastPathComponent]];
    [[self addressScrollview] setHasVerticalScroller:FALSE];
    [[self hexScrollView] setHasVerticalScroller:FALSE];
    [[self addressScrollview] setSynchronizedScrollView:[self hexScrollView]];
    [[self hexScrollView] setSynchronizedScrollView:[self asciiScrollView]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSString *)windowNibName
{
    return @"RHMainWindow";
}

- (void)doReload {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self processRomFile:^(bool param1) {
            if (param1 && self.delegate != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate didFinishLoadingROM];
                    //[[self hexCollectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    //[[self asciiCollectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    //[[self addressCollectionView] reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    [[self hexCollectionView] reloadData];
                    [[self asciiCollectionView] reloadData];
                    [[self addressCollectionView] reloadData];

                    [[self tableView] reloadData];
                    NSImage *bannerIcon = [self->cartridgeData bannerIcon];
                    if (self->cartridgeData.hasAnimatedBanner) {
                        self.bannerIconImageView.image = bannerIcon;
                        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerInterval:) userInfo:nil repeats:NO];
                    } else {
                        self.bannerIconImageView.image = bannerIcon;
                    }
                });
            }
        }];
    });
   
}

- (NSDictionary *)HeaderSpecificationDictionary {
    NSString *specPath = [[NSBundle mainBundle] pathForResource:@"ndsheaderspec" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:specPath];
}

- (IBAction)boundsDidChange:(NSNotification *)notification {

}

- (void)processTableView:(sNDSHeaderExt *)ndsHeader andCartridgeData:(NDSCartridgeData *)cartridgeData {
    [romFileHandle seekToFileOffset:0];
    romHeaderInfo = [[NSMutableDictionary alloc] initWithDictionary:[self HeaderSpecificationDictionary]];
    for (int i = 0; i < [romHeaderInfo allKeys].count; i++) {
        NSString *curKey = [romHeaderInfo allKeys][i];
        int curOffset = [[romHeaderInfo objectForKey:curKey][@"offset"] intValue];
        int readSize = [[romHeaderInfo objectForKey:curKey][@"size"] intValue];
        [romFileHandle seekToFileOffset:curOffset];
        NSData *fileBytes = [romFileHandle readDataOfLength:readSize];
        [[romHeaderInfo objectForKey:curKey] setObject:fileBytes forKey:@"data"];
        NSColor *dataColor = [colorGen colorFromGradient:(CGFloat)((CGFloat)i/[romHeaderInfo allKeys].count)];
        [[romHeaderInfo objectForKey:curKey] setObject:dataColor forKey:@"color"];
    }
}

- (IBAction)timerInterval:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            if (self->bannerFrame >= self->cartridgeData.bannerIconAnimationFramesMax) {
                self->bannerFrame = 0;
            }
            NSNumber *duration = [self->cartridgeData bannerAnimation][self->bannerFrame].duration;
            NSNumber *bannerBitmapIndex = [self->cartridgeData bannerAnimation][self->bannerFrame].bitmapIndex;
            //NSLog(@"sleeping for icon animation");
            [NSThread sleepForTimeInterval:[duration doubleValue]/20];
            // update UI on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                self.bannerIconImageView.image = [[self->cartridgeData animatedBannerIcons] objectAtIndex:[bannerBitmapIndex unsignedIntValue]];
            });
            self->bannerFrame++;
        }
    });
    //[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerInterval:) userInfo:nil repeats:NO];
}

- (void)processForHexView:(completionBlock)completion {
    NSData *databuffer;
    __block int length = 1024;
    __block int offset = 0;
    [romFileHandle seekToFileOffset:0];
    databuffer = [romFileHandle readDataOfLength:length];
    cartridgeData = [[NDSCartridgeData alloc] initWithHeaderData:databuffer fileHandle:romFileHandle];
    length = (int)[[self->cartridgeData romHeaderData] length];
    [self processTableView:[self->cartridgeData rawHeader] andCartridgeData:self->cartridgeData];
    while (length > offset ) {
        //[addressFormatStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%04x:\n", offset]]];
        [self->addressesArray addObject:[NSString stringWithFormat:@"%04x:", offset]];
        offset += 0x1A;
        if (offset > length) {
            break;
        }
    }
    self->isCollectionViewDataReady = true;
    [self->romFileHandle seekToFileOffset:0];
    completion(true);
}

- (void)processRomFile:(completionBlock)returningBlock {
    if (romFilePath == nil) returningBlock(false);
    if ([[romFilePath path] length] <= 0) returningBlock(false);
    
    romFileHandle = [NSFileHandle fileHandleForReadingAtPath:[romFilePath path]];
    if (romFileHandle == nil) {
        NSLog(@"Failed to open file");
        returningBlock(false);
    }
    
    NSData *fileData = [romFileHandle readDataToEndOfFile];
    NSData *pattern = [@"NCCH" dataUsingEncoding:NSASCIIStringEncoding];
    NSRange range = [fileData rangeOfData:pattern options:0 range:NSMakeRange(0, fileData.length)];
    is3DSTypeROM = (range.location != NSNotFound);
    [self processForHexView:^(bool param1) {
        [self->romFileHandle closeFile];
        returningBlock(param1);
    }];
}

- (void)setROMPath:(NSURL *)path
{
    romFilePath = path;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (romHeaderInfo == nil) return 0;
    NSInteger ret = [[romHeaderInfo allKeys] count];
    return ret;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = tableColumn.identifier;
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    NSString *keyValue = [[romHeaderInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)][row];
    if ([[tableColumn identifier] isEqualToString:@"descriptionCol"]) {
        [cell textField].stringValue = keyValue;
    } else {
        NSString *dataFormatType = [romHeaderInfo objectForKey:keyValue][@"type"];
        NSData *cellData = [romHeaderInfo objectForKey:keyValue][@"data"];
        
        if ([dataFormatType isEqualToString:@"string"]) {
            [cell textField].stringValue = [NSString stringWithCString:(const char*)[cellData bytes] encoding:NSASCIIStringEncoding];
        } else if ([dataFormatType isEqualToString:@"hex"]) {
            if ([keyValue isEqualToString:@"Header CRC-16"]) {
                [cell textField].stringValue = [NSString stringWithFormat:@"0x%02x (recalcsum; 0x%02x)", *(unsigned int*)[cellData bytes], cartridgeData.RecalculatedHeaderCRC16];
            } else {
                [cell textField].stringValue = [NSString stringWithFormat:@"0x%02x", *(unsigned int*)[cellData bytes]];
            }
        }
        [[cell textField] setTextColor:((NSColor *)[romHeaderInfo objectForKey:keyValue][@"color"])];
        
        if ([keyValue isEqualToString:@"Header CRC-16"]) {
            [cell imageView].image = cartridgeData.RecalcChecksumMatchesHeader ? [NSImage imageWithSystemSymbolName:@"checkmark" accessibilityDescription:@"CRC16 Matched"] : [NSImage imageWithSystemSymbolName:@"x.circle.fill" accessibilityDescription:@"CRC16 Check Failed"];
        } else {
            // info
            [cell imageView].image = [NSImage new];
        }
        
    }
    return cell;
}

- (NSCollectionViewItem *)collectionView:(nonnull NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (!isCollectionViewDataReady) {
        return nil;
    }
    if ([[collectionView identifier] isEqualToString:@"addressView"]) {
        AddressTextView *newItem = [[AddressTextView alloc] initWithNibName:@"AddressTextView" bundle:[NSBundle mainBundle]];
        newItem.addressString = addressesArray[indexPath.item];
        return newItem;
    }
    
    NSColor *selectedColor;
    for (int i = 0; i < [romHeaderInfo allKeys].count; i++) {
        int offset = [[romHeaderInfo objectForKey:[romHeaderInfo allKeys][i]][@"offset"] intValue];
        int size = [[romHeaderInfo objectForKey:[romHeaderInfo allKeys][i]][@"size"] intValue];
        int maxOffset = offset + size;
        if (indexPath.item >= offset && indexPath.item < maxOffset) {
            selectedColor = (NSColor *)[romHeaderInfo objectForKey:[romHeaderInfo allKeys][i]][@"color"];
            break;
        }
    }
    
    if ([[collectionView identifier] isEqualToString:@"ASCIIView"]) {
        ASCIITextView *newItem = [[ASCIITextView alloc] initWithNibName:@"ASCIITextView" bundle:[NSBundle mainBundle]];
        if (cartridgeData.romHeaderData != nil) {
            //unsigned char *romHeader = (unsigned char *)[cartridgeData.romHeaderData bytes];
            uint16_t rawBytes;
            [cartridgeData.romHeaderData getBytes:&rawBytes range:NSMakeRange(indexPath.item, 1)];
            [newItem setRawData:[NSData dataWithBytes:&rawBytes length:1]];
            if (selectedColor) {
                [newItem setFontColor:selectedColor];
                newItem.isImportantByte = true;
            }
        }
        return newItem;
    } else {
        HexTextView *newItem = [[HexTextView alloc] initWithNibName:@"HexTextView" bundle:[NSBundle mainBundle]];
        if (cartridgeData.romHeaderData != nil) {
            //unsigned char *romHeader = (unsigned char *)[cartridgeData.romHeaderData bytes];
            uint16_t rawBytes;
            [cartridgeData.romHeaderData getBytes:&rawBytes range:NSMakeRange(indexPath.item, 1)];
            [newItem setRawData:[NSData dataWithBytes:&rawBytes length:1]];
            if (selectedColor) {
                [newItem setFontColor:selectedColor];
                newItem.isImportantByte = true;
            }
        }
        return newItem;
    }
    return nil;
}

- (NSInteger)collectionView:(nonnull NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([[collectionView identifier] isEqualToString:@"addressView"]) {
        return [addressesArray count];
    } else {
        if (cartridgeData != nil) {
            if (cartridgeData.romHeaderData != nil) {
                return [cartridgeData.romHeaderData length];
            }
        }
    }
    return 0;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    if (previousSelectionSet) {
        [self.asciiCollectionView deselectItemsAtIndexPaths:[self.asciiCollectionView indexPathsForVisibleItems]];
        [self.hexCollectionView deselectItemsAtIndexPaths:[self.hexCollectionView indexPathsForVisibleItems]];
    }
    previousSelectionSet = indexPaths;
    NSMutableArray *additonalBytestoSelect = [[NSMutableArray alloc] init];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull path, BOOL * _Nonnull stop) {
        id item = [collectionView itemAtIndexPath:path];
        if ([item isKindOfClass:[ASCIITextView class]] || [item isKindOfClass:[HexTextView class]]) {
            NSDictionary *selectedData;
            NSString *selectedTitle;
            for (int i = 0; i < [romHeaderInfo allKeys].count; i++) {
                int offset = [[romHeaderInfo objectForKey:[romHeaderInfo allKeys][i]][@"offset"] intValue];
                int size = [[romHeaderInfo objectForKey:[romHeaderInfo allKeys][i]][@"size"] intValue];
                int maxOffset = offset + size;
                if (path.item >= offset && path.item < maxOffset) {
                    selectedData = [romHeaderInfo objectForKey:[romHeaderInfo allKeys][i]];
                    selectedTitle = [romHeaderInfo allKeys][i];
                    NSInteger offset = [selectedData[@"offset"] integerValue];
                    for (int sz = 0; sz < [selectedData[@"size"] integerValue]; sz++) {
                        NSIndexPath *newPath = [NSIndexPath indexPathForItem:(offset+sz) inSection:0];
                        [additonalBytestoSelect addObject:newPath];
                    }
                    
                    break;
                }
            }
            if (selectedData) {
                [(PopoverInformationView *)[[self.popoverView contentViewController] view] setPopoverData:selectedData title:selectedTitle];
                [self.popoverView showRelativeToRect:[collectionView frameForItemAtIndex:path.item] ofView:collectionView preferredEdge:NSRectEdgeMinY];
                popoverIsShown = true;
            } else {
                if (popoverIsShown) {
                    [self.popoverView performClose:self];
                }
            }
        }
    }];
    NSSet *uniqueMakes = [NSSet setWithArray:additonalBytestoSelect];
    [indexPaths setByAddingObjectsFromSet:uniqueMakes];
    [self.hexCollectionView setSelectionIndexPaths:uniqueMakes];
    [self.asciiCollectionView setSelectionIndexPaths:uniqueMakes];
}

- (void)keyDown:(NSEvent *)event {
    
}
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
}

- (IBAction)copy:(id)sender {
    [[NSPasteboard generalPasteboard] clearContents];
    NSInteger selectedTableRow = [[self tableView] selectedRow];
    NSString *selectedTableKey = [[romHeaderInfo allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)][selectedTableRow];
    NSData *selectedData = romHeaderInfo[selectedTableKey][@"data"];
    NSString *dataFormatType = romHeaderInfo[selectedTableKey][@"type"];
    NSString *selectedValue = @"";
    if ([dataFormatType isEqualToString:@"string"]) {
        selectedValue = [NSString stringWithCString:(const char*)[selectedData bytes] encoding:NSASCIIStringEncoding];
    } else if ([dataFormatType isEqualToString:@"hex"]) {
        selectedValue = [NSString stringWithFormat:@"0x%02x", *(unsigned int*)[selectedData bytes]];
    }

    [[NSPasteboard generalPasteboard] setString:selectedValue forType:NSPasteboardTypeString];
}

@end
