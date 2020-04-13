//
//  SFAGraph.m
//  SalutronFitnessApp
//
//  Created by Mark John Revilla on 12/2/13.
//  Copyright (c) 2013 Raymond Sarmiento. All rights reserved.
//

#import "SFAGraph.h"

#import "SFAGraphView.h"

@interface SFAGraph ()

@end

@implementation SFAGraph

#pragma mark - Convenience Methods

+ (SFAGraph *)graphWithGraphView:(SFAGraphView *)graphView
{
    SFAGraph *graph = [[SFAGraph alloc] initWithGraphView:graphView];
    return graph;
}

#pragma mark - Initialization

- (id)initWithGraphView:(SFAGraphView *)graphView
{
    if (self = [super init])
    {
        self.frame = graphView.bounds;
    }
    
    return self;
}

@end
