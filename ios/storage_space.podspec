#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint storage_space.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'storage_space'
  s.version          = '1.4.0'
  s.summary          = 'Get the free, available and total storage space for the device.'
  s.description      = <<-DESC
Get the free, available and total storage space for the device, plus the storage used by the app itself.
                       DESC
  s.homepage         = 'https://github.com/flowmobile/storage_space'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'flowmobile'
  s.source           = { :path => '.' }
  s.source_files = 'storage_space/Sources/storage_space/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Declares the disk space required reason APIs this plugin uses.
  s.resource_bundles = {'storage_space_privacy' => ['storage_space/Sources/storage_space/PrivacyInfo.xcprivacy']}
end
