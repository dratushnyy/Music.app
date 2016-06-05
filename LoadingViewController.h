//
//  LoadingViewController.h
//  Music
//
//  Created by Dmitry Ratushnyy on 26/11/15.
//

#import <UIKit/UIKit.h>

@interface LoadingViewController : UIViewController
    @property (nonatomic) UILabel *activityLabel;
    @property (nonatomic) UIActivityIndicatorView *activityIndicator;
    @property (nonatomic) UIView *container;
    @property (nonatomic) CGRect frame;

- (id) initWithFrame:(CGRect) initFrame;
@end
