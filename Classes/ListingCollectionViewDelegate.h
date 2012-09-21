//
//  ListingCollectionViewDelegate.h
//  Sharetribe
//
//  Created by Janne Käki on 7/31/12.
//
//

#import <Foundation/Foundation.h>

@class Listing;

@protocol ListingCollectionViewDelegate <NSObject>

- (void)viewController:(UIViewController *)viewer didSelectListing:(Listing *)listing;
- (void)viewController:(UIViewController *)viewer didSelectListings:(NSArray *)listings;

- (void)viewController:(UIViewController *)viewer wantsToRefreshPage:(NSInteger)page;
- (void)viewController:(UIViewController *)viewer wantsToSearch:(NSString *)search;

@end
