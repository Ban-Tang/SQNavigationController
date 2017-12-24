#
#  Be sure to run `pod spec lint SQNavigationController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "SQNavigationController"
  s.version      = "0.1"
  s.summary      = "A full screen pop gesture navigaiton controller"
  s.homepage     = "https://coding.net/u/roylee/p/SQNavigationController"

  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Roylee" => "roylee-stillway@163.com" }
  s.platform     = :ios
  s.platform     = :ios, "8.0"

  s.source       = { 
    :git => "https://git.coding.net/roylee/SQNavigationController.git", 
    :tag => "#{s.version}" 
  }
  s.source_files  = "SQNavigationController/SQNavigationController/**/*.{h,m}"
s.public_header_files = "SQNavigationController/SQNavigationController/SQNavigation{Controller,Bar}.h"

  s.requires_arc = true

  # s.dependency 'SQKit', :git => 'https://git.coding.net/roylee/SQKit.git', :tag => '1.0'

end
