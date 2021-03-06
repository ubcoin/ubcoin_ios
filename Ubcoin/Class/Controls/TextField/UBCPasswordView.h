//
//  UBCPasswordView.h
//  Ubcoin
//
//  Created by Alex Ostroushko on 01.08.2018.
//  Copyright © 2018 UBANK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBCPasswordView : UIView

@property (readonly, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *placeholder;

- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)isValid;

@end
