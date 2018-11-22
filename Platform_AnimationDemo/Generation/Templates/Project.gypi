{
    'variables': {
        'platform_dir%': 'Poq.iOS.Platform/',
        'version%': '',
    },

    'xcode_settings': {
        'POQ_BUILD_NUMBER': '',
        'POQ_VERSION': '<(version)',
    },

    'target_defaults': {
        'configurations': {
            'Debug': {
                'defines': [ '$(inherited)', 'DEBUG=1' ],

                'xcode_settings': {
                    'ONLY_ACTIVE_ARCH': 'YES',
                    'SWIFT_OPTIMIZATION_LEVEL': '-Onone',
                },
            },
            'Release': { },
            'Calabash': { },
        },

        'defines': [ '$(inherited)' ],

        'xcode_settings': {
            'ENABLE_BITCODE': 'NO',
            'ENABLE_TESTABILITY': 'YES',
            'IPHONEOS_DEPLOYMENT_TARGET': '11.0',
            'ONLY_ACTIVE_ARCH': 'NO',
            'SDKROOT': 'iphoneos',
            'SWIFT_OPTIMIZATION_LEVEL': '-Owholemodule',
            'SWIFT_VERSION': '4.0',
            'SWIFT_WHOLE_MODULE_OPTIMIZATION': 'YES',
        },

        'library_dirs': [
            '$(inherited)',
        ],

        'mac_framework_dirs': [
            '$(inherited)',
        ],
    },
}