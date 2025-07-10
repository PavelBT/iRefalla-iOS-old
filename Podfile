# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'iRefalla' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iRefalla
  pod 'Alamofire', '~> 5.9'
  pod 'SwiftyJSON', '~> 5.0'
  pod 'MRProgress'
  pod 'DKImagePickerController'
  pod 'PDFReader', '~> 2.5.1'
  pod 'Parse', '~> 1.19'
  pod 'ParseLiveQuery', '~> 2.8'
  pod 'TKImageShowing', '~> 1.1'
  pod 'Charts', '~> 4.1'

  target 'iRefallaTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'iRefallaUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"
    end
  end
end
