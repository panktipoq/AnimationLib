{
    'target_name': '<(target_name)',
    'type': 'loadable_module',
    'mac_xcuitest_bundle': 1,

    'dependencies': [
        '<(host_target)'
    ],

    'xcode_settings': {
        'COPY_PHASE_STRIP': 'NO',
        'GCC_NO_COMMON_BLOCKS': 'YES',
        'INFOPLIST_FILE': '<(tests_folder)/Info.plist',
        'PRODUCT_BUNDLE_IDENTIFIER': '<(bundle_id)',
        'PRODUCT_NAME': '<(target_name)',
        'TARGETED_DEVICE_FAMILY': '1,2',
        'TEST_TARGET_NAME': '<(host_target)',
        'USES_XCTRUNNER': 'YES',
    },

    'link_settings': {
        'libraries': [
            '$(BUILT_PRODUCTS_DIR)/PoqPlatform.framework',
        ],
    },

    'mac_bundle_resources': [
        '<!@(find ./<(tests_folder) -type d -name *.bundle)',
    ],

    'sources': [
        '<!@(find <(tests_folder) -name *.swift)',
        '../../../PoqPlatform/Sources/ApplicationConstants/AccessibilityLabels.swift',
    ],
}