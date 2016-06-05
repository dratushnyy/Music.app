//
//  LoadingViewController.m
//  Music
//
//  Created by Dmitry Ratushnyy on 26/11/15.
//
#import "LoadingViewController.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (id) initWithFrame:(CGRect)initFrame {
    self = [super init];
    if(self){
        self.frame = initFrame;
        self.view.frame = initFrame;
    }
    return self;
}

- (void) loadView {
    [super loadView];
    CGRect rect = CGRectMake(0, 0, 200, 100);

    self.container = [[UIView alloc] initWithFrame:rect];
    UIColor * bgColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    self.container.backgroundColor = bgColor;
    self.container.layer.cornerRadius = 6;
    self.activityLabel = [[UILabel alloc] init];
    self.activityLabel.text = @"Loading";
    self.activityLabel.textColor = [UIColor grayColor];
    self.activityLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.container addSubview:self.activityLabel];
    self.activityLabel.frame = CGRectMake(60, 10, 200, 25);
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.container addSubview:self.activityIndicator];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    self.activityIndicator.frame = CGRectMake(80, 60, 30, 30);
    
    [self.view addSubview:self.container];
    self.container.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);

}
- (void)viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

- (void)viewWillDisappear:(BOOL) animated {
    [super viewWillDisappear:animated];
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

@end
