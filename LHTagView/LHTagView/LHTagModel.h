//
//  LHTagModel.h
//  LHTagView
//
//  Created by Apple on 17/1/12.
//  Copyright © 2017年 Linitial. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHTagModel : NSObject

@property (nonatomic, assign) BOOL isSelected;

/**
 *  @p 方向 左上:3，左下:4，右上:5, 右下:6
 */
@property (nonatomic, assign) NSInteger Direction;

/**
 *  @p 1显示 2 隐藏
 */
@property (nonatomic, assign) NSInteger Status;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *detail;

@property (nonatomic, assign) CGFloat Top;
@property (nonatomic, assign) CGFloat Left;
@property (nonatomic, assign) CGFloat Width;
@property (nonatomic, assign) CGFloat Height;

/**
 *  @p 是否加载
 */
@property (nonatomic, assign) BOOL isLoaded;

@end
