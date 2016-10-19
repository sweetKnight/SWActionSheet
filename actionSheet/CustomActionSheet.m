//
//  CustomActionSheet.m
//  YYModelTest
//
//  Created by 冯剑锋 on 16/1/25.
//  Copyright © 2016年 冯剑锋. All rights reserved.
//

#import "CustomActionSheet.h"

#define DEF_Screen_Withd [UIScreen mainScreen].bounds.size.width

#define DEF_Screen_Height [UIScreen mainScreen].bounds.size.height

static int baseTagValue = 500;

typedef NS_ENUM(NSInteger, AnitionState){
    AnitionStateNone,
    AnitionStateStart,
    AnitionStateEnd,
};

static CGFloat buttonHeight = 40;
static CGFloat titleHeight = 35;

@interface CustomActionSheet ()
{
    
    struct{
        unsigned int __otherButtonDidClick : 1;
    }_otherButtonClickDelegate;
    
    BOOL isHaveTitle;
    BOOL isHaveCancelButton;
    CGRect showFrame;
    CGRect hiddenFrame;
}

@property (nonatomic, strong) UIButton * backgroundButton;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * cancelButton;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, assign) AnitionState state;
@end

@implementation CustomActionSheet



-(instancetype)initWithTitle:(NSString *)title delegate:(id<CustomActionSheetDelegate>) delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *) otherButtonTitleArrary{
    self = [super initWithFrame:CGRectMake(0, 0, DEF_Screen_Withd, DEF_Screen_Height)];
    if (self) {
        _state = AnitionStateNone;
        _delegate = delegate;
        
        //创建显示背景试图(根据元素个数)
        [self createBottomBGView:[self returnButtonNumber:title CancelButtonTitle:cancelButtonTitle OtherButtonTitleArrary:otherButtonTitleArrary]];
        
        //经过判断然后创建取消按键
        [self createCancelButton:cancelButtonTitle];
        
        //经过判断然后创建title
        [self creatTittleView:title];
        
        //经过判断然后创建其他功能按键
        [self creatButtonView:isHaveTitle OtherButtonTitleArrary:otherButtonTitleArrary];
    }
    return self;
}

-(void)setDelegate:(id<CustomActionSheetDelegate>)delegate{
    _delegate = delegate;
    _otherButtonClickDelegate.__otherButtonDidClick = [_delegate respondsToSelector:@selector(otherButtonDidClick:)];
}

#pragma mark - showAndHidden
-(void)showInView:(UIView *)view{
    [view.window addSubview:self];
    [self animationMethodForPop:_bottomView];
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundButton.alpha = 1;
        _bottomView.frame = showFrame;
    } completion:^(BOOL finished) {
        _state = AnitionStateEnd;
    }];
}

-(void)cancelButtonClick{
    if (_state != AnitionStateEnd) {
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundButton.alpha = 0;
        _bottomView.frame = hiddenFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)otherButtonClick:(UIButton *)button{
    if (_state != AnitionStateEnd) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(otherButtonDidClick:)]) {
        [_delegate otherButtonDidClick:button];
    }
    [self cancelButtonClick];
}

#pragma mark - 封装方法
/*!
 *  创建显示背景试图(根据元素个数)
 *
 *  @param lineNumber 元素个数
 */
-(void)createBottomBGView:(NSInteger)lineNumber{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _backgroundButton = [[UIButton alloc]initWithFrame:self.bounds];
    _backgroundButton.backgroundColor = [UIColor clearColor];
    _backgroundButton.alpha = 0;
    [_backgroundButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backgroundButton];
    
    showFrame = CGRectMake(0, DEF_Screen_Height - 41*lineNumber-10 - 10, DEF_Screen_Withd, 41*lineNumber+10);
    hiddenFrame = CGRectMake(0, DEF_Screen_Height, DEF_Screen_Withd, 41*lineNumber+10);
    
    _bottomView = [[UIView alloc]initWithFrame:hiddenFrame];
    _bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    _bottomView.layer.shadowOffset = CGSizeMake(0, 0);
    _bottomView.layer.shadowOpacity = 0.5;
    _bottomView.layer.shadowRadius = 5;
    [self addSubview:_bottomView];
}
/*!
 *  创建功能按键个数
 *
 *  @param ishaveTitle            是否有标题
 *  @param otherButtonTitleArrary 功能按键标题数组
 */
