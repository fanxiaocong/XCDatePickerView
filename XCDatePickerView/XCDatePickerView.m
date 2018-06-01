//
//  XCDatePickerView.m
//  
//
//  Created by 樊小聪 on 16/7/7.
//  Copyright © 2016年 Injoinow. All rights reserved.
//


#import "XCDatePickerView.h"

#import "UIView+XCExtension.h"


#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#define DATE_VIEW_HEIGHT    310     // 弹出框的高度
#define DATE_TOP_BAR_HEIGHT 40      // Top 工具条的高度
#define DURATION            0.3     // 弹出的时间

#define CANCEL_BUTTON_TITLE_COLOR   [UIColor darkTextColor]     // 取消按钮的文字颜色
#define ENTER_BUTTON_TITLE_COLOR    [UIColor orangeColor]       // 确认按钮的文字颜色


@interface XCDatePickerView ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) UIView *maskView;
@property (weak, nonatomic) UIView *contentView;
@property (weak, nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) UIPickerView *pickerView;

@property (copy, nonatomic) void(^didClickEnterHandle)(NSDate *selectedDate, NSString *selectedDateStr);

@property (strong, nonatomic) NSDateFormatter *fmt;
@property (assign, nonatomic) XCDateFormatType dateType;

/** 👀 小时数组（0 至 1000 小时） 👀 */
@property (strong, nonatomic) NSArray *hours;
/** 👀 分钟数组（只有 0 和 30 两个数据） 👀 */
@property (strong, nonatomic) NSArray *minutes;
/** 👀 年份数组 1970 到 当前年份 👀 */
@property (strong, nonatomic) NSMutableArray *years;


/** 👀 选中的时间字符串 👀 */
@property (copy, nonatomic) NSString *selectedDateStr;
/** 👀 选中的小时 👀 */
@property (copy, nonatomic) NSString *selectedHours;
/** 👀 选中的分钟 👀 */
@property (copy, nonatomic) NSString *selectedMinutes;

@end


@implementation XCDatePickerView

#pragma mark - 💤 👀 LazyLoad Method 👀

- (NSArray *)hours
{
    if (!_hours)
    {
        NSMutableArray *mArr = [NSMutableArray array];
        
        for (NSInteger i = 0; i < 1000; i++)
        {
            NSString *str = [NSString stringWithFormat:@"%zi", i];
            [mArr addObject:str];
        }
        
        _hours = mArr;
    }
    
    return _hours;
}

- (NSArray *)minutes
{
    if (_minutes == nil)
    {
        _minutes = @[@"0", @"30"];
    }
    return _minutes;
}


//  ----  年的数组  ----
- (NSMutableArray *)years
{
    if (!_years)
    {
        _years = [NSMutableArray array];
        
        NSInteger currentYear = [self currentYear];
        
        for (NSInteger startYear = 1970; startYear <= currentYear; startYear ++)
        {
            [_years addObject:[NSString stringWithFormat:@"%zi年", startYear]];
        }
    }
    
    return _years;
}

- (NSDateFormatter *)fmt
{
    if (_fmt == nil)
    {
        _fmt = [[NSDateFormatter alloc] init];
    }
    return _fmt;
}


- (UIView *)contentView
{
    if (!_contentView)
    {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, DATE_VIEW_HEIGHT)];
        
        contentView.backgroundColor = [UIColor whiteColor];
        
        // 取消按钮
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(0, 0, 80, DATE_TOP_BAR_HEIGHT);
        [cancelBtn setContentMode:UIViewContentModeCenter];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn setTitleColor:CANCEL_BUTTON_TITLE_COLOR forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        
        // 确定按钮
        UIButton *enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        enterBtn.frame = CGRectMake(SCREEN_WIDTH-80, 0, 80, DATE_TOP_BAR_HEIGHT);
        [enterBtn setTitle:@"确定" forState:UIControlStateNormal];
        enterBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [enterBtn setTitleColor:ENTER_BUTTON_TITLE_COLOR forState:UIControlStateNormal];
        [enterBtn addTarget:self action:@selector(didClickEnterAction) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:cancelBtn];
        [contentView addSubview:enterBtn];
        
        _contentView = contentView;
        [self addSubview:contentView];
    }
    
    return _contentView;
}

