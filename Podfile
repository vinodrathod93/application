# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'


def shared_pods
    pod 'AFNetworking'
    pod 'Mantle'
end


target 'Neediator' do

    shared_pods
    
    pod 'SDWebImage', '~>3.7'
    pod 'MBProgressHUD', '~> 0.9.1'
    pod 'XLForm', '~> 3.0.0'
    pod 'libPhoneNumber-iOS', '~> 0.8'
    pod 'Realm'
    pod 'SLExpandableTableView'
    pod 'MWPhotoBrowser'
    pod 'pop'
    pod 'RMPZoomTransitionAnimator'
    pod 'Appirater'
    pod 'DIDatepicker'
    
    source 'https://github.com/CocoaPods/Specs.git'
    platform :ios, '8.1'
    pod 'GoogleMaps'
    
    pod 'SVPullToRefresh'
    pod 'Google/Analytics'
end


target 'Neediator-AppleWatch' do
    shared_pods
end


target 'NeediatorTests' do

end

post_install do |add_app_extension_macro|
    add_app_extension_macro.pods_project.targets.each do |target|
        if target.name.include?("Pods-Neediator-AppleWatch")
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'AF_APP_EXTENSIONS=1']
            end
        end
    end
end

