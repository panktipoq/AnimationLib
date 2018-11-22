{
    'targets': [
        {
            'target_name': 'PoqCart',

            'includes': ['Templates/Targets/Framework.gypi'],

            'xcode_settings' : {
                'INFOPLIST_FILE': 'PoqCart/SupportFiles/PoqCart-Info.plist',
                'PRODUCT_NAME': 'PoqCart',
                'PRODUCT_BUNDLE_IDENTIFIER': 'com.poq.PoqCart',
            },


            'sources': [
                '<!@(find ./PoqCart -name *.swift -o -name *.h)',
            ],

            'link_settings': {
                'libraries': [
                    '$(BUILT_PRODUCTS_DIR)/PoqNetworking.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqModuling.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqUtilities.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqPlatform.framework',
                ],
            },

        },

        {
    'target_name': 'PoqCart-UnitTests',
    'type': 'loadable_module',
    'mac_xctest_bundle': 1,

    'dependencies': [
        'PoqDemoApp'
    ],

    'xcode_settings': {
        'BUNDLE_LOADER': '$(BUILT_PRODUCTS_DIR)/PoqDemoApp.app/PoqDemoApp',
        'INFOPLIST_FILE': 'PoqCart-UnitTests/Info.plist',
        'PRODUCT_BUNDLE_IDENTIFIER': 'com.poq.PoqCart-unittests',
        'TEST_HOST': '$(BUNDLE_LOADER)',
        'WRAPPER_EXTENSION': 'xctest',
    },
    

    'mac_bundle_resources': [
        '<!@(find PoqCart-UnitTests -type d -name *.bundle)',
    ],
    
    'sources': [
        '<!@(find PoqCart-UnitTests -name *.swift)',
    ],
}
    ]

}
