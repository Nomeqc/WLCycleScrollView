#
# Be sure to run `pod lib lint WLCycleScrollView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WLCycleScrollView'
  s.version          = '1.0.1'
  s.summary          = '简单易用的、灵活易扩展的循环滚动视图'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    简单易用的灵活的滚动视图
  DESC

  s.homepage         = 'https://github.com/Nomeqc/WLCycleScrollView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Fallrainy' => 'xie5405@163.com' }
  s.source           = { :git => 'https://github.com/Nomeqc/WLCycleScrollView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'WLCycleScrollView/Classes/**/*'
end
