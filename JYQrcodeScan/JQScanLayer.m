//
//  JQScanLayer.m
//  JYQrcodeScan
//
//  Created by Leon.yan on 27/07/2016.
//  Copyright © 2016 Jilu+Leon. All rights reserved.
//

@import UIKit;

#import "JQScanLayer.h"

@implementation JQScanLayer

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self display];
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGPathRef path = CGPathCreateWithRect(self.bounds, NULL);
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, self.bounds);
    // draw line
    CGContextAddPath(ctx, path);
    
    CGPathRelease(path);
    
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    // draw mark
    CGContextRestoreGState(ctx);
}

@end
