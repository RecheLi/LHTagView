//
//  ViewController.m
//  LHTagView
//
//  Created by Apple on 17/1/12.
//  Copyright © 2017年 Linitial. All rights reserved.
//

#import "ViewController.h"
#import "LHTagView.h"
#import "LHTagModel.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData];
}

- (void)getData {
    LHTagModel *model1 = [[LHTagModel alloc]init];
    model1.name = @" angelababy ";
    model1.detail = @" xiaoming ";
    model1.Left = 30.0;
    model1.Top = 75.6;
    model1.Direction = 3;
    LHTagView *view1 = [[LHTagView alloc]initWithTagModel:model1 superview:_imageView];
    view1.modelBlock = ^(LHTagModel *model){
    };
    view1.dotColor = [UIColor cyanColor];
    view1.nameColor = [UIColor purpleColor];
    
    LHTagModel *model2 = [[LHTagModel alloc]init];
    model2.name = @" bangbangbang ";
    model2.detail = @" 😄 baby baby baby 😊 ";
    model2.Left = 65.0;
    model2.Top = 259.6;
    model2.Direction = 5;
    LHTagView *view2 = [[LHTagView alloc]initWithTagModel:model2 superview:_imageView];
    view2.modelBlock = ^(LHTagModel *model){
    };
    view2.bgColor = [UIColor greenColor];
    
    LHTagModel *model3 = [[LHTagModel alloc]init];
    model3.name = @"年会没中奖😢";
    model3.detail = @"呵呵哒";
    model3.Left = 107.0;
    model3.Top = 154.6;
    model3.Direction = 4;
    LHTagView *view3 = [[LHTagView alloc]initWithTagModel:model3 superview:_imageView];
    view3.modelBlock = ^(LHTagModel *model){
    };
    view3.nameColor = [UIColor redColor];
    
    LHTagModel *model4 = [[LHTagModel alloc]init];
    model4.name = @"靓女😍";
    model4.detail = @"😍";
    model4.Left = 107.0;
    model4.Top = 334.6;
    model4.Direction = 6;
    LHTagView *view4 = [[LHTagView alloc]initWithTagModel:model4 superview:_imageView];
    view4.modelBlock = ^(LHTagModel *model){
    };

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
