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
    model1.name = @" name one ";
    model1.detail = @" detail one ";
    model1.Left = 30.0;
    model1.Top = 25.6;
    model1.Direction = 3;
    LHTagView *view1 = [[LHTagView alloc]initWithTagModel:model1 superview:_imageView];
    view1.modelBlock = ^(LHTagModel *model){
        NSLog(@"model1.left %f",model.Left);
    };
    view1.nameColor = [UIColor purpleColor];
    
    LHTagModel *model2 = [[LHTagModel alloc]init];
    model2.name = @" 我的自白 ";
    model2.detail = @" 😄 ";
    model2.Left = 140.0;
    model2.Top = 259.6;
    model2.Direction = 5;
    LHTagView *view2 = [[LHTagView alloc]initWithTagModel:model2 superview:_imageView];
    view2.modelBlock = ^(LHTagModel *model){
        NSLog(@"model2.left %f",model.Left);
    };
    
    LHTagModel *model3 = [[LHTagModel alloc]init];
    model3.name = @" 年会没中奖 ";
    model3.detail = @"呵呵哒";
    model3.Left = 60.0;
    model3.Top = 112.6;
    model3.Direction = 4;
    LHTagView *view3 = [[LHTagView alloc]initWithTagModel:model3 superview:_imageView];
    view3.modelBlock = ^(LHTagModel *model){
        NSLog(@"model3.left %f",model.Left);
    };
    view3.nameColor = [UIColor redColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
