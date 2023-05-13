# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Weather' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Weather

  #Networking
  pod 'Moya/RxSwift'

  #Rx
  pod 'RxSwift'
  pod 'RxCocoa'
  
  #Loading Images
  pod 'Nuke'
  
  #loading indicator
  pod 'ProgressHUD'
  
  #Database
  pod 'GRDB.swift'
  
  # ignore all warnings from all pods
  inhibit_all_warnings!

  target 'WeatherTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'WeatherUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
