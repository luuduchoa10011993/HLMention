Pod::Spec.new do |s|
  s.name             = 'HLMention'
  s.version          = '0.1.0'
  s.summary          = 'By far the most fantastic view I have seen in my entire life. No joke.'
 
  s.description      = <<-DESC
This fantastic view changes its color gradually makes your app look fantastic!
                       DESC
 
  s.homepage         = 'https://github.com/aldhoa/HLMention'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LUU DUC HOA' => 'luuduchoa10011993@gmail.com' }
  s.source           = { :git => 'https://github.com/aldhoa/HLMention.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '13.0'
  s.source_files = 'HLMention/HLMention.swift'
 
end
