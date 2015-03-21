//
//  GBIPullRefreshView.m
//  DemoFloatHeaderPullRefreshTableView
//
//  Created by Andy Cui on 13-1-24.
//  Copyright (c) 2013年 Andy Cui. All rights reserved.
//

#import "GBIPullRefreshView.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f

@interface GBIPullRefreshView (Private)

-(void)setState:(GBIPullRefreshViewState)state;

-(void)setParentScrollViewToDesireContentInsets:(UIScrollView *)parentScrollView forLoaingState:(BOOL)isLoadingState;

@end

@implementation GBIPullRefreshView

@synthesize delegate = _delegate;

-(void)dealloc{

    [_infoLabel release];
    
    [_statusLabel release];
    
    [_arrowImage release];
    
    [_activityView release];
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    [self initWithFrame:frame imageName:nil textColor:TEXT_COLOR pullDirection:GBIPullRefreshViewDirectionPullDown];
    
    return self;
}

-(id)initWithFrame:(CGRect)frame imageName:(NSString*)arrow textColor:(UIColor *)textColor pullDirection:(GBIPullRefreshViewDirection)direction{
    
    if((self = [super initWithFrame:frame])) {
    
        _pullDirection = direction;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont systemFontOfSize:12.0f];
        label.textColor = textColor;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        [self addSubview:label];
        _infoLabel = label;
        [label release];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:13.0f];
        label.textColor = textColor;
        label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        [self addSubview:label];
        _statusLabel=label;
        [label release];
        
        CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
        
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
        
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
        [self addSubview:view];
        _activityView = view;
        [view release];
        
        
        [self setState:GBIPullRefreshViewNormal];
    
    }
    return self;
}


-(void)setState:(GBIPullRefreshViewState)state{
    
    NSString *infoString = @"Pull to refresh...";
    
    switch (_pullDirection) {
        case GBIPullRefreshViewDirectionPullDown:
            infoString = @"Pull down to refresh...";
            break;
        case GBIPullRefreshViewDirectionPullUp:
            infoString = @"Pull up to refresh...";
            break;
        case GBIPullRefreshViewDirectionPullRight:
            infoString = @"Pull right to refresh...";
            break;
        case GBIPullRefreshViewDirectionPullLeft:
            infoString = @"Pull left to refresh...";
            break;
        default:
            break;
    }
    
    switch (state) {
        case GBIPullRefreshViewLoading:
            
            _statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
            
            break;
        case GBIPullRefreshViewNormal:
            
            if (_state == GBIPullRefreshViewPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
            
			_statusLabel.text = NSLocalizedString(infoString, @"Pull to refresh status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
            
			[self refreshView];
            
            break;
        case GBIPullRefreshViewPulling:
            
            _statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
            
            break;
        default:
            break;
    }
    
    _state = state;
    
}

-(void)setParentScrollViewToDesireContentInsets:(UIScrollView *)parentScrollView forLoaingState:(BOOL)isLoadingState{

    UIEdgeInsets normalInsets = UIEdgeInsetsZero;
    
    if (_delegate && [_delegate respondsToSelector:@selector(normalEdgeInset)]) {
        normalInsets = [_delegate normalEdgeInset];
    }
    
    UIEdgeInsets loadingInsets = UIEdgeInsetsZero;
    
    if (isLoadingState && _delegate && [_delegate respondsToSelector:@selector(loadingEdgeInset:)]) {
        loadingInsets = [_delegate loadingEdgeInset:self];
    }
    
    UIEdgeInsets currentInsets = parentScrollView.contentInset;
    
    switch (_pullDirection) {
        case GBIPullRefreshViewDirectionPullDown:
            
            if (currentInsets.top != loadingInsets.top + normalInsets.top) {
                currentInsets.top = loadingInsets.top + normalInsets.top;
            }
            
            break;
        case GBIPullRefreshViewDirectionPullUp:
            
            if (currentInsets.bottom != loadingInsets.bottom + normalInsets.bottom) {
                currentInsets.bottom = loadingInsets.bottom + normalInsets.bottom;
            }
            
            break;
        case GBIPullRefreshViewDirectionPullRight:
            
            if (currentInsets.left != loadingInsets.left + normalInsets.left) {
                currentInsets.left = loadingInsets.left + normalInsets.left;
            }
            
            break;
        case GBIPullRefreshViewDirectionPullLeft:
            
            if (currentInsets.right != loadingInsets.right + normalInsets.right) {
                currentInsets.right = loadingInsets.right + normalInsets.right;
            }
            
            break;
        default:
            break;
    }
    
    //NSLog(@"(%f,%f,%f,%f)",currentInsets.top,currentInsets.left,currentInsets.bottom,currentInsets.right);
    
    parentScrollView.contentInset = currentInsets;

}

-(void)parentScrollViewDidScroll:(UIScrollView *)parentScrollView{
    
    if (_state == GBIPullRefreshViewLoading) {
        //NSLog(@"state is loading...before");
        [self setParentScrollViewToDesireContentInsets:parentScrollView forLoaingState:YES];
        //NSLog(@"state is loading...after");
        
	} else if (parentScrollView.isDragging) {
        
        //NSLog(@"state is isDragging...");
        
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(pullRefreshViewDataSourceIsLoading:)]) {
			_loading = [_delegate pullRefreshViewDataSourceIsLoading:self];
		}
        
        BOOL shouldTriggerPullStateChangeEvent = NO;
		if ([_delegate respondsToSelector:@selector(shouldTriggerPullStateChangeEvent:)]) {
			shouldTriggerPullStateChangeEvent = [_delegate shouldTriggerPullStateChangeEvent:self];
		}
        
		if (_state == GBIPullRefreshViewPulling && !shouldTriggerPullStateChangeEvent && !_loading) {
            
			[self setState:GBIPullRefreshViewNormal];
            
		} else if (_state == GBIPullRefreshViewNormal && shouldTriggerPullStateChangeEvent && !_loading) {
            
			[self setState:GBIPullRefreshViewPulling];
            
		}
        
        [self setParentScrollViewToDesireContentInsets:parentScrollView forLoaingState:NO];
        
	}
    
}

