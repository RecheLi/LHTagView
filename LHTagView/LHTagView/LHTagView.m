//
//  LHTagView.m
//  LHTagView
//
//  Created by Apple on 17/1/12.
//  Copyright © 2017年 Linitial. All rights reserved.
//

#import "LHTagView.h"
#import "LHTagModel.h"
#import "LHTConfigs.h"

@interface LHTagView () <UIGestureRecognizerDelegate> {
    CGFloat viewTagLeft, startAngle, endAngle;
}

//名称
@property (nonatomic, strong) UILabel *nameLabel;

//详情
@property (nonatomic, strong) UILabel *detailLabel;

//容器
@property (nonatomic, strong) UIView *containerView;

//父视图
@property (nonatomic, weak) UIImageView *parentImageView;

//圆角视图
@property (nonatomic, strong) UIView *dotLayer;

//弧
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

//方向
@property (nonatomic, assign) LHTagDirection direction;

@end

const CGFloat kLHTagHeight = 58.0;
const CGFloat kLHTagBlackDotWidth = 20.0;
const CGFloat kLHTagWhiteDotWidth = 8.0;
const CGFloat kLHTagLabelHeight = 15.0;
const CGFloat kLHTagLabelPadding = 15.0;

@implementation LHTagView

- (instancetype)initWithTagModel:(LHTagModel *)model
                       superview:(UIImageView *)imageView {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [imageView addSubview:self];
        _parentImageView = imageView;
        _model = model;
        self.height = kLHTagHeight;
        [self commonInit];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(_model.Left));
            make.top.equalTo(@(_model.Top));
            make.width.equalTo(@(_model.Width));
            make.height.equalTo(@(self.height));
        }];
        [self setDirection:_model.Direction];
    }
    return self;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.lineWidth = (kLHTagBlackDotWidth-kLHTagWhiteDotWidth/2.0)/2.0;
        _shapeLayer.lineCap = kCALineCapButt;
        _shapeLayer.strokeColor = [[[UIColor blackColor]colorWithAlphaComponent:.5] CGColor];
        _shapeLayer.fillColor = nil;
    }
    return _shapeLayer;
}

- (void)drawRect:(CGRect)rect {
    [self.dotLayer layoutIfNeeded];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddArc(pathRef, &CGAffineTransformIdentity,
                 _dotLayer.width/2.0, _dotLayer.height/2.0, (kLHTagBlackDotWidth-kLHTagWhiteDotWidth/2.0)/2.0, startAngle, endAngle, YES);
    self.shapeLayer.path = pathRef;
}

- (void)commonInit {
    startAngle = 0;
    endAngle = -M_PI*3/2;
    [self setupContainer];
    [self setupDots];
    [self setupNameLabel];
    [self setupWeightLabel];
    [self setLayout];
    [self addGesture];
}

- (void)setupContainer {
    _containerView = [UIView new];
    [self addSubview:_containerView];
    _containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    _containerView.layer.cornerRadius = 5.0;
    _containerView.layer.masksToBounds = YES;
}

- (void)setupNameLabel {
    _nameLabel = [UILabel new];
    _nameLabel.origin = CGPointMake(kLHTagLabelPadding, 7);
    _nameLabel.height = kLHTagLabelHeight;
    _nameLabel.numberOfLines = 1;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_containerView addSubview:_nameLabel];
    NSMutableAttributedString *attrName = [[NSMutableAttributedString alloc]initWithString:_model.name attributes:[self defaultAttributes]];
    CGSize nameSize = [attrName boundingRectWithSize:CGSizeMake(MAXFLOAT, kLHTagLabelHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _nameLabel.attributedText = attrName;
    _nameLabel.width = nameSize.width;
}

- (void)setupWeightLabel {
    _detailLabel = [UILabel new];
    _detailLabel.origin = CGPointMake(_nameLabel.left, _nameLabel.bottom+2.0);//2.0 is margintop
    _detailLabel.height = kLHTagLabelHeight;
    _detailLabel.numberOfLines = 1;
    _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_containerView addSubview:_detailLabel];
    NSMutableAttributedString *attrWeight = [[NSMutableAttributedString alloc]initWithString:_model.detail attributes:[self defaultAttributes]];
    CGSize weightSize = [attrWeight boundingRectWithSize:CGSizeMake(MAXFLOAT, kLHTagLabelHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _detailLabel.attributedText = attrWeight;
    _detailLabel.size = weightSize;
}

- (void)setupDots {
    //黑色圆点
    _dotLayer = [UIView new];
    [self addSubview:_dotLayer];
    [_dotLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.width.equalTo(@(kLHTagBlackDotWidth));
        make.height.equalTo(@(kLHTagBlackDotWidth));
    }];
    _dotLayer.clipsToBounds = NO;
    [_dotLayer.layer addSublayer:self.shapeLayer];

    //白色圆点
    CAShapeLayer *whiteLayer = [CAShapeLayer layer];
    whiteLayer.size = CGSizeMake(kLHTagWhiteDotWidth, kLHTagWhiteDotWidth);
    whiteLayer.origin = CGPointMake((kLHTagBlackDotWidth-kLHTagWhiteDotWidth)/2.0, (kLHTagBlackDotWidth-kLHTagWhiteDotWidth)/2.0);
    whiteLayer.cornerRadius = whiteLayer.height/2.0;
    whiteLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [_dotLayer.layer addSublayer:whiteLayer];
}

- (void)setLayout {
    if (_nameLabel.width<_detailLabel.width) {
        _containerView.width = _detailLabel.width+kLHTagLabelPadding*2;
        _nameLabel.width = _detailLabel.width;
    } else {
        _containerView.width = _nameLabel.width+kLHTagLabelPadding*2;
        _detailLabel.width = _nameLabel.width;
    }
    self.width = _containerView.width + kLHTagBlackDotWidth/2.0;
    _model.Width = self.width;
    @weakify(self);
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(kLHTagBlackDotWidth/2.0));
        make.top.equalTo(@(kLHTagBlackDotWidth/2.0));
        make.width.equalTo(@(weak_self.containerView.width));
        make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
    }];
}

