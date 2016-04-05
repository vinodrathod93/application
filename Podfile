# Uncomment this line to define a global platform for your project
#"platforms": {
#    "iOS": "8.0",
#    "watchos": "2.0"
#}

source 'https://github.com/CocoaPods/Specs.git'



#use_frameworks!

def shared_pods
    pod 'AFNetworking'
    pod 'Mantle'
end


target 'Neediator' do
    platform :ios, '8.1'
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
    
    pod 'GoogleMaps'
    
    pod 'SVPullToRefresh'
    pod 'Google/Analytics'
end


#target 'Neediator-AppleWatch Extension' do
#
#    platform :watchos, '2.0'
#    shared_pods
#end


target 'NeediatorTests' do

end

#link_with 'Neediator', 'Neediator-AppleWatch Extension'
