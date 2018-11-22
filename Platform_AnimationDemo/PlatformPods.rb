# PLEASE READ THIS BEFORE EDITING.
# WARNING - If adding a new pod, please check to see if it causes an issue and correct this in the configure_pods section at the bottom!
# See the confluence guide for more details - https://poqcommerce.atlassian.net/wiki/spaces/EN/pages/311492863/Cocoapods+Implementation

def bag_pods
    # PoqCart
    pod 'ReSwift', '4.0.1'
    pod 'Cartography', '3.0.1'
end

def analytics_pods
    # Tracking
    pod 'Firebase/Core', '4.10.0'
    pod 'Firebase/Performance', '4.10.0'
    pod 'FirebaseSwizzlingUtilities', '1.0.0'
end

def moduling_pods
    # Operational
    pod 'ObjectMapper', '3.3.0'
end

def networking_pods
    # Operational
    pod 'HanekeSwift', :git => 'https://github.com/poqcommerce/HanekeSwift.git', :branch => 'feature/swift-3'
    pod 'ObjectMapper', '3.3.0'

    # Security
    pod 'Locksmith', '4.0.0'
end

def platform_pods
    # User Interface - Elements
    pod 'AZDropdownMenu', :git => 'https://github.com/poqcommerce/AZDropdownMenu.git', :branch => 'swift-3.0'

    # User Interface - Loading / Progress Indication
    pod 'NVActivityIndicatorView', '3.2' # 28 types of loading indicator
    pod 'SVProgressHUD', :git => 'https://github.com/poqcommerce/SVProgressHUD.git' # progress indicator

    # User Interface - Functional Features
    pod 'DBPrivacyHelper', :git => 'https://github.com/poqcommerce/DBPrivacyHelper.git' #permission handling
    pod 'IDMPhotoBrowser', :git => 'https://github.com/poqcommerce/IDMPhotoBrowser.git'
    pod 'Koloda', '~> 4.3.1'
    pod 'RSBarcodes_Swift' , :git => 'https://github.com/poqcommerce/RSBarcodes_Swift.git', :branch => 'Swift-3.0' # Barcode, QRCode generator/scan

    # Operational
    pod 'Bolts-Swift', '1.3.0'
    pod 'HanekeSwift', :git => 'https://github.com/poqcommerce/HanekeSwift.git', :branch => 'feature/swift-3'
    pod 'ObjectMapper', '3.3.0'

    # Payment
    pod 'Braintree', '4.11.0'
    pod 'Braintree/Apple-Pay', '4.11.0'
    pod 'Braintree/PaymentFlow', '4.11.0'
    pod 'Stripe', '12.1.1'
    
    # Security
    pod 'Locksmith', '4.0.0'
    
    # Social
    pod 'FacebookCore', '0.3.1' #swift sdk
    pod 'FacebookLogin', '0.3.1' #swift sdk

    # Storage
    pod 'RealmSwift', '2.10.0'

    # Tracking
    pod 'Fabric' , '1.7.2'
    pod 'Firebase/Core', '4.10.0'
    pod 'Firebase/Performance', '4.10.0'
    pod 'GoogleAnalytics', '3.17.0'

end

def urban_airship_pods
    pod 'UrbanAirship-iOS-SDK', '9.2.0'
end

def utilities_pods
    # Security
    pod 'Locksmith', '4.0.0'

    # Tracking
    pod 'Crashlytics', '3.9.3'
    pod 'Fabric' , '1.7.2'

    # Tooling
    pod 'SwiftLint', '0.24.0', :configurations => ['Debug']
end

def all_pods
    analytics_pods
    moduling_pods
    networking_pods
    platform_pods
    urban_airship_pods
    utilities_pods
    bag_pods
end

def podify_platform_target(name, &inner_handler)
    project_path = File.dirname(__FILE__) + '/Poq.iOS.Platform.xcodeproj'
    target name do
        project project_path unless project_path.nil?
        inherit! :search_paths
        yield if block_given?
    end
end

def podify_platform_app(name, &inner_handler)
    podify_platform_target name do
        all_pods
        yield if block_given?

        puts "Adding Calabash to #{name} for Calabash configuration"
        pod 'Calabash', :configurations => ['Calabash']

        notification_extension_target_name = "#{name}-NotificationExtension"
        target notification_extension_target_name do
            inherit! :search_paths
            pods_for_target notification_extension_target_name
        end
    end
end

def podify_platform_unit_tests(name, &inner_handler)
    unit_tests_target_name = "#{name}-UnitTests"
    target unit_tests_target_name do
        inherit! :search_paths
        pods_for_target unit_tests_target_name
        yield if block_given?
    end
end

