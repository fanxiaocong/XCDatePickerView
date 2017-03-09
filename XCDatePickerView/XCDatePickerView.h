//
//  XCDatePickerView.h
//
//
//  Created by 樊小聪 on 16/7/7.
//  Copyright © 2016年 Injoinow. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XCDateFormatType)
{
    XCDateFormatTypeHourMinute = 0,   // 时、分 的时间显示方式 13:22
    
    XCDateFormatTypeYearMonthDay,     // 年、月、日 的时间显示方式 2016-06-11
    
    XCDateFormatTypeDateTime,         // 年、月、日、时、分、秒 的显示方式 2016-03-01 11:11:11
    
    XCDateFormatTypeHalfHour,         // 一天之内的时间，每 半小时 间隔
    
    XCDateFormatTypeYear,             //只显示年
    
    XCDateFormatTypeOther,
};

@interface XCDatePickerView : UIView

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
                       didClickEnterHandle:(void(^)(NSDate *selectedDate, NSString *selectedDateString))    didClickEnterHandle;

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
                       didClickEnterHandle:(void(^)(NSDate *selectedDate, NSString *selectedDateString))didClickEnterHandle;

@end










