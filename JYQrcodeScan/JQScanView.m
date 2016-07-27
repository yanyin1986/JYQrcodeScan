//
//  JQScanView.m
//  JYQrcodeScan
//
//  Created by Leon.yan on 27/07/2016.
//  Copyright © 2016 Jilu+Leon. All rights reserved.
//

#import "JQScanView.h"
#import "JQScanLayer.h"

@interface JQScanView ()

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) JQScanLayer *scanLayer;
@property (nonatomic, strong) CALayer *lineLayer;
@property (nonatomic, strong) UIView *textView;

@end

@implementation JQScanView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _commonInit];
}

- (void)_commonInit
{
    _maskLayer = [CAShapeLayer layer];
    
    CGRect frame = CGRectMake((CGRectGetWidth(self.bounds) - 240) / 2.0, (CGRectGetHeight(self.bounds) - 240) / 2.0, 240, 240);
    UIBezierPath *maskPath = [self _maskPathForClipFrame:frame];
    _maskLayer.path = maskPath.CGPath;
    _maskLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
    [self.layer addSublayer:_maskLayer];
    
    _scanLayer = [JQScanLayer layer];
    _scanLayer.frame = frame;
    [self.layer addSublayer:_scanLayer];
    
    const CGPoint positions[4] = {
        CGPointMake(9, 9),
        CGPointMake(231, 9),
        CGPointMake(231, 231),
        CGPointMake(9, 231),
    };
    
    for (int i = 0; i < 4; i++) {
        CALayer *cornerLayer = [CALayer layer];
        cornerLayer.bounds = CGRectMake(0, 0, 16, 16);
        cornerLayer.contents = (__bridge id) [UIImage imageNamed:@"scan-corner"].CGImage;
        cornerLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2 * i);
        cornerLayer.position = positions[i];
        [_scanLayer addSublayer:cornerLayer];
    }
}

- (UIBezierPath *)_maskPathForClipFrame:(CGRect)clipFrame
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *clipPath = [[UIBezierPath bezierPathWithRect:clipFrame] bezierPathByReversingPath];
    [path appendPath:clipPath];
    
    return path;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    
    CGRect frame = CGRectMake((CGRectGetWidth(self.bounds) - 240) / 2.0, (CGRectGetHeight(self.bounds) - 240) / 2.0, 240, 240);
    UIBezierPath *maskPath = [self _maskPathForClipFrame:frame];
    _maskLayer.path = maskPath.CGPath;
    _scanLayer.frame = frame;
    [CATransaction commit];
    
    _textView.center = CGPointMake(self.bounds.size.width / 2.0,
                                   CGRectGetMaxY(frame) + 20 + CGRectGetHeight(_textView.frame) / 2.0);
}

- (void)startAnimation
{
    if (!_lineLayer) {
        _lineLayer = [CALayer layer];
        _lineLayer.contents = (__bridge id) [UIImage imageNamed:@"scan-line"].CGImage;
        _lineLayer.bounds = CGRectMake(0, 0, 240, 24);
        _lineLayer.position = CGPointMake(120, 0);
        _scanLayer.masksToBounds = YES;
        [_scanLayer addSublayer:_lineLayer];
    }
    _textView.hidden = NO;
    _lineLayer.hidden = NO;
    [_lineLayer removeAllAnimations];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.fromValue = @(0);
    animation.toValue = @(240);
    animation.duration = 3;
    animation.repeatCount = CGFLOAT_MAX;
    
    [_lineLayer addAnimation:animation forKey:@"position.y"];
    
}

- (void)stopAnimation
{
    [_lineLayer removeAllAnimations];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    _lineLayer.hidden = YES;
    [CATransaction commit];
}

@end
