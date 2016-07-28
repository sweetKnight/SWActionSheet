//
//  CustomActionSheet.h
//  YYModelTest
//
//  Created by 冯剑锋 on 16/1/25.
//  Copyright © 2016年 冯剑锋. All rights reserved.
//

#import <UIKit/UIKit.h>
/*!
 *  自定义actionsheet,用500+的tag值取出按键
 */
@protocol CustomActionSheetDelegate;

@interface CustomActionSheet : UIView

@property (nonatomic, weak) id<CustomActionSheetDelegate> delegate;
/*!
 *  创建actionsheet(下面参数没有的都传递nil)
 *
 *  @param title                  标题
 *  @param delegate               代理
 *  @param cancelButtonTitle      取消按键标题
 *  @param otherButtonTitleArrary 其他按键数组
 *
 *  @return 返回实例
 */
-(instancetype)initWithTitle:(NSString *)title delegate:(id<CustomActionSheetDelegate>) delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *) otherButtonTitleArrary;
/*!
 *  出现在当前试图
 *
 *  @param view 将要添加的试图
 */
-(void)showInView:(UIView *)view;

@end


@protocol CustomActionSheetDelegate <NSObject>
/*!
 *  功能按键点击代理
 *
 *  @param button 按键
 */
-(void)otherButtonDidClick:(UIButton *)button;

@end