- (void)addGesture {
    UIPanGestureRecognizer *panTagView =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panTagView:)];
    panTagView.minimumNumberOfTouches=1;
    panTagView.maximumNumberOfTouches=1;
    panTagView.delegate=self;
    [self addGestureRecognizer:panTagView];
    
    UITapGestureRecognizer* tapTagView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTagView:)];
    tapTagView.numberOfTapsRequired=1;
    tapTagView.numberOfTouchesRequired=1;
    tapTagView.delegate = self;
    [self addGestureRecognizer:tapTagView];
}

/**
 *  标签移动
 */
- (void)panTagView:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:_parentImageView];
    if (sender.state == UIGestureRecognizerStateBegan) {
        viewTagLeft = point.x-self.origin.x;
    }
    [self panTagViewPoint:point];
}

- (void)panTagViewPoint:(CGPoint )point {
    @weakify(self);
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(point.x-viewTagLeft));
        make.top.equalTo(@(point.y-weak_self.height/2));
        if((point.x-viewTagLeft)<=0){
            make.left.equalTo(@0);
        }
        if (point.y+weak_self.size.height/2 >= weak_self.parentImageView.height) {
            make.top.equalTo(@(weak_self.parentImageView.height-weak_self.height));
        }
        if (point.y-weak_self.size.height/2 <= 0) {
            make.top.equalTo(@(0));
        }
        if (point.x+weak_self.width-viewTagLeft >= kScreenWidth) {
            make.left.equalTo(@(kScreenWidth-weak_self.width));
        }
    }];
    _model.Left = self.frame.origin.x;
    _model.Top = self.frame.origin.y;
    if (_modelBlock) {
        _modelBlock(_model);
    }
}

/**
 *点击标签翻转
 */
- (void)tapTagView:(UITapGestureRecognizer *)sender{
    [self setDotLayerDirection];
}

- (void)setDotLayerDirection {
    @weakify(self);
    if (_direction == LHTagDirectionLeftTop) { //当前方向左上
        //点击后转右上，更新右上约束
        [_dotLayer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(weak_self.width-kLHTagBlackDotWidth));
            make.top.equalTo(@0);
            make.width.equalTo(@(kLHTagBlackDotWidth));
            make.height.equalTo(@(kLHTagBlackDotWidth));
        }];
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@(kLHTagBlackDotWidth/2.0));
            make.width.equalTo(@(weak_self.containerView.width));
            make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
        }];
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(weak_self.origin.x+weak_self.width-8));
            if (weak_self.right+weak_self.width-8 >= kScreenWidth) {
                make.left.equalTo(@(kScreenWidth-weak_self.width));
            }
        }];
        startAngle = M_PI_2;
        endAngle = -M_PI;
        [self setNeedsDisplay];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _nameLabel.textAlignment = NSTextAlignmentRight;
        _direction = LHTagDirectionRightTop;
    } else if (_direction == LHTagDirectionRightTop) { //当前方向右上
        //点击后转右下，更新右下约束
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.width.equalTo(@(weak_self.containerView.width));
            make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
        }];
        
        [_dotLayer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(weak_self.width-kLHTagBlackDotWidth));
            make.top.equalTo(@(weak_self.height-kLHTagBlackDotWidth));
            make.width.equalTo(@(kLHTagBlackDotWidth));
            make.height.equalTo(@(kLHTagBlackDotWidth));
        }];
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(weak_self.origin.x-weak_self.width+8));
            if (weak_self.origin.x-weak_self.width+8<=0) {
                make.left.equalTo(@0);
            }
        }];
        startAngle = M_PI;
        endAngle = -M_PI/2;
        [self setNeedsDisplay];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _nameLabel.textAlignment = NSTextAlignmentRight;
        _direction = LHTagDirectionRightBottom;
    } else if (_direction == LHTagDirectionRightBottom) { //当前方向右下
        //点击后转左下，更新左下约束
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(kLHTagBlackDotWidth/2.0));
            make.top.equalTo(@0);
            make.width.equalTo(@(weak_self.containerView.width));
            make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
        }];
        
        [_dotLayer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@(weak_self.height-kLHTagBlackDotWidth));
            make.width.equalTo(@(kLHTagBlackDotWidth));
            make.height.equalTo(@(kLHTagBlackDotWidth));
        }];
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(weak_self.origin.x-weak_self.width+8));
            if (weak_self.origin.x-weak_self.width+8<=0) {
                make.left.equalTo(@0);
            }
        }];
        startAngle = M_PI*3/2;
        endAngle = 0;
        [self setNeedsDisplay];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _direction = LHTagDirectionLeftBottom;
    } else if (_direction == LHTagDirectionLeftBottom) {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(kLHTagBlackDotWidth/2.0));
            make.top.equalTo(@(kLHTagBlackDotWidth/2.0));
            make.width.equalTo(@(weak_self.containerView.width));
            make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
        }];
        
        [_dotLayer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.width.equalTo(@(kLHTagBlackDotWidth));
            make.height.equalTo(@(kLHTagBlackDotWidth));
        }];
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(weak_self.origin.x-weak_self.width+8));
            if (weak_self.origin.x-weak_self.width+8<=0) {
                make.left.equalTo(@0);
            }
        }];
        startAngle = 0;
        endAngle = -M_PI*3/2;
        [self setNeedsDisplay];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _direction = LHTagDirectionLeftTop;
    }
    [self layoutIfNeeded];
    if (_modelBlock) {
        _modelBlock(_model);
    }
    _model.Direction = _direction;
    _model.Left = self.frame.origin.x;
    _model.Top = self.frame.origin.y;
}

