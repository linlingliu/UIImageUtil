//
//  UIImage+imageScale.m
//  UIImageCategory
//
//  Created by LX on 2019/1/3.
//  Copyright © 2019 LX. All rights reserved.
//

#import "UIImage+imageScale.h"

static NSInteger const kUploadImageLength = 1.00 * 1024 * 1024;

@implementation UIImage (imageScale)

- (UIImage *)mm_subImage:(CGRect)rect {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *smallImage = [UIImage imageWithCGImage:subImageRef];
    return smallImage;
}

- (UIImage *)mm_scaleToSize:(CGSize)size {
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    CGFloat verticalRadio = size.height * 1.0/height;
    CGFloat horizontalRadio = size.width * 1.0/width;
    CGFloat radio = 1;
    if (verticalRadio > 1 && horizontalRadio > 1) {
        radio = verticalRadio > horizontalRadio ? horizontalRadio:verticalRadio;
    }else {
        radio = verticalRadio < horizontalRadio? verticalRadio:horizontalRadio;
    }
    width = width *radio;
    height = height *radio;
    //防止图片变形
    NSInteger xPos = (size.width - width) / 2;
    NSInteger yPos = (size.height - height) /2;
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

- (UIImage *)mm_croppedImage:(CGRect)bounds {
    CGFloat scale = MAX(self.scale, 1.0f);
    CGRect scaledBounds = CGRectMake(bounds.origin.x * scale, bounds.origin.y * scale, bounds.size.width * scale, bounds.size.height * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, scaledBounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (NSData *)mm_dataCompresWithLength:(NSInteger)length {
    if (length > kUploadImageLength) {
        length = kUploadImageLength;
    }
    NSData *imageData = [[NSData alloc] init];
    for (NSInteger compression = 1.0; compression >= 0.0; compression -=.1) {
        imageData = UIImageJPEGRepresentation(self, compression);
        NSInteger imageLength = imageData.length;
        if (imageLength < length) {
            break;
        }
    }
    return imageData;
}

#pragma mark -
#pragma mark Util

+ (UIImage *)mm_imageWithColor:(UIColor *)color withRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

- (UIImage *)mm_roundCornerImageWithRadius:(CGFloat)radius {
    UIImage *roundCornerImage = self;
    CGRect imageBoundles = CGRectMake(0, 0, roundCornerImage.size.width, roundCornerImage.size.height);
    UIGraphicsBeginImageContextWithOptions(roundCornerImage.size, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:imageBoundles cornerRadius:radius] addClip];
    [roundCornerImage drawInRect:imageBoundles];
    roundCornerImage = UIGraphicsGetImageFromCurrentImageContext();
    return roundCornerImage;
}

+ (UIImage *)mm_screenshot {
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (![window respondsToSelector:@selector(screen)] || window.screen == [UIScreen mainScreen]) {
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, window.center.x, window.center.y);
            CGContextConcatCTM(context, window.transform);
            CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x,
                                  -window.bounds.size.height * window.layer.anchorPoint.y);
            [window.layer renderInContext:context];
            CGContextRestoreGState(context);
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
