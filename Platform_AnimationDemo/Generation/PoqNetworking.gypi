{
    'targets': [
        {
            'target_name': 'PoqNetworking',

            'includes': ['Templates/Targets/Framework.gypi'],

            'xcode_settings' : {
                'INFOPLIST_FILE' : 'PoqNetworking/SupportFiles/PoqNetworking-Info.plist',
                'PRODUCT_NAME': 'PoqNetworking',
                'PRODUCT_BUNDLE_IDENTIFIER': 'com.poq.networking',
            },

            'mac_framework_headers': [
                '../PoqNetworking/SupportFiles/PoqNetworking.h',
            ],

            'sources': [
                '<!@(find ./PoqNetworking -name *.swift -o -name *.h)',
            ],

            'link_settings': {
                'libraries': [
                    '$(BUILT_PRODUCTS_DIR)/PoqModuling.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqUtilities.framework',
                ]
            }
        },

#       ---------- Unit Test Target ----------

        {
            'variables': {
                'target_name': 'PoqNetworking-UnitTests',
                'bundle_id': 'com.poq.networking-unittests',
                # To make run on each PR we need attach it to app target
                'host_target': 'PoqDemoApp',
                'tests_folder': 'PoqNetworking-UnitTests',
            },

            'includes': ['Templates/Targets/UnitTests.gypi'],
        },
    ]
}
