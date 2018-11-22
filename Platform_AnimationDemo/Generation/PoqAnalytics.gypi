{
    'targets': [
        {
            'target_name': 'PoqAnalytics',

            'includes': ['Templates/Targets/Framework.gypi'],

            'xcode_settings' : {
                'INFOPLIST_FILE' : 'PoqAnalytics/SupportFiles/PoqAnalytics-Info.plist',
                'PRODUCT_NAME': 'PoqAnalytics',
                'PRODUCT_BUNDLE_IDENTIFIER': 'com.poq.analytics',
            },

            'mac_framework_headers': [
                '../PoqAnalytics/SupportFiles/PoqAnalytics.h',
            ],

            'sources': [
                '<!@(find ./PoqAnalytics -name *.swift -o -name *.h)',
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
                'target_name': 'PoqAnalytics-UnitTests',
                'bundle_id': 'com.poq.analytics-unittests',
                # To make run on each PR we need attach it to app target
                'host_target': 'PoqDemoApp',
                'tests_folder': 'PoqAnalytics-UnitTests',
            },

            'includes': ['Templates/Targets/UnitTests.gypi'],
        },
    ]
}