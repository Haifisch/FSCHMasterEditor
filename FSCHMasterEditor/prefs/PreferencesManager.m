//
//  PreferencesManager.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/17/22.
//

#import "PreferencesManager.h"

@implementation PreferencesManager

+ (id)sharedManager {
    static PreferencesManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init {
    if (self = [super init]) {
        if ([self hasPreferencesSaved] == FALSE) {
            self.gradientColors = [NSArray arrayWithObjects:[NSColor colorWithRed:25.0f/255.0f green:29.0f/255.0f blue:200.0f/255.0f alpha:1], [NSColor colorWithRed:255/255.0f green:98.0f/255.0f blue:95.0f/255.0f alpha:1], [NSColor colorWithRed:25.0f/255.0f green:29.0f/255.0f blue:200.0f/255.0f alpha:1], [NSColor colorWithRed:255/255.0f green:98.0f/255.0f blue:95.0f/255.0f alpha:1], nil];
            NSError *error;
            NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:self.gradientColors requiringSecureCoding:NO error:&error];
            [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"gradientColors"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"prefsInit"];
        } else {
            NSError *error;
            NSData *storedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"gradientColors"];
            NSArray *storedArray = [NSKeyedUnarchiver unarchivedArrayOfObjectsOfClass:[NSColor class] fromData:storedData error:&error];
            self.gradientColors = storedArray;
        }
    }
    return self;
}

- (BOOL)hasPreferencesSaved {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"prefsInit"];
}

- (void)setGradientColorArray:(NSArray<NSColor *> *)gradientColors {
    self.gradientColors = gradientColors;
    NSError *error;
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:self.gradientColors requiringSecureCoding:NO error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"gradientColors"];
}

- (NSInteger)bytesToRead {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"bytesToRead"] integerValue];
}

- (void)saveNumberOfHeaderBytesToRead:(NSInteger)num {
    [[NSUserDefaults standardUserDefaults] setInteger:num forKey:@"bytesToRead"];
}

@end
