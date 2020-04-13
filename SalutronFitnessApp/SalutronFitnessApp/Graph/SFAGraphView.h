//
//  BTGraphView.h
//  BLETest
//
//  Created by Mark John Revilla on 11/13/13.
//  Copyright (c) 2013 Stratpoint. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"

#import "CPTGraphHostingView.h"

@protocol SFAGraphViewDelegate <NSObject>
@optional
- (void)graphTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)graphTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end

@interface SFAGraphView : CPTGraphHostingView

@property (strong, nonatomic) id<SFAGraphViewDelegate> delegate;

@end