-(void)parentScrollViewDidEndDragging:(UIScrollView *)parentScrollView{
    
    BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(pullRefreshViewDataSourceIsLoading:)]) {
		_loading = [_delegate pullRefreshViewDataSourceIsLoading:self];
	}
    
    BOOL shouldTriggerLoadEvent = NO;
    if ([_delegate respondsToSelector:@selector(shouldTriggerLoadEvent:)]) {
        shouldTriggerLoadEvent = [_delegate shouldTriggerLoadEvent:self];
    }
    
	if (shouldTriggerLoadEvent && !_loading) {
        
		if ([_delegate respondsToSelector:@selector(pullRefreshViewDidTriggerRefresh:)]) {
			[_delegate pullRefreshViewDidTriggerRefresh:self];
		}
        
		[self setState:GBIPullRefreshViewLoading];
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        
		[self setParentScrollViewToDesireContentInsets:parentScrollView forLoaingState:YES];
        
		[UIView commitAnimations];
        
	}
    
}

-(void)parentScrollViewDidFinishLoading:(UIScrollView *)parentScrollView{

    // !!!Important change state before aniamtion
    [self setState:GBIPullRefreshViewNormal];
    
    BOOL animated = YES;
    
    if (animated) {
        [UIView beginAnimations:@"finishLoadingAnimation" context:nil];
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(animationWillStart:context:)];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.25];
    }
    
    [self setParentScrollViewToDesireContentInsets:parentScrollView forLoaingState:NO];
    
    if (animated) {
        [UIView commitAnimations];
    }
    
//    [self setState:GBIPullRefreshViewNormal];
    
}

#pragma mark - Animation Delegate

-(void)animationWillStart:(NSString *)animationID context:(void *)context{
    
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
}

-(void)refreshView{

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
