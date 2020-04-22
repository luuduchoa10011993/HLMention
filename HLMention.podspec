#
# Be sure to run `bundle exec pod lib lint HLMention.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HLMention"
  s.version          = "0.1.0"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage         = "https://github.com/aldhoa/HLMention"
  s.author           = { 'LUU DUC HOA' => 'luuduchoa10011993@gmail.com' }
  s.summary          = "HLMention help developer to user tag user for textview custom for iOS"
  s.source           = { :git => "https://github.com/aldhoa/HLMention.git", :tag => s.version }
  s.social_media_url = ''

  s.platform     = :ios, '13.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resources = 'Pod/Assets/*'

  s.frameworks = 'UIKit'
  s.module_name = 'HLMention'
end
