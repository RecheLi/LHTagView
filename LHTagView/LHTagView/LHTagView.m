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

//小圆视图
@property (nonatomic, strong) UIView *dotView;

//白色圆点
@property (nonatomic, weak) CAShapeLayer *whiteLayer;

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

- (instancetype)initWithTagModel:(LHTagModel *)model
                       superview:(UIImageView *)imageView {
    self = [super init];
    if (self) {
        _model = model;
        [imageView addSubview:self];
        _parentImageView = imageView;
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

- (void)drawRect:(CGRect)rect {
    [self.dotView layoutIfNeeded];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddArc(pathRef, &CGAffineTransformIdentity,
                 _dotView.width/2.0, _dotView.height/2.0, (kLHTagBlackDotWidth-kLHTagWhiteDotWidth/2.0)/2.0, startAngle, endAngle, YES);
    self.shapeLayer.path = pathRef;
}

- (void)commonInit {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.height = kLHTagHeight;
    startAngle = 0;
    endAngle = -M_PI*3/2;
    [self setupContainer];
    [self setupDots];
    [self setupNameLabel];
    [self setupDetailLabel];
    [self setupLayout];
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

- (void)setupDetailLabel {
    _detailLabel = [UILabel new];
    _detailLabel.origin = CGPointMake(_nameLabel.left, _nameLabel.bottom+2.0);//2.0 is margintop
    _detailLabel.height = kLHTagLabelHeight;
    _detailLabel.numberOfLines = 1;
    _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_containerView addSubview:_detailLabel];
    NSMutableAttributedString *attrDetail = [[NSMutableAttributedString alloc]initWithString:_model.detail attributes:[self defaultAttributes]];
    CGSize detailSize = [attrDetail boundingRectWithSize:CGSizeMake(MAXFLOAT, kLHTagLabelHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    _detailLabel.attributedText = attrDetail;
    _detailLabel.size = detailSize;
}

- (void)setupDots {
    //黑色圆点
    _dotView = [UIView new];
    [self addSubview:_dotView];
    [_dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.width.equalTo(@(kLHTagBlackDotWidth));
        make.height.equalTo(@(kLHTagBlackDotWidth));
    }];
    _dotView.clipsToBounds = NO;
    [_dotView.layer addSublayer:self.shapeLayer];

    //白色圆点
    CAShapeLayer *whiteLayer = [CAShapeLayer layer];
    whiteLayer.size = CGSizeMake(kLHTagWhiteDotWidth, kLHTagWhiteDotWidth);
    whiteLayer.origin = CGPointMake((kLHTagBlackDotWidth-kLHTagWhiteDotWidth)/2.0, (kLHTagBlackDotWidth-kLHTagWhiteDotWidth)/2.0);
    whiteLayer.cornerRadius = whiteLayer.height/2.0;
    whiteLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [_dotView.layer addSublayer:whiteLayer];
    self.whiteLayer = whiteLayer;
}

- (void)setupLayout {
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
    panTagView.minimumNumberOfTouches = 1;
    panTagView.maximumNumberOfTouches = 1;
    panTagView.delegate = self;
    [self addGestureRecognizer:panTagView];
    
    UITapGestureRecognizer *tapTagView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTagView:)];
    tapTagView.numberOfTapsRequired = 1;
    tapTagView.numberOfTouchesRequired = 1;
    tapTagView.delegate = self;
    [self addGestureRecognizer:tapTagView];
}

#pragma mark - 拖动标签
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
        if((point.x-viewTagLeft) <= 0){
            make.left.equalTo(@0);
        }
        if (point.y+weak_self.height/2 >= weak_self.parentImageView.height) {
            make.top.equalTo(@(weak_self.parentImageView.height-weak_self.height));
        }
        if (point.y-weak_self.size.height/2 <= 0) {
            make.top.equalTo(@(0));
        }
        if (point.x+weak_self.width-viewTagLeft >= kScreenWidth) {
            make.left.equalTo(@(kScreenWidth-weak_self.width));
        }
    }];
    _model.Left = self.origin.x;
    _model.Top = self.origin.y;
    if (_modelBlock) {
        _modelBlock(_model);
    }
}

#pragma mark - 点击标签翻转
- (void)tapTagView:(UITapGestureRecognizer *)sender{
    [self setDotLayerDirection];
}

#pragma mark - 调整方向
- (void)setDotLayerDirection {
    @weakify(self);
    if (_direction == LHTagDirectionLeftTop) { //当前方向左上
        //点击后转右上，更新右上约束
        [_dotView mas_updateConstraints:^(MASConstraintMaker *make) {
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
        [_dotView mas_updateConstraints:^(MASConstraintMaker *make) {
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
        [_dotView mas_updateConstraints:^(MASConstraintMaker *make) {
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
        [_dotView mas_updateConstraints:^(MASConstraintMaker *make) {
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
    _model.Left = self.origin.x;
    _model.Top = self.origin.y;
}

#pragma mark - 标签方向设置
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
        [_dotView mas_updateConstraints:^(MASConstraintMaker *make) {
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
        [_dotView mas_updateConstraints:^(MASConstraintMaker *make) {
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
        [_dotView mas_updateConstraints:^(MASConstraintMaker *make) {
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
        [_dotView mas_updateConstraints:^(MASConstraintMaker *make) {
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

#pragma mark - setter
- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    _containerView.backgroundColor = _bgColor;
    _shapeLayer.strokeColor = _bgColor.CGColor;
}

- (void)setNameColor:(UIColor *)nameColor {
    _nameColor = nameColor;
    _nameLabel.textColor = _nameColor;
}

- (void)setDetailColor:(UIColor *)detailColor {
    _detailColor = detailColor;
    _detailLabel.textColor = _detailColor;
}

- (void)setDotColor:(UIColor *)dotColor {
    _dotColor = dotColor;
    _whiteLayer.backgroundColor = _dotColor.CGColor;
}

#pragma mark - getter
- (NSDictionary *)defaultAttributes {
    return @{NSForegroundColorAttributeName:[UIColor whiteColor],
             NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Regular" size:14]};
}

+ (CGFloat)height {
    return kLHTagHeight;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}


@end
