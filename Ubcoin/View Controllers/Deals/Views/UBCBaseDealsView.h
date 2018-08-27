//
//  UBCBaseDealsView.h
//  Ubcoin
//
//  Created by Alex Ostroushko on 08.08.2018.
//  Copyright © 2018 UBANK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBCDealDM.h"

@class UBCGoodDM;
@protocol UBCDealsViewDelegate <NSObject>

- (void)openChatForItem:(UBCGoodDM *)item;

@end

@interface UBCBaseDealsView : UIView <UBDefaultTableViewDelegate>

@property (weak, nonatomic) id<UBCDealsViewDelegate> delegate;
@property (strong, nonatomic) UBDefaultTableView *tableView;
@property (strong, nonatomic) NSMutableArray *items;
@property (assign, nonatomic) NSUInteger pageNumber;

- (void)setupEmptyView;
- (void)updateInfo;
- (void)handleResponse:(NSArray *)deals;

- (NSAttributedString *)infoStringWithString:(NSString *)string;

@end
