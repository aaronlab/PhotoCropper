#
# Be sure to run `pod lib lint DynamicBottomSheet.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PhotoCropper'
  s.version          = '0.3.0'
  s.summary          = 'A simple image crop library for iOS'

  s.description      = <<-DESC
This is a simple image crop library for iOS on Christmas🎅 🎄for fun based on RxSwift,
which doesn't support customized resizing by users.
This would be appropriate when limiting crop rate control to users.
                       DESC

  s.homepage         = 'https://github.com/aaronLab/PhotoCropper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Aaron Lee' => 'aaronlab.net@gmail.com' }
  s.source           = { :git => 'https://github.com/aaronLab/PhotoCropper.git', :tag => s.version.to_s }

  s.requires_arc = true

  s.swift_versions = '5.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'PhotoCropper/Classes/**/*'

  s.dependency 'RxSwift', '~> 6.0'
  s.dependency 'RxCocoa', '~> 6.0'
  s.dependency 'RxGesture', '~> 4.0'
  s.dependency 'SnapKit', '~> 5.0'
  s.dependency 'Then', '~> 2.0'
end
