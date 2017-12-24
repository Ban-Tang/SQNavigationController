#
#  Be sure to run `pod spec lint UIViewController+NavigaitonBar.podspec' to ensure this is a
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

  s.name         = "UIViewController+SQNavigaitonBar"
  s.version      = "0.1"
  s.summary      = "Easy config for UINavigaitonBar bar button." // 目前是针对 SQNavigaitonController 的封装

  s.homepage     = "https://coding.net/u/roylee/p/UIViewController-NavigationBar"
  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Roylee" => "roylee-stillway@163.com" }

  s.platform     = :ios, "8.0"


  s.source       = { :git => "https://git.coding.net/roylee/UIViewController-NavigationBar.git", :tag => "#{s.version}" }
  s.source_files  = "UIViewController-NavigaitonBar/Utility/**/*.{h,m}"
  s.public_header_files = "UIViewController-NavigaitonBar/Utility/**/*.h"

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency 'SQNavigationController', :git => 'https://git.coding.net/roylee/SQNavigationController.git', :tag => '0.1'

end