- (UIPickerView *)pickerView
{
    if (!_pickerView)
    {
        UIPickerView *pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, DATE_TOP_BAR_HEIGHT, SCREEN_WIDTH, DATE_VIEW_HEIGHT-DATE_TOP_BAR_HEIGHT)];
        pickView.backgroundColor = [UIColor whiteColor];
        pickView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        pickView.layer.borderWidth = 0.5;
        
        _pickerView = pickView;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.hidden = YES;
        
        [self.contentView addSubview:pickView];
    }
    
    return _pickerView;
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker)
    {
        UIDatePicker *datePicker =  [[UIDatePicker alloc] initWithFrame:CGRectMake(0, DATE_TOP_BAR_HEIGHT, SCREEN_WIDTH, DATE_VIEW_HEIGHT-DATE_TOP_BAR_HEIGHT)];
        
        datePicker.backgroundColor   = [UIColor whiteColor];
        datePicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
        datePicker.layer.borderWidth = 0.5;
        
        _datePicker = datePicker;
        
        [self.contentView addSubview:datePicker];
    }
    
    return _datePicker;
}

#pragma mark - 🔓 👀 Public Method 👀

/**
 *  显示一个自定义的 时间选择器
 *
 *  @param dateType            时间显示的类型
 *  @param maxDate             最大时间
 *  @param minDate             最小时间
 *  @param didClickEnterHandle 点击确定按钮的回调
 */
+ (void)showDatePickViewWithDateFormatType:(XCDateFormatType)dateType
                                   maxDate:(NSDate *)maxDate
                                   minDate:(NSDate *)minDate
                       didClickEnterHandle:(void(^)(NSDate *selectedDate, NSString *selectedDateString))    didClickEnterHandle
{
    [self showDatePickViewWithDateFormatType:dateType
                                        date:[NSDate date]
                                     maxDate:maxDate
                                     minDate:minDate
                         didClickEnterHandle:didClickEnterHandle];
}

/**
 *  显示一个自定义的 时间选择器
 *
 *  @param dateType            时间显示的类型
 * @param  date                默认时间
 *  @param maxDate             最大时间
 *  @param minDate             最小时间
 *  @param didClickEnterHandle 点击确定按钮的回调
 */
+ (void)showDatePickViewWithDateFormatType:(XCDateFormatType)dateType
                                      date:(NSDate *)date
                                   maxDate:(NSDate *)maxDate
                                   minDate:(NSDate *)minDate
                       didClickEnterHandle:(void(^)(NSDate *selectedDate, NSString *selectedDateString))didClickEnterHandle
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    // 弹下键盘
    [keyWindow resignFirstResponder];
    
    XCDatePickerView *customView = [[XCDatePickerView alloc] initWithFrame:keyWindow.bounds];
    
    customView.backgroundColor = [UIColor clearColor];
    [keyWindow addSubview:customView];
    
    customView.dateType = dateType;
    
    customView.didClickEnterHandle = didClickEnterHandle;
    
    customView.datePicker.date = date ?: [NSDate date];
    customView.datePicker.minimumDate = minDate;
    customView.datePicker.maximumDate = maxDate;
    
    switch (dateType)
    {
        case XCDateFormatTypeHourMinute:
        {
            customView.datePicker.datePickerMode = UIDatePickerModeTime;
            customView.fmt.dateFormat = @"HH:mm";
            break;
        }
        case XCDateFormatTypeYearMonthDay:
        {
            customView.datePicker.datePickerMode = UIDatePickerModeDate;
            customView.fmt.dateFormat = @"yyyy-MM-dd";
            break;
        }
        case XCDateFormatTypeDateTime:
        {
            customView.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            customView.fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            break;
        }
        case XCDateFormatTypeHalfHour:
        {
            customView.datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
            customView.datePicker.minuteInterval = 30;
            customView.fmt.dateFormat = @"H小时 m分钟";
            customView.datePicker.date = [customView currentBeginDate];

            break;
        }
        case XCDateFormatTypeYear:
        {
            customView.datePicker.hidden = YES;
            customView.pickerView.hidden = NO;
            NSMutableString * yearStr = [NSMutableString stringWithString:customView.years[0]];
            [yearStr deleteCharactersInRange:NSMakeRange(yearStr.length - 1, 1)];
            customView.selectedDateStr = yearStr;
            break;
        }
        case XCDateFormatTypeOther:
        {
            customView.datePicker.hidden = YES;
            customView.pickerView.hidden = NO;
            NSString *defaultsHour     = customView.hours.firstObject;
            NSString *defaultMinutes   = customView.minutes.firstObject;
            customView.selectedDateStr = [NSString stringWithFormat:@"%.1f", (defaultsHour.integerValue + defaultMinutes.floatValue / 60)];
            break;
        }
    }
    
    UIView *maskView = [[UIView alloc] initWithFrame:customView.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0;
    [customView insertSubview:maskView belowSubview:customView.contentView];
    
    customView.maskView = maskView;
    
    // 点击了蒙板
    [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:customView action:@selector(hide)]];
    
    [customView show];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 点击了确定按钮的回调
 */
