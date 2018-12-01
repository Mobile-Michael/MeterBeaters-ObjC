#import "Toast.h"

@interface ToastView ()
@property (strong, nonatomic, readonly) UILabel *textLabel;
@end
@implementation ToastView
@synthesize textLabel = _textLabel;

CGFloat const ToastHeight = 35.0f;
CGFloat const ToastGap = 2.5f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(UILabel *)textLabel
{
    if (!_textLabel)
    {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, self.frame.size.width - 10.0, self.frame.size.height - 10.0)];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.numberOfLines = 2;
        _textLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [_textLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:24]];
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:_textLabel];
        
    }
    
    return _textLabel;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [_text uppercaseString];
    self.textLabel.text = text;
}

+ (void)showToastInParentView: (UIView *)parentView withText:(NSString *)text withDuaration:(CGFloat)duration;
{
    
    //Count toast views are already showing on parent. Made to show several toasts one above another
    NSInteger toastsAlreadyInParent = 0;
    for (UIView *subView in [parentView subviews]) {
        if ([subView isKindOfClass:[ToastView class]])
        {
            toastsAlreadyInParent++;
        }
    }
    
    if( toastsAlreadyInParent > 5)
    {
        return;
    }
    
    CGRect parentFrame = parentView.frame;
    CGFloat fMiddle = parentFrame.size.height / 2.0f;
    CGFloat fMoveIt = (fMiddle + ToastHeight * toastsAlreadyInParent + ToastGap * toastsAlreadyInParent);
    CGFloat yOrigin = parentFrame.size.height - fMoveIt;
    
    
    CGRect selfFrame = CGRectMake(parentFrame.origin.x + 20.0, yOrigin, parentFrame.size.width - 40.0, ToastHeight);
    ToastView *toast = [[ToastView alloc] initWithFrame:selfFrame];
    
    toast.backgroundColor = [UIColor clearColor];
    toast.alpha = 0.0f;
    toast.layer.cornerRadius = 4.0;
    toast.text =  [text uppercaseString];
    
    [parentView addSubview:toast];
    
    [UIView animateWithDuration:0.4 animations:^{
        toast.alpha = 0.9f;
        toast.textLabel.alpha = 0.9f;
    }completion:^(BOOL finished) {
        if(finished){
            
        }
    }];
    
    
    [toast performSelector:@selector(hideSelf) withObject:nil afterDelay:duration];
    
}

- (void)hideSelf
{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
        self.textLabel.alpha = 0.0;
    }completion:^(BOOL finished) {
        if(finished){
            [self removeFromSuperview];
        }
    }];
}

@end
