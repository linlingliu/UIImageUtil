//
//  UIView+MMOverlay.h
//  UIDemo
//
//  Created by LX on 2018/12/12.
//  Copyright © 2018 LX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 通过生成与背景色同色的镂空图片覆盖在views上来实现圆角，在纯背景色且内容无变化子views上使用
 */

@interface UIView (MMOverlay)


/**
 为size设置好的View添加圆角

 @param radius 半径
 @param bgColor 视图的父view背景色
 */
- (void)mm_cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor;

- (void)mm_cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor;

- (void)mm_cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor;


/**
 添加圆角

 @param radius 半径
 @param size 所需覆盖的view的size
 @param bgColor 视图的父view的背景色
 */
- (void)mm_cornerRadius:(CGFloat)radius size:(CGSize)size backgroundColor:(UIColor *)bgColor;

- (void)mm_cornerRadius:(CGFloat)radius size:(CGSize)size backgroundColor:(UIColor *)bgColor corners:(UIRectCorner)corners;

- (void)mm_cornerRadius:(CGFloat)radius size:(CGSize)size backgroundColor:(UIColor *)bgColor corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor;

@end

NS_ASSUME_NONNULL_END
