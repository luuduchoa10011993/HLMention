#
# Be sure to run `bundle exec pod lib lint HLMention.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

    Pod::Spec.new do |s|
    s.name             = 'HLMention'
    s.version          = '0.1.0'
    s.summary          = 'HLMention help developer to user tag user for textview custom'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = <<-DESC
    The native TextView Editor by HoaLD.
    DESC

    s.homepage         = 'https://github.com/aldhoa/HLMention'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'LUU DUC HOA' => 'luuduchoa10011993@gmail.com' }
    s.source           = { :git => 'https://github.com/aldhoa/HLMention.git', :tag => s.version.to_s }

    s.ios.deployment_target = '13.0'
    s.swift_version = '5.0'
    s.source_files = 'HLMention/HoaLDMentionsTextField/HLMention/HLMentionsTextView.swift'

    end
