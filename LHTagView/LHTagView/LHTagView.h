//
//  LHTagView.h
//  LHTagView
//
//  Created by Apple on 17/1/12.
//  Copyright © 2017年 Linitial. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LHTagModel;
typedef NS_ENUM(NSUInteger, LHTagDirection) {
    LHTagDirectionLeftTop = 3,
    LHTagDirectionLeftBottom,
    LHTagDirectionRightTop,
    LHTagDirectionRightBottom,
};

typedef void(^LHTagHandleBlock)(LHTagModel *tagModel);

@interface LHTagView : UIView

@property (nonatomic, copy) LHTagHandleBlock modelBlock;

@property (nonatomic, strong) LHTagModel *model;

@property (nonatomic, strong) UIColor *nameColor;

@property (nonatomic, strong) UIColor *detailColor;

- (instancetype)initWithTagModel:(LHTagModel *)model
                       superview:(UIImageView *)imageView;

+ (CGFloat)height;

@end
