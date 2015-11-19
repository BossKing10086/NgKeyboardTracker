//
//  ViewController.m
//  NgKeyboardTrackerDemo
//
//  Created by Meiwin Fu on 29/6/15.
//  Copyright (c) 2015 Meiwin Fu. All rights reserved.
//

#import "ViewController.h"
#import "NgKeyboardTracker.h"

NSString * DescriptionFromKeyboardTracker(NgKeyboardTracker * tracker) {
  return [NSString stringWithFormat:@"[%@]\n%@\nvisible: %@"
          , NgAppearanceStateAsString(tracker.appearanceState)
          , NSStringFromCGRect(tracker.currentFrame)
          , [tracker isKeyboardVisible] ? @"YES" : @"NO" ];
}

@interface LayoutView : UIView <NgKeyboardTrackerDelegate>
@property (nonatomic, strong, readonly) UITextView * textView;
@property (nonatomic, strong, readonly) UIScrollView * scrollView;
@property (nonatomic, strong, readonly) UILabel * label;
@property (nonatomic, strong, readonly) UIButton * button;
@property (nonatomic, strong, readonly) NgPseudoInputAccessoryViewCoordinator * coordinator;
@end

@implementation LayoutView
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupViews];
    
    _coordinator = [[NgKeyboardTracker sharedTracker] createPseudoInputAccessoryViewCoordinator];
    [_coordinator setPseudoInputAccessoryViewHeight:44.f];
    
    [[NgKeyboardTracker sharedTracker] addDelegate:self];
  }
  return self;
}
- (void)dealloc {

  [[NgKeyboardTracker sharedTracker] removeDelegate:self];
}
- (BOOL)canBecomeFirstResponder {
  return YES;
}
- (UIView *)inputAccessoryView {
  return _coordinator.pseudoInputAccessoryView;
}
- (void)setupViews {
  _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
  _scrollView.backgroundColor = [UIColor whiteColor];
  _scrollView.alwaysBounceVertical = YES;
  _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
  [self addSubview:_scrollView];
  
  _textView = [[UITextView alloc] init];
  _textView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1.f];
  _textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
  _textView.font = [UIFont systemFontOfSize:17];
  [self addSubview:_textView];
  
  UIView * border = [UIView new];
  border.tag = 1000;
  border.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.f];
  [_textView addSubview:border];
  
  _button = [UIButton buttonWithType:UIButtonTypeSystem];
  [_button setTitle:@"Dismiss Keyboard" forState:UIControlStateNormal];
  [_button sizeToFit];
  [_scrollView addSubview:_button];
  
  _label = [UILabel new];
  _label.font = [UIFont systemFontOfSize:16];
  _label.numberOfLines = 3;
  _label.textAlignment = NSTextAlignmentCenter;
  [_scrollView addSubview:_label];
}
- (void)layoutTextView {
  
  CGRect kbframe = [[NgKeyboardTracker sharedTracker] keyboardCurrentFrameForView:self];
  CGSize s = self.frame.size;
  CGFloat textViewH = _coordinator.pseudoInputAccessoryViewHeight;
  CGFloat bottomPadding = -textViewH;
  
  if (!CGRectEqualToRect(CGRectZero, kbframe)) {
    bottomPadding += ( s.height - kbframe.origin.y );
  }

  bottomPadding = MAX(0, bottomPadding);
  
  _textView.frame = (CGRect) {
    0,
    s.height - textViewH - bottomPadding,
    s.width,
    textViewH
  };

  UIView * border = [_textView viewWithTag:1000];
  border.frame = (CGRect) { 0, 0, _textView.frame.size.width, .6 };
  
  [_coordinator setPseudoInputAccessoryViewHeight:textViewH];
}
- (void)layoutSubviews {
  
  [super layoutSubviews];
  
  CGSize s = self.frame.size;
  _scrollView.frame = self.bounds;
  _scrollView.contentSize = s;

  [self layoutTextView];
  
  _button.frame = (CGRect) {
    30,
    60,
    s.width - 60,
    30
  };
  
  _label.frame = (CGRect) {
    30,
    120,
    s.width - 60,
    60
  };
  
}
- (void)keyboardTrackerDidUpdate:(NgKeyboardTracker *)tracker {
  [self layoutTextView];
}
- (void)keyboardTrackerDidChangeAppearanceState:(NgKeyboardTracker *)tracker {
  _label.text = DescriptionFromKeyboardTracker(tracker);
  [self layoutTextView];
}
@end

@interface ViewController () <NgKeyboardTrackerDelegate>
@property (nonatomic, strong, readonly) LayoutView * layoutView;
@end

@implementation ViewController

- (void)loadView {
  [super loadView];
  
  _layoutView = [[LayoutView alloc] initWithFrame:self.view.bounds];
  _layoutView.autoresizingMask = ~UIViewAutoresizingNone;
  self.view = _layoutView;
  [_layoutView becomeFirstResponder];
}
- (void)viewDidLoad {
  [super viewDidLoad];

  [_layoutView.button addTarget:self action:@selector(onButtonTap:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // uncomment following codes to change textView's height
  /*
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    _layoutView.coordinator.pseudoInputAccessoryViewHeight = 88.f;
  });
  */
}
- (void)onButtonTap:(id)sender {
  [_layoutView.textView resignFirstResponder];
}

@end