- (void)setDirection:(LHTagDirection)direction {
    _direction = direction;
    @weakify(self);
    if (_direction == LHTagDirectionLeftTop) { //当前方向左上
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(kLHTagBlackDotWidth/2.0));
            make.top.equalTo(@(kLHTagBlackDotWidth/2.0));
            make.width.equalTo(@(weak_self.containerView.width));
            make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
        }];
        
        [_dotLayer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.width.equalTo(@(kLHTagBlackDotWidth));
            make.height.equalTo(@(kLHTagBlackDotWidth));
        }];
        startAngle = 0;
        endAngle = -M_PI*3/2;
        [self setNeedsDisplay];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _direction = LHTagDirectionLeftTop;
    } else if (_direction == LHTagDirectionRightTop) { //当前方向右上
        [_dotLayer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(weak_self.width-kLHTagBlackDotWidth));
            make.top.equalTo(@0);
            make.width.equalTo(@(kLHTagBlackDotWidth));
            make.height.equalTo(@(kLHTagBlackDotWidth));
        }];
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@(kLHTagBlackDotWidth/2.0));
            make.width.equalTo(@(weak_self.containerView.width));
            make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
        }];
        startAngle = M_PI_2;
        endAngle = -M_PI;
        [self setNeedsDisplay];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _nameLabel.textAlignment = NSTextAlignmentRight;
        _direction = LHTagDirectionRightTop;
        
    } else if (_direction == LHTagDirectionRightBottom) { //当前方向右下
        //点击后转右下，更新右下约束
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.width.equalTo(@(weak_self.containerView.width));
            make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
        }];
        
        [_dotLayer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(weak_self.width-kLHTagBlackDotWidth));
            make.top.equalTo(@(weak_self.height-kLHTagBlackDotWidth));
            make.width.equalTo(@(kLHTagBlackDotWidth));
            make.height.equalTo(@(kLHTagBlackDotWidth));
        }];
        startAngle = M_PI;
        endAngle = -M_PI/2;
        [self setNeedsDisplay];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _nameLabel.textAlignment = NSTextAlignmentRight;
        _direction = LHTagDirectionRightBottom;
    } else if (_direction == LHTagDirectionLeftBottom) {
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(kLHTagBlackDotWidth/2.0));
            make.top.equalTo(@0);
            make.width.equalTo(@(weak_self.containerView.width));
            make.height.equalTo(@(kLHTagHeight-kLHTagBlackDotWidth/2.0));
        }];
        
        [_dotLayer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@(weak_self.height-kLHTagBlackDotWidth));
            make.width.equalTo(@(kLHTagBlackDotWidth));
            make.height.equalTo(@(kLHTagBlackDotWidth));
        }];
        startAngle = M_PI*3/2;
        endAngle = 0;
        [self setNeedsDisplay];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _direction = LHTagDirectionLeftBottom;
    }
}

- (NSDictionary *)defaultAttributes {
    return @{NSForegroundColorAttributeName:[UIColor whiteColor],
             NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:14]};
}

- (void)setNameColor:(UIColor *)nameColor {
    _nameColor = nameColor;
    _nameLabel.textColor = _nameColor;
}

- (void)setDetailColor:(UIColor *)detailColor {
    _detailColor = detailColor;
    _detailLabel.textColor = _detailColor;
}

+ (CGFloat)height {
    return kLHTagHeight;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}


@end
