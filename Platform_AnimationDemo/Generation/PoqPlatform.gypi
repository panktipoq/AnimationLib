{
    'targets': [
        {
            'target_name': 'PoqPlatform',

            'includes': ['Templates/Targets/Framework.gypi'],

            'xcode_settings' : {
                'INFOPLIST_FILE': 'PoqPlatform/SupportFiles/PoqPlatform-Info.plist',
                'PRODUCT_NAME': 'PoqPlatform',
                'PRODUCT_BUNDLE_IDENTIFIER': 'com.poq.platform',
                'SWIFT_INCLUDE_PATHS': '$(SRCROOT)/SupportFiles/GoogleAnalytics/**',
            },

            'mac_framework_headers': [
                '../PoqPlatform/SupportFiles/PoqPlatform.h',
            ],

            'sources': [
                '<!@(find ./PoqPlatform -name *.swift -o -name *.h)',
            ],

            'link_settings': {
                'libraries': [
                    '$(BUILT_PRODUCTS_DIR)/PoqModuling.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqNetworking.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqUtilities.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqAnalytics.framework',
                ],
            },

            'mac_bundle_resources': [
                '<!@(find ./PoqPlatform -name *.storyboard -o -name *.xib -o -name *.xcassets -o -name *.xcdatamodel -o -name *.otf -o -name *.ttf -o -name *.strings -o -name *.bundle)',
                '<!@(find ./Resources -name *.xcassets -o -name *.xcdatamodel -o -name *.otf -o -name *.ttf -o -name *.strings -o -name *.bundle)',
                '<!@(find ./PoqPlatform/SupportFiles -iname *.json)'
            ],
        },

#       ---------- Unit Test Target ----------

        {
            'variables': {
                'target_name': 'PoqPlatform-UnitTests',
                'bundle_id': 'com.poq.platform-unittests',
                'host_target': 'PoqDemoApp',
                'tests_folder': 'PoqPlatform-UnitTests',
            },

            'includes': ['Templates/Targets/UnitTests.gypi'],
            
            'mac_bundle_resources': [
                '<!@(find ./PoqPlatform-UnitTests/Helper/FileTests -iname *.json)'
            ],
        },
    ]
}
