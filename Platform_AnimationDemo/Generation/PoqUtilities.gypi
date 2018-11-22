{
    'targets': [
        {
            'target_name': 'PoqUtilities',

            'includes': ['Templates/Targets/Framework.gypi'],

            'xcode_settings' : {
                'INFOPLIST_FILE': 'PoqUtilities/SupportFiles/PoqUtilities-Info.plist',
                'PRODUCT_NAME': 'PoqUtilities',
                'PRODUCT_BUNDLE_IDENTIFIER': 'com.poq.utilities',
                'SWIFT_INCLUDE_PATHS': '$(SRCROOT)/SupportFiles/GoogleAnalytics/** $(SRCROOT)/SupportFiles/GoogleTagManager/** $(SRCROOT)/PoqPlatform/SupportFiles/**',
            },

            'mac_framework_headers': [
                '../PoqUtilities/SupportFiles/PoqUtilities.h',
            ],

            'sources': [
                '<!@(find ./PoqUtilities -name *.swift -o -name *.h)',
            ],
        },
    #       ---------- Unit Test Target ----------

        {
            'variables': {
                'target_name': 'PoqUtilities-UnitTests',
                'bundle_id': 'com.poq.utilities-unittests',
                'host_target': 'PoqDemoApp',
                'tests_folder': 'PoqUtilities-UnitTests',
            },
            
            'includes': ['Templates/Targets/UnitTests.gypi'],
        },
    ]

}
