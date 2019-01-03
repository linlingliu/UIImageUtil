//
//  UIView+MMOverlay.m
//  UIDemo
//
//  Created by LX on 2018/12/12.
//  Copyright © 2018 LX. All rights reserved.
//

/*
 fillRule 指定使用哪一种算法去判断画布上的某区域是否属于该图形“内部” （内部区域将被填充）
 noZero 为0,不在图形内    从图中一点做射线，和路径的方向为锐角加1，钝角减一
 even——odd 和路径的交点为奇数在图形内，否则在图形外，与方向无关
 */
#import "UIView+MMOverlay.h"
#import <objc/runtime.h>


#pragma mark -
#pragma mark MMOverlayBorder

@interface MMOverlayBorder : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) UIColor *color;

@end

@implementation MMOverlayBorder

+ (instancetype)overlayBorderWithWidth:(CGFloat)width andColor:(UIColor *)color {
    MMOverlayBorder *_border = [[MMOverlayBorder alloc] init];
    _border.width = width;
    _border.color = color;
    return _border;
}

- (NSString *)overlayCacheKey {
    return [NSString stringWithFormat:@"%@_%@",@(self.width),self.color.description];
}

@end

#pragma mark -
#pragma mark MMOverlayModel

@interface MMOverlayModel : NSObject

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, assign) UIRectCorner corners;
@property (nonatomic, strong, nullable) MMOverlayBorder *border;
@property (nonatomic, assign) CGSize ceilSize;
//@property (nonatomic, readonly) CGFloat ceilWidth;
//@property (nonatomic, readonly) CGFloat ceilHeight;

@end

@implementation MMOverlayModel

+ (instancetype)overlayModelWithRadius:(CGFloat)radius size:(CGSize)size bgColor:(UIColor *)bgColor corners:(UIRectCorner)corners border:(nullable MMOverlayBorder *)border {
    MMOverlayModel *_model = [[MMOverlayModel alloc] init];
    _model.radius = radius;
    _model.size = size;
    _model.bgColor = bgColor;
    _model.corners = corners;
    _model.border = border;
    return _model;
}

- (NSString *)overlayCacheKey {
    NSString *suffix = [self.border overlayCacheKey]?:@"";
    return [[NSString stringWithFormat:@"%@_%@_%@_%@",@(self.radius),NSStringFromCGSize(self.size),self.bgColor.description,@(self.corners)] stringByAppendingString:suffix];
}

- (void)setSize:(CGSize)size {
    _size = size;
    _ceilSize = CGSizeMake(ceil(size.width), ceil(size.height));
}

@end

#pragma mark -
#pragma mark UIView + MMOverlay

static NSCache <NSString *, UIImage *> *mm_OverlayCache;

@interface UIView ()

@property (nonatomic, strong) UIImageView *mm_overlayImageView;

@end

@implementation UIView (MMOverlay)

- (void)mm_cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor {
    [self mm_cornerRadius:radius backgroundColor:bgColor corners:0 borderWidth:0 borderColor:nil];
}

- (void)mm_cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor {
    [self mm_cornerRadius:radius backgroundColor:bgColor corners:0 borderWidth:borderWidth borderColor:borderColor];
}

- (void)mm_cornerRadius:(CGFloat)radius backgroundColor:(UIColor *)bgColor corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor {
    [self mm_cornerRadius:radius size:self.bounds.size backgroundColor:bgColor corners:corners borderWidth:borderWidth borderColor:borderColor];
}

- (void)mm_cornerRadius:(CGFloat)radius size:(CGSize)size backgroundColor:(UIColor *)bgColor {
    [self mm_cornerRadius:radius size:size backgroundColor:bgColor corners:0 borderWidth:0 borderColor:nil];
}

- (void)mm_cornerRadius:(CGFloat)radius size:(CGSize)size backgroundColor:(UIColor *)bgColor corners:(UIRectCorner)corners {
    [self mm_cornerRadius:radius size:size backgroundColor:bgColor corners:corners borderWidth:0 borderColor:nil];
}

