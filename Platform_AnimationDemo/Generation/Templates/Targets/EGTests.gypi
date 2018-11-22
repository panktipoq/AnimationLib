{
    'target_name': '<(target_name)',
    'type': 'loadable_module',
    'mac_xctest_bundle': 1,

    'dependencies': [
        '<(host_target)'
    ],

    'xcode_settings': {
        'BUNDLE_LOADER': '$(BUILT_PRODUCTS_DIR)/<(host_target).app/<(host_target)',
        'INFOPLIST_FILE': '<(tests_folder)/Info.plist',
        'PRODUCT_BUNDLE_IDENTIFIER': '<(bundle_id)',
        'TEST_HOST': '$(BUNDLE_LOADER)',
        'WRAPPER_EXTENSION': 'xctest',
    },
    
    'link_settings': {
        'libraries': [
            '$(BUILT_PRODUCTS_DIR)/PoqPlatform.framework',
        ],
    },

    'mac_bundle_resources': [
        '<!@(find <(tests_folder) -type d -name *.bundle)',
    ],
    
    'sources': [
        '<!@(find <(tests_folder) <(platform_dir)PoqTesting <(platform_dir)PoqDemoApp-EGTests/Base -name *.swift)',
    ],
}