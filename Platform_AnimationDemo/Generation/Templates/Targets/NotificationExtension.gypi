{
    'variables': {
        # Team id defaulted to the enterprise team.
        'team_id%': 'DK34MVSU63',
        'signing_identity%': 'iPhone Distribution',
    },

    'target_name': '<(product_name)-NotificationExtension',
    'product_name': '<(product_name)-NotificationExtension',
    'type': 'executable',
    'mac_bundle': 1,
    'ios_app_extension': 1,

    'xcode_settings': {
        'CODE_SIGN_ENTITLEMENTS': '<!(find . -name <(product_name)-NotificationExtension.entitlements)',
        'CODE_SIGN_IDENTITY': '<(signing_identity)',
        'DEVELOPMENT_TEAM': '<(team_id)',
        'INFOPLIST_FILE': '<(platform_dir)PoqNotificationExtension/SupportFiles/Info.plist',
        'PRODUCT_BUNDLE_IDENTIFIER': '<(product_id).notificationextension',
        'PROVISIONING_PROFILE_SPECIFIER': '<(product_name)-NotificationExtension',
    },

    'sources': [
        '<!@(find <(platform_dir)PoqNotificationExtension/Sources -name *.swift)',
    ],

    'mac_bundle_resources': [
        '<!@(find . -name <(product_name)-NotificationExtension.entitlements)',
    ],
}