- (void)didClickEnterAction
{
    NSString *timeDate = nil;
    NSDate   *date = nil;
    
    switch (self.dateType)
    {
        case XCDateFormatTypeOther:
        case XCDateFormatTypeYear:
        {
            timeDate = self.selectedDateStr;
            break;
        }
        default:
        {
            date = self.datePicker.date;
            
            if ([date compare:self.datePicker.minimumDate] == NSOrderedAscending)   // 如果当前时间 小于 最小时间，则取 最小时间
            {
                date = self.datePicker.minimumDate;
            }
            
            if ([date compare:self.datePicker.maximumDate] == NSOrderedDescending)  // 如果当前时间 大于 最大时间，则取 最大时间
            {
                date = self.datePicker.maximumDate;
            }
            
            timeDate = [self timeWithFormattersString:self.fmt.dateFormat timeDate:date];
            
            break;
        }
    }
    
    // 点击确定按钮
    if (self.didClickEnterHandle)
    {
        self.didClickEnterHandle(date, timeDate);
    }
    
    [self hide];
}

/**
 弹出
 */
- (void)show
{
    [UIView animateWithDuration:DURATION animations:^{
        
        self.maskView.alpha = 0.4;
        self.contentView.top = SCREEN_HEIGHT - self.contentView.height;
        
    } completion:NULL];
}

/**
 隐藏
 */
- (void)hide
{
    [UIView animateWithDuration:.2 animations:^{
        
        self.maskView.alpha = 0;
        self.contentView.top = SCREEN_HEIGHT;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 将时间转换成指定格式的字符串

 @param format 字符串格式
 @param date 要转换的时间
 */
- (NSString *)timeWithFormattersString:(NSString *)format timeDate:(NSDate *)date
{
    // 实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    
    [dateFormat setDateFormat:format];//设定时间格式
    
    return [dateFormat stringFromDate:date];
}


/**
 返回当前的年份
 */
- (NSInteger)currentYear
{
    NSString *currentYear = [self timeWithFormattersString:@"yyyy" timeDate:[NSDate date]];
    
    return currentYear.integerValue;
}

- (NSDate *)currentBeginDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned flags = NSCalendarUnitYear |
    NSCalendarUnitMonth |
    NSCalendarUnitWeekday|
    NSCalendarUnitDay |
    NSCalendarUnitHour |
    NSCalendarUnitMinute |
    NSCalendarUnitSecond |
    NSCalendarUnitWeekdayOrdinal;
    
    NSDateComponents *components = [calendar components:flags fromDate:[NSDate date]];
    
    [components setSecond:0];
    [components setMinute:30];
    [components setHour:0];
    
    return [calendar dateFromComponents:components];
}

#pragma mark -- UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.dateType == XCDateFormatTypeYear)
    {
        return 1;
    }
    else
    {
        return 4;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.dateType == XCDateFormatTypeYear)
    {
        return self.years.count;
    }
    else
    {
        if (component == 1 || component == 3) return 1;
        
        if (component == 2) return self.minutes.count;
        
        return self.hours.count;
    }
}

#pragma mark -- UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.dateType == XCDateFormatTypeYear)
    {
        return self.years[row];
    }
    else
    {
        if (component == 1)     return @"小时";
        
        if (component == 3)     return @"分钟";
        
        if (component == 2)     return self.minutes[row];
        
        return self.hours[row];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.dateType == XCDateFormatTypeYear)
    {
        NSMutableString * yearStr = [NSMutableString stringWithString:self.years[row]];
        [yearStr deleteCharactersInRange:NSMakeRange(yearStr.length - 1, 1)];
        self.selectedDateStr = yearStr;
        return;
    }

    if (component == 0)
    {
        self.selectedHours = self.hours[row];
    }
    
    if (component == 2)
    {
        self.selectedMinutes = self.minutes[row];
    }
    
    self.selectedDateStr = [NSString stringWithFormat:@"%.1f", (self.selectedHours.integerValue + self.selectedMinutes.floatValue / 60)];
}

@end


