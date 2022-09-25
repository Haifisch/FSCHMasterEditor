//
//  RHMainWindow.h
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/9/22.
//

#import <Cocoa/Cocoa.h>
#import "FSCHMasterEditor-Bridging-Header.h"
#import "SyncScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RHMainWindowDelegate <NSObject>
@optional
- (void)didFinishLoadingROM;
@end


@interface RHMainWindow : NSWindowController <NSTableViewDelegate, NSTableViewDataSource, NSCollectionViewDelegate, NSCollectionViewDataSource>
typedef void (^completionBlock)(bool param1);

@property (nonatomic, weak) id <RHMainWindowDelegate> delegate;

@property (strong) IBOutlet NSTextField *headerChecksumValidationLabel;
@property (strong) IBOutlet NSImageView *headerChecksumValidationImage;

@property (strong) IBOutlet NSCollectionView *addressCollectionView;
@property (strong) IBOutlet NSCollectionView *hexCollectionView;
@property (strong) IBOutlet NSCollectionView *asciiCollectionView;

@property (strong) IBOutlet SyncScrollView *hexScrollView;
@property (strong) IBOutlet NSClipView *hexClipView;
@property (strong) IBOutlet SyncScrollView *asciiScrollView;
@property (strong) IBOutlet NSClipView *asciiClipView;
@property (strong) IBOutlet SyncScrollView *addressScrollview;
@property (strong) IBOutlet NSClipView *addressClipview;

@property (strong) IBOutlet NSPopover *popoverView;
@property (strong) IBOutlet NSImageView *bannerIconImageView;

@property (strong) IBOutlet NSPanel *checksumPanel;


- (instancetype)initWithPathToROM:(NSURL *)romPath delegate:(id <RHMainWindowDelegate>)delegate;
- (void)setROMPath:(NSURL *)path;
- (void)doReload;

@end

NS_ASSUME_NONNULL_END