- (void)mm_cornerRadius:(CGFloat)radius size:(CGSize)size backgroundColor:(UIColor *)bgColor corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(nullable UIColor *)borderColor {
    if (!self.mm_overlayImageView) {
        [self mm_addOverlayImageView];
    }
    MMOverlayBorder *_border = nil;
    if (borderWidth > 0 && borderColor && borderWidth < radius) {
        _border = [MMOverlayBorder overlayBorderWithWidth:borderWidth andColor:borderColor];
    }
    MMOverlayModel *_model = [MMOverlayModel overlayModelWithRadius:radius size:size bgColor:bgColor corners:corners border:_border];
    UIImage *overlayImage = [self mm_overlayImageWithModel:_model];
    self.mm_overlayImageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.mm_overlayImageView.image = overlayImage;
}

#pragma mark -
#pragma mark private Method

- (void)mm_addOverlayImageView {
    UIImageView *overlayView = [[UIImageView alloc] init];
    overlayView.userInteractionEnabled = NO;
    [self addSubview:overlayView];
    self.mm_overlayImageView = overlayView;
}

- (UIImage *)mm_overlayImageWithModel:(MMOverlayModel *)model {
    NSString *cacheKey = [model overlayCacheKey];
    UIImage *overlayImage = [self mm_overlayImageForKey:cacheKey];
    if (!overlayImage) {
        overlayImage = [self mm_buildImageWithModel:model];
        [self mm_setOverlayImage:overlayImage forKey:cacheKey];
    }
    return overlayImage;
}

- (UIImage *)mm_buildImageWithModel:(MMOverlayModel *)model {
    UIGraphicsBeginImageContextWithOptions(model.ceilSize, NO, 0.0);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, model.ceilSize.width, model.ceilSize.height);
    [model.bgColor setFill];
    UIRectFill(rect);
    CGPathRef overlayPath = [self mm_overlayPathWithModel:model rect:rect];
    CGContextSetBlendMode(currentContext, kCGBlendModeDestinationOut);
    CGContextAddPath(currentContext, overlayPath);
    CGContextEOFillPath(currentContext);
    if (model.border) {
        CGContextSetBlendMode(currentContext, kCGBlendModeNormal);
        CGContextEOFillPath(currentContext);
        CGPathRef _borderPath = [self mm_borderPathWithModel:model];
        [model.border.color setStroke];
        CGContextSetLineWidth(currentContext, model.border.width);
        CGContextAddPath(currentContext, _borderPath);
        CGContextStrokePath(currentContext);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGPathRef)mm_overlayPathWithModel:(MMOverlayModel *)model rect:(CGRect)rect {
    CGPathRef _path = nil;
    if (!model.corners) {
        _path = CGPathCreateWithRoundedRect(rect, model.radius, model.radius, nil);
    }else {
        UIBezierPath *_temp = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:model.corners cornerRadii:CGSizeMake(model.radius, model.radius)];
        _path = _temp.CGPath;
    }
    return _path;
}

- (CGPathRef)mm_borderPathWithModel:(MMOverlayModel *)model {
    CGPathRef _path = nil;
    //边框是从中间往2边扩展的
    CGFloat borderCorner = model.radius - model.border.width;
    CGRect borderRect = CGRectMake(model.border.width/2.0, model.border.width/2.0, model.ceilSize.width - model.border.width, model.ceilSize.height - model.border.width);
    if (!model.corners) {
        _path = CGPathCreateWithRoundedRect(borderRect, borderCorner, borderCorner, nil);
    }else {
        UIBezierPath *_temp = [UIBezierPath bezierPathWithRoundedRect:borderRect byRoundingCorners:model.corners cornerRadii:CGSizeMake(borderCorner, borderCorner)];
        _path = _temp.CGPath;
    }
    return _path;
}


#pragma mark -
#pragma mark cache

- (void)mm_setOverlayImage:(UIImage *)image forKey:(NSString *)key {
    if (!mm_OverlayCache) {
        mm_OverlayCache = [[NSCache alloc] init];
    }
    [mm_OverlayCache setObject:image forKey:key];
}

- (nullable UIImage *)mm_overlayImageForKey:(NSString *)key {
    return [mm_OverlayCache objectForKey:key];
}

#pragma mark -
#pragma mark Get,Set Method

- (UIImageView *)mm_overlayImageView {
    return objc_getAssociatedObject(self , _cmd);
}

- (void)setMm_overlayImageView:(UIImageView *)mm_overlayImageView {
    objc_setAssociatedObject(self, @selector(mm_overlayImageView), mm_overlayImageView, OBJC_ASSOCIATION_RETAIN);
}

@end
