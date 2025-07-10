# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'iRefalla' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for iRefalla
  pod 'Alamofire', '~> 4.4'
  pod 'SwiftyJSON'
  pod 'MRProgress'
  pod 'DKImagePickerController'
  pod 'PDFReader', '~> 2.5'
  pod 'Parse'
  pod 'ParseLiveQuery'
  pod 'TKImageShowing'
  pod 'Charts'

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
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "11.0"
    end
  end
end
