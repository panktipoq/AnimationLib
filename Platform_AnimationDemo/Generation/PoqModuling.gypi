{
    'targets': [
        {
            'target_name': 'PoqModuling',

            'includes': ['Templates/Targets/Framework.gypi'],

            'xcode_settings' : {
                'INFOPLIST_FILE' : 'PoqModuling/SupportFiles/PoqModuling-Info.plist',
                'PRODUCT_NAME': 'PoqModuling',
                'PRODUCT_BUNDLE_IDENTIFIER': 'com.poq.moduling',
            },

            'mac_framework_headers': [
                '../PoqModuling/SupportFiles/PoqModuling.h',
            ],

            'sources': [
                '<!@(find ./PoqModuling -name *.swift -o -name *.h)',
            ],

            'link_settings': {
                'libraries': [
                    '$(BUILT_PRODUCTS_DIR)/PoqUtilities.framework',
                ]
            }
        },
        
        #       ---------- Unit Test Target ----------
        {
            'variables': {
                'target_name': 'PoqModuling-UnitTests',
                'bundle_id': 'com.poq.moduling-unittests',
                # To make run on each PR we need attach it to app target
                'host_target': 'PoqDemoApp',
                'tests_folder': 'PoqModuling-UnitTests',
            },

            'includes': ['Templates/Targets/UnitTests.gypi'],
        }
    ]
}
