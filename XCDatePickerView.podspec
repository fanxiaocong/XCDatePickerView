
Pod::Spec.new do |s|

  s.name         = "XCDatePickerView"
  s.version      = "1.0.1"
  s.summary      = "DatePickerView"

  s.description  = "DatePickerView自定义时间筛选控件"

  s.homepage     = "https://github.com/fanxiaocong/XCDatePickerView"

  s.license      = "MIT"


  s.author       = { "樊小聪" => "1016697223@qq.com" }


  s.source       = { :git => "https://github.com/fanxiaocong/XCDatePickerView.git", :tag => s.version }


  s.source_files  = "XCDatePickerView"
  s.requires_arc = true
  s.platform     = :ios, "8.0"
  s.frameworks   =  'UIKit'

end

