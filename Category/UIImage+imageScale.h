//
//  UIImage+imageScale.h
//  UIImageCategory
//
//  Created by LX on 2019/1/3.
//  Copyright © 2019 LX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (imageScale)

/**
 截取图片的莫个部位

 @param rect image rect
 @return UIimage
 */
- (UIImage *)mm_subImage:(CGRect)rect;

//改变图片的大小
- (UIImage *)mm_scaleToSize:(CGSize )size;

//裁剪图片
- (UIImage *)mm_croppedImage:(CGRect)bounds;

//图片压缩到指定大小
- (NSData *)mm_dataCompresWithLength:(NSInteger)length;

#pragma mark -
#pragma mark Util

+ (UIImage *)mm_imageWithColor:(UIColor *)color withRect:(CGRect)rect;

//图片做圆角处理
- (UIImage *)mm_roundCornerImageWithRadius:(CGFloat)radius;

//截屏
+ (UIImage *)mm_screenshot;

@end

NS_ASSUME_NONNULL_END
