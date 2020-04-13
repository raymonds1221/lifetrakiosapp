//
//  SFAGraph.h
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/2/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "CPTXYGraph.h"

@class SFAGraphView;

@interface SFAGraph : CPTXYGraph

+ (SFAGraph *)graphWithGraphView:(SFAGraphView *)graphView;

- (id)initWithGraphView:(SFAGraphView *)graphView;

@end
