//
//  APPChildViewController.m
//  PageApp
//
//  Created by Rafael Garcia Leiva on 10/06/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import "APPChildViewController.h"

@interface APPChildViewController ()

@end

@implementation APPChildViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.screenNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].applicationFrame.size.width, 60)];
    self.screenNumber.text = [NSString stringWithFormat:@"Screen #%ld", (long)self.index];
    [self.view addSubview:self.screenNumber];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
