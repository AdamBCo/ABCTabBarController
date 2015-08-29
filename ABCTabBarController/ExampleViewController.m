//
//  ExampleViewController.m
//  ABCTabBarController
//
//  Created by Adam Cooper on 8/29/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import "ExampleViewController.h"

@interface ExampleViewController ()

@end

@implementation ExampleViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.screenNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].applicationFrame.size.width, 60)];
    [self.screenNumber setTextAlignment:NSTextAlignmentCenter];
    self.screenNumber.text = [NSString stringWithFormat:@"ViewController #%ld", (long)self.index];
    [self.view addSubview:self.screenNumber];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
