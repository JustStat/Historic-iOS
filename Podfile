platform :ios, '9.0'

target 'Historic' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Historic
  pod 'AnimatedCollectionViewLayout'
  pod 'GoogleMaps'
  pod 'SwiftyJSON'
  pod 'SDWebImage'
  pod 'SwiftSpinner'
  pod 'RealmSwift'
  pod 'Agrume'
  pod 'DropDown'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
