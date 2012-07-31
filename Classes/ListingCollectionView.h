//
//  ListingCollectionView.h
//  Sharetribe
//
//  Created by Janne Käki on 7/31/12.
//
//

#import <Foundation/Foundation.h>

@protocol ListingCollectionView <NSObject>

- (void)addListings:(NSArray *)listings;
- (void)clearAllListings;

@end
