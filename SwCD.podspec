#
# Be sure to run `pod lib lint SwCD.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SwCD"
  s.version          = "0.1.3"
  s.summary          = "Lightweight CoreData library. written in Swift."
  s.homepage         = "https://github.com/xxxAIRINxxx/SwCD"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Airin" => "xl1138@gmail.com" }
  s.source           = { :git => "https://github.com/xxxAIRINxxx/SwCD.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'SwCD/'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'CoreData'
end
