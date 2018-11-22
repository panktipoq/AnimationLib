{
    'targets': [
        {
            'target_name': 'PoqUrbanAirship',

            'includes': ['Templates/Targets/Framework.gypi'],

            'xcode_settings' : {
                'INFOPLIST_FILE': 'PoqUrbanAirship/SupportFiles/PoqUrbanAirship-Info.plist',
                'PRODUCT_NAME': 'PoqUrbanAirship',
                'PRODUCT_BUNDLE_IDENTIFIER': 'com.poq.urbanairship',
            },

            'mac_framework_headers': [
                '../PoqUrbanAirship/SupportFiles/PoqUrbanAirship.h',
            ],

            'sources': [
                '<!@(find ./PoqUrbanAirship -name *.swift -o -name *.h)',
            ],

            'link_settings': {
                'libraries': [
                    '$(BUILT_PRODUCTS_DIR)/PoqAnalytics.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqModuling.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqNetworking.framework',
                    '$(BUILT_PRODUCTS_DIR)/PoqUtilities.framework',
                ]
            }
        },
    ]

}
