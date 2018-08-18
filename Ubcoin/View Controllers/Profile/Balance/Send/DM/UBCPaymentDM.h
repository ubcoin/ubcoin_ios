//
//  UBCPaymentDM.h
//  Ubcoin
//
//  Created by Alex Ostroushko on 18.08.2018.
//  Copyright © 2018 UBANK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBCPaymentDM : NSObject

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *comission;
@property (readonly, nonatomic) NSNumber *totalAmount;
@property (readonly, nonatomic) BOOL valid;

- (NSArray<UBTableViewRowData *> *)rowsData;

@end
