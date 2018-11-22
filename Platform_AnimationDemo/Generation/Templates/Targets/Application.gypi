{
    'variables': {
        # Fabric keys defaulted to empty.
        'fabric_api_key%': '',
        'fabric_secret%': '',
        
        # Team id defaulted to the enterprise team.
        'team_id%': 'DK34MVSU63',
        'signing_identity%': 'iPhone Distribution',
    },

    'target_name': '<(target_name)',
    'type': 'executable',
    'mac_bundle': 1,

    'xcode_settings': {
        'CODE_SIGN_ENTITLEMENTS': '<!(find . -name <(target_name).entitlements)',
        'CODE_SIGN_IDENTITY': '<(signing_identity)',
        'DEVELOPMENT_TEAM': '<(team_id)',
        'FABRIC_API_KEY': '<(fabric_api_key)',
        'FABRIC_API_SECRET': '<(fabric_secret)',
        'PRODUCT_BUNDLE_IDENTIFIER': '<(bundle_id)',
        'PRODUCT_NAME': '<(target_name)',
        'PROVISIONING_PROFILE_SPECIFIER': '<(target_name)',
        'TARGETED_DEVICE_FAMILY': '1,2',
    },

    'link_settings': {
        'libraries': [
            '$(BUILT_PRODUCTS_DIR)/PoqAnalytics.framework',
            '$(BUILT_PRODUCTS_DIR)/PoqPlatform.framework',
            '$(BUILT_PRODUCTS_DIR)/PoqModuling.framework',
            '$(BUILT_PRODUCTS_DIR)/PoqNetworking.framework',
            '$(BUILT_PRODUCTS_DIR)/PoqUtilities.framework',
        ],
    },

    'mac_bundle_resources': [
        '<!@(find . -name <(target_name).entitlements)',
    ],

    'postbuilds': [
        {
            'postbuild_name': 'Embed Platform Frameworks',
            'inputs': [],
            'outputs': [],
            'action': ['sh', '${SRCROOT}/<(platform_dir)Generation/Scripts/CopyFramework.sh', 'PoqAnalytics.framework', 'PoqPlatform.framework', 'PoqModuling.framework', 'PoqNetworking.framework', 'PoqUtilities.framework'],
        },
	    {
            'postbuild_name' : 'Swiftlint',
            'inputs' : [],
            'outputs' : [],
            'action' : ['sh', '${SRCROOT}/<(platform_dir)Scripts/Swiftlint.sh', '${SRCROOT}/<(platform_dir)SupportFiles/Swiftlint/.swiftlint.yml'],
        },
    ],

    'conditions': [
        [
            'fabric_api_key!=""', {
                'postbuilds' : [
                    {
                        'postbuild_name': 'Fabric',
                        'inputs': [],
                        'outputs': [],
                        'action': ['sh', '${SRCROOT}/<(platform_dir)Generation/Scripts/RunFabric.sh'],
                    },
                ]
            }
        ],
    ],
}
