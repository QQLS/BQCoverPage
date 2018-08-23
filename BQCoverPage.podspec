#
# Be sure to run `pod lib lint BQCoverPage.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BQCoverPage'
  s.version          = '0.1.0'
  s.summary          = 'A top tab contain some of controller.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  The controller contain the third pary. Top is cover, center is tab, bottom is sub controller.
                       DESC

  s.homepage         = 'https://github.com/QQLS/BQCoverPage'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'QQLS' => '702166055@qq.com' }
  s.source           = { :git => 'https://github.com/QQLS/BQCoverPage.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  ## swift_version need before deployment_target.
  # related platform
  s.platform = :ios
  # dependency Swift version.
  s.swift_version = '4.0'
  
  s.ios.deployment_target = '8.0'

  s.source_files = 'BQCoverPage/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BQCoverPage' => ['BQCoverPage/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
