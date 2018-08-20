//
//  UBCDealCell.m
//  Ubcoin
//
//  Created by Alex Ostroushko on 08.08.2018.
//  Copyright © 2018 UBANK. All rights reserved.
//

#import "UBCDealCell.h"

@implementation UBCDealCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.icon.cornerRadius = 10;
        self.iconWidth = 75;
        self.iconHeight = 75;
        
        self.title.numberOfLines = 1;
        self.desc.numberOfLines = 1;
        self.desc.font = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        
        HUBLabel *info = [HUBLabel.alloc initWithStyle:HUBLabelStyleDefaultDescription];
        info.attributedText = [self infoString];
        [self.leftStackView addArrangedSubview:info];
    }
    
    return self;
}

- (NSAttributedString *)infoString
{
    NSTextAttachment *tgIcon = NSTextAttachment.new;
    tgIcon.image = [UIImage imageNamed:@"icTg"];
    tgIcon.bounds = CGRectMake(0, (UBFont.descFont.pointSize - tgIcon.image.size.height), tgIcon.image.size.width, tgIcon.image.size.height);
    
    NSMutableAttributedString *info = [NSMutableAttributedString.alloc initWithAttributedString:[NSAttributedString attributedStringWithAttachment:tgIcon]];
    
    NSString *text = [NSString stringWithFormat:@" %@ ", UBLocalizedString(@"str_requires_external_app", nil)];
    [info appendAttributedString:[NSAttributedString.alloc initWithString:text attributes:@{NSForegroundColorAttributeName: UBColor.descColor, NSFontAttributeName: UBFont.descFont}]];
    
    return info;
}

@end
