{
    'targets': [
        {
            'variables': {
                'target_name': 'PoqDemoApp',
                'bundle_id': 'com.poq.poqdemoapp',
            },

            'includes': ['Templates/Targets/Application.gypi'],

            'xcode_settings': {
                'INFOPLIST_FILE': 'PoqDemoApp/SupportFiles/PoqDemoApp-Info.plist',
                'ASSETCATALOG_COMPILER_APPICON_NAME': 'PoqDemoApp-AppIcon',
            },

            'mac_framework_headers': [
                '../PoqPlatform/SupportFiles/PoqPlatform.h',
            ],

            'sources': [
                '<!@(find ./PoqDemoApp/Sources -name *.swift -o -name *.h)',
            ],

            'link_settings': {
                'libraries': [
                    '$(BUILT_PRODUCTS_DIR)/PoqUrbanAirship.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqCart.framework'
                ],
            },

            'mac_bundle_resources': [
                '<!@(find ./PoqDemoApp/Resources -name *.storyboard -o -name *.xib -o -name *.xcassets -o -name *.xcdatamodel -o -name *.otf -o -name *.ttf -o -name *.strings -o -name *.bundle)',
                '<!@(find ./PoqDemoApp/SupportFiles/Production -iname *.plist)',
                '<!@(find ./PoqDemoApp/SupportFiles -iname *.json)', 
            ],

            'copies': [
                {
                    'destination': '<(PRODUCT_DIR)/<(target_name).app/PlugIns',
                    'files': [ '<(PRODUCT_DIR)/<(target_name)-NotificationExtension.appex' ]
                }
            ],

            'postbuilds': [
                {
                    'postbuild_name': 'Embed Client Frameworks',
                    'inputs': [],
                    'outputs': [],
                    'action': ['sh', '${SRCROOT}/Generation/Scripts/CopyFramework.sh', 'PoqUrbanAirship.framework', 'PoqCart.framework'],
                },
            ],

            'dependencies': [ '<(target_name)-NotificationExtension' ],
        },
        {
            'variables': {
                'product_name': 'PoqDemoApp',
                'product_id': 'com.poq.poqdemoapp'
            },

            'includes': ['Templates/Targets/NotificationExtension.gypi'],
        },

        {
            'variables': {
                'target_name': 'PoqDemoApp-InHouseUAT',
                'bundle_id': 'com.poq.poqdemoapp-uat',
            },

            'includes': ['Templates/Targets/Application.gypi'],

            'xcode_settings': {
                'INFOPLIST_FILE': 'PoqDemoApp/SupportFiles/PoqDemoApp-InHouseUAT-Info.plist',
                'ASSETCATALOG_COMPILER_APPICON_NAME': 'PoqDemoApp-AppIcon',
            },

            'mac_framework_headers': [
                '../PoqPlatform/SupportFiles/PoqPlatform.h',
            ],

            'sources': [
                '<!@(find ./PoqDemoApp/Sources -name *.swift -o -name *.h)',
            ],

            'link_settings': {
                'libraries': [
                    '$(BUILT_PRODUCTS_DIR)/PoqUrbanAirship.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqCart.framework'
                ],
            },

            'mac_bundle_resources': [
                '<!@(find ./PoqDemoApp/Resources -name *.storyboard -o -name *.xib -o -name *.xcassets -o -name *.xcdatamodel -o -name *.otf -o -name *.ttf -o -name *.strings -o -name *.bundle)',
                '<!@(find ./PoqDemoApp/SupportFiles/UAT -iname *.plist)', 
                '<!@(find ./PoqDemoApp/SupportFiles -iname *.json)', 
            ],

            'copies': [
                {
                    'destination': '<(PRODUCT_DIR)/<(target_name).app/PlugIns',
                    'files': [ '<(PRODUCT_DIR)/<(target_name)-NotificationExtension.appex' ]
                }
            ],

            'postbuilds': [
                {
                    'postbuild_name': 'Embed Client Frameworks',
                    'inputs': [],
                    'outputs': [],
                    'action': ['sh', '${SRCROOT}/Generation/Scripts/CopyFramework.sh', 'PoqUrbanAirship.framework', 'PoqCart.framework'],
                },
            ],

            'dependencies': [ '<(target_name)-NotificationExtension' ],
        },
        {
            'variables': {
                'product_name': 'PoqDemoApp-InHouseUAT',
                'product_id': 'com.poq.poqdemoapp-uat'
            },

            'includes': ['Templates/Targets/NotificationExtension.gypi'],
        },

#       ---------- Earl Grey Test Target ----------

        {
            'variables': {
                'target_name': 'PoqDemoApp-EGTests',
                'bundle_id': 'com.poq.poqdemoapp-egtests',
                'host_target': 'PoqDemoApp',
                'tests_folder': 'PoqDemoApp-EGTests',
            },

            'includes': ['Templates/Targets/EGTests.gypi'],
        },
    ]
}