# Sets up all targets in the platform and allows for a custom handler which is called inheriting from the PoqPlatform target.
# All poq framework targets inherit from the PoqModuling target.
def podify_platform(&inner_handler)
    podify_platform_target 'PoqUtilities' do
        utilities_pods

        podify_platform_target 'PoqModuling' do
            moduling_pods

            podify_platform_target 'PoqAnalytics' do
                analytics_pods

                podify_platform_target 'PoqUrbanAirship' do
                    urban_airship_pods
                end
            end

            podify_platform_target 'PoqNetworking' do
                networking_pods
            end


            podify_platform_target 'PoqPlatform' do
                platform_pods

	    	podify_platform_target 'PoqCart' do
                  bag_pods
            	end

                podify_platform_app 'PoqDemoApp' do
                    podify_platform_unit_tests 'PoqAnalytics'
                    podify_platform_unit_tests 'PoqModuling'
                    podify_platform_unit_tests 'PoqNetworking'
                    podify_platform_unit_tests 'PoqPlatform'
                    podify_platform_unit_tests 'PoqUtilities'
                    podify_platform_unit_tests 'PoqCart'

                    target 'PoqDemoApp-EGTests' do
                        inherit! :search_paths
                        pods_for_target 'PoqDemoApp-EGTests'
                    end
                end
    
                podify_platform_app 'PoqDemoApp-InHouseUAT'

                yield if block_given?
            end
        end
    end
end

# Defines pods for a target based on the target name specified. E.g. adds swifter to tests...
def pods_for_target(name)
    if name.match(/.*NotificationExtension/)
        puts "Adding UrbanAirship extension pod to #{name}"
        pod 'UrbanAirship-iOS-AppExtensions'
    end

    if name.match(/.*Tests/)
        puts "Adding Swifter to #{name}"
        pod 'Swifter', '~> 1.3.3'
    end

    if name.match(/.*EGTests/)
        puts "Adding EarlGrey to #{name}"
        pod 'EarlGrey', '~> 1.12.0'
    end
end

# Adds all pods needed to the project at the specific project path (handles Tests, EarlGrey, Calabash and Notification Extensions).
# can take a block / lambda / function as the last parameter which should be defined as `handler = labda do |target|`.
# This handler allows the project to customize its pods.
def podify_project(project_path, &inner_handler)
    project = Xcodeproj::Project.open(project_path)
    project.native_targets.each do |target|
        target target.name do
            project project_path
            inherit! :search_paths

            unless target.extension_target_type?
                puts "Adding all pods to #{target.name}"
                all_pods
            end

            if target.product_type == 'com.apple.product-type.application' && target.build_settings("Calabash")
                puts "Adding Calabash to #{target.name} for Calabash configuration"
                pod 'Calabash', :configurations => ['Calabash']
            end

            pods_for_target(target.name)
            yield(target) if block_given?
        end
    end
end

# Adds all pods needed to platform and client at the specific project path.
# Can take a block / lambda / function as the last parameter which should be defined as `handler = labda do |target|`.
# This handler allows the client to customize its clients pods.
def podify_client(project_path, &inner_handler)
    podify_platform_handler = lambda do
        podify_project project_path do |target|
            yield(target) if block_given?
        end
    end

    podify_platform do
        podify_platform_handler.call
    end
end

# Configures all new pod targets to match generation settings.
# Also clears up all static framework and library duplicates by editing the xcconfig files here.
def configure_pods
    post_install do |installer|
        # Due to an issue with cocoapods, objc frameworks get duplicated causes slow start times and static scope issues:
        # - https://github.com/CocoaPods/CocoaPods/issues/5768
        # - https://stackoverflow.com/questions/46932341/class-is-implemented-in-both-one-of-the-two-will-be-used-which-one-is-undefine
        # We should maintain the below code whenever a pod is added!!!

        # To fix this issue we must remove duplicates from all but their specific target; they are still linked to all targets but not copied.
        # We loop through every cocoapod aggregate target to correct each target by removing specific objc frameworks.
        installer.aggregate_targets.each do |target|
            next unless target.name.match(/Pods-.*/)

            # We loop through every configuration of that target (calabash, debug, release).
            target.xcconfigs.each do |config_name, config_file|
                # We correct the specifically problematic frameworks by removing them from all except their correct targets.
                unless target.name == 'Pods-PoqAnalytics'
                    config_file.frameworks.delete_if { |f| f =~ /Firebase.*/ }
                    config_file.frameworks.delete('GTMSessionFetcher')
                    config_file.frameworks.delete('GoogleToolboxForMac')
                end

                unless target.name == 'Pods-PoqPlatform'
                    config_file.libraries.delete('GoogleAnalytics')
                end

                unless target.name == 'Pods-PoqUtilities'
                    config_file.frameworks.delete('Crashlytics')
                    config_file.frameworks.delete('Fabric')
                end
                
                # Finally we save the configuration to make the changes permanent.
                config_path = target.xcconfig_path(config_name)
                config_file.save_as(config_path)
            end
        end

        # Frameworks MUST follow apps settings
        installer.pods_project.targets.each do |target|
            pod_version = '3.0'
            pod_version = '4.1' if target.name =~ /Facebook.*/
            pod_version = '4.0' if target.name == 'Cartography'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = pod_version
                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
            
            puts "Completed #{target.name}"
        end
    
        ENV["COCOAPODS_DISABLE_STATS"] = "true"
    end
end

# One lane to rule them all, one lane to find them; one lane to bring them all and in the darkness bind them.
def podify(project_name, &inner_handler)
    # Only doing the platform bit here instead of in podify_platform for backwards compatibility.
    platform :ios, '11.0'
    use_frameworks!

    workspace "#{project_name}.xcworkspace"
    if project_name == 'Poq.iOS.Platform'
        # Handle the platform separately as its all the same project file.
        podify_platform
    else
        # Podify the client project.
        podify_client "#{project_name}.xcodeproj" do |target|
            yield(target) if block_given?
        end
    end
    configure_pods
end
