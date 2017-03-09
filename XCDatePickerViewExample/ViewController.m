//
//  ViewController.m
//  XCDatePickerViewExample
//
//  Created by 樊小聪 on 2017/3/8.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

#import "ViewController.h"

#import "XCDatePickerView.h"

@interface ViewController ()

@property (assign, nonatomic) XCDateFormatType type;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)chooseTypeAction:(UIButton *)sender
{
    self.type = sender.tag - 100;
}


- (IBAction)show:(UIButton *)sender
{
    [XCDatePickerView showDatePickViewWithDateFormatType:self.type date:NULL maxDate:NULL minDate:NULL didClickEnterHandle:^(NSDate *selectedDate, NSString *selectedDateString) {
        
        NSLog(@"时间:   %@", selectedDateString);
        
        [sender setTitle:selectedDateString forState:UIControlStateNormal];
    }];
}

@end
