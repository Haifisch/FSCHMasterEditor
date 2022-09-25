//
//  CollectionLayout.m
//  FSCHMasterEditor
//
//  Created by Dylan Laws on 9/20/22.
//

#import "CollectionLayout.h"

@implementation CollectionLayout

- (void)prepareLayout {
    self.scrollDirection = NSCollectionViewScrollDirectionVertical;
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    if ([[[self collectionView] identifier] isEqualToString:@"addressView"]) {
        self.itemSize = NSMakeSize(48, 16);
        self.estimatedItemSize = NSMakeSize(48, 16);
        self.sectionInset = NSEdgeInsetsMake(0, 0, 0, 0);
    } else {
        self.itemSize = NSMakeSize(16, 16);
        self.estimatedItemSize = NSMakeSize(16, 16);
        self.sectionInset = NSEdgeInsetsMake(0, 0, 0, 0);
    }
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
   return NO;
}
/*
- (NSCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSCollectionViewLayoutAttributes *attr = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    if (![[[self collectionView] identifier] isEqualToString:@"addressView"]) {
        int y = indexPath.item * 16;
        int x = (indexPath.item / 24) * 16;
        NSRect modifiedFrame = [attr frame];
        modifiedFrame.origin.x = floor(modifiedFrame.origin.x / (modifiedFrame.size.width + [self minimumInteritemSpacing])) * (modifiedFrame.size.width + [self minimumInteritemSpacing]);
        [attr setFrame:modifiedFrame];
    } else {
        NSRect modifiedFrame = [attr frame];
        modifiedFrame.origin.y = floor(modifiedFrame.origin.y / (modifiedFrame.size.height + [self minimumInteritemSpacing])) * (modifiedFrame.size.height + [self minimumInteritemSpacing]);
        [attr setFrame:modifiedFrame];
    }
    
    return attr;
}*/

@end
