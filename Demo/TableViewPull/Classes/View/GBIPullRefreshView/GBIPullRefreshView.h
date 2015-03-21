//
//  GBIPullRefreshView.h
//  DemoFloatHeaderPullRefreshTableView
//
//  Created by Andy Cui on 13-1-24.
//  Copyright (c) 2013年 Andy Cui. All rights reserved.
//

//
//  EGORefreshTableHeaderView.h
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

typedef enum GBIPullRefreshViewDirection {
	GBIPullRefreshViewDirectionPullDown = 0,
	GBIPullRefreshViewDirectionPullUp = 1,
	GBIPullRefreshViewDirectionPullRight = 2,
    GBIPullRefreshViewDirectionPullLeft = 3
} GBIPullRefreshViewDirection;


typedef enum{
	GBIPullRefreshViewPulling = 0,
	GBIPullRefreshViewNormal,
	GBIPullRefreshViewLoading,
} GBIPullRefreshViewState;

@protocol GBIPullRefreshViewDelegate;

@interface GBIPullRefreshView : UIView{
    
    GBIPullRefreshViewState _state;
    
    GBIPullRefreshViewDirection _pullDirection;
    
    UILabel *_infoLabel;
    
    UILabel *_statusLabel;
    
    CALayer *_arrowImage;
    
    UIActivityIndicatorView *_activityView;
    
    id<GBIPullRefreshViewDelegate> _delegate;
    
}

@property (nonatomic, assign) id<GBIPullRefreshViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame imageName:(NSString*)arrow textColor:(UIColor *)textColor pullDirection:(GBIPullRefreshViewDirection)direction;

-(void)parentScrollViewDidScroll:(UIScrollView *)parentScrollView;
-(void)parentScrollViewDidEndDragging:(UIScrollView *)parentScrollView;

-(void)parentScrollViewDidFinishLoading:(UIScrollView *)parentScrollView;

-(void)refreshView;

@end

@protocol GBIPullRefreshViewDelegate <NSObject>

-(BOOL)shouldTriggerPullStateChangeEvent:(GBIPullRefreshView*)view;
-(BOOL)shouldTriggerLoadEvent:(GBIPullRefreshView*)view;

- (void)pullRefreshViewDidTriggerRefresh:(GBIPullRefreshView*)view;
- (BOOL)pullRefreshViewDataSourceIsLoading:(GBIPullRefreshView*)view;

-(UIEdgeInsets)normalEdgeInset;

-(UIEdgeInsets)loadingEdgeInset:(GBIPullRefreshView*)view;

@optional
- (NSDate*)pullRefreshViewDataSourceLastUpdated:(GBIPullRefreshView*)view;



@end