-(void)creatButtonView:(BOOL)ishaveTitle OtherButtonTitleArrary:(NSArray *)otherButtonTitleArrary{
    for (int i = 0; i < otherButtonTitleArrary.count; i++) {
        UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(10, (ishaveTitle?46:0) +i*(buttonHeight + 1), DEF_Screen_Withd - 20, buttonHeight)];
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(otherButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:otherButtonTitleArrary[i] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.tag = baseTagValue+i+1;
        [_bottomView addSubview:button];
    }
}
/*!
 *  经过判断然后创建取消按键
 *
 *  @param cancelButtonTitle 取消按键标题
 */
-(void)createCancelButton:(NSString *)cancelButtonTitle{
    if (isHaveCancelButton) {
        _cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(10, CGRectGetHeight(_bottomView.frame) - 40, DEF_Screen_Withd-20, buttonHeight)];
        _cancelButton.layer.cornerRadius = 5;
        _cancelButton.layer.masksToBounds = YES;
        [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        
        [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_cancelButton];
    }
    _cancelButton.tag = baseTagValue;
}
/*!
 *  创建标题View
 *
 *  @param title 标题
 */
-(void)creatTittleView:(NSString *)title{
    if (isHaveTitle) {
        UIView * titleView = [[UIView alloc]initWithFrame:CGRectMake(10, 5, DEF_Screen_Withd-20, titleHeight)];
        titleView.backgroundColor = [UIColor whiteColor];
        titleView.layer.cornerRadius = 5;
        titleView.layer.masksToBounds = YES;
        [_bottomView addSubview:titleView];
        
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(titleView.frame), CGRectGetHeight(titleView.frame))];
        _titleLabel.text = title;
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleView addSubview:_titleLabel];
    }
}
/*!
 *  返回元素个数
 *
 *  @param title                  标题
 *  @param cancelButtonTitle      取消按键
 *  @param otherButtonTitleArrary 功能按键
 *
 *  @return 元素个数
 */
-(NSInteger)returnButtonNumber:(NSString *)title CancelButtonTitle:(NSString *)cancelButtonTitle OtherButtonTitleArrary:(NSArray *)otherButtonTitleArrary{
    NSInteger lineNumber = 0;
    if (title != nil) {
        isHaveTitle = YES;
        lineNumber ++;
    }
    if (cancelButtonTitle != nil) {
        isHaveCancelButton = YES;
        lineNumber ++;
    }
    if (otherButtonTitleArrary != nil) {
        lineNumber = lineNumber + otherButtonTitleArrary.count;
    }
    return lineNumber;
}

#pragma mark - 动画
-(void)animationMethodForPop:(UIView *)duhuanView{
    _state = AnitionStateStart;
    CASpringAnimation * spring = [[CASpringAnimation alloc]init];
    spring.keyPath = @"position.y";
    spring.damping = 12;
    spring.stiffness = 180;
    spring.mass = 1;
    spring.initialVelocity = 0;
    spring.fromValue = @(duhuanView.center.y);
    spring.toValue = @(showFrame.origin.y + showFrame.size.height/2);
    spring.duration = spring.settlingDuration;
    spring.delegate = self;
    [duhuanView.layer addAnimation:spring forKey:@"spring_position.y"];
    
    CABasicAnimation * animate = [[CABasicAnimation alloc]init];
    animate.keyPath = @"opacity";
    animate.fromValue = @(0);
    animate.toValue = @(1);
    animate.duration = spring.settlingDuration;
    [_backgroundButton.layer addAnimation:animate forKey:@"animate_opacity"];
    
    _backgroundButton.alpha = 1;
    duhuanView.frame = showFrame;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag == YES) {
        _state = AnitionStateEnd;
    }
}

@end
