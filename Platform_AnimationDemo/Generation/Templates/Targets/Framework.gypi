{
    'type': 'shared_library',
    'mac_bundle': 1,

    'xcode_settings': {
        'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES': 'NO',
        'CODE_SIGN_IDENTITY': '',
        'DEVELOPMENT_TEAM': 'DK34MVSU63',
        'DYLIB_INSTALL_NAME_BASE': '@rpath',
        'SKIP_INSTALL': 'YES',
        'TARGETED_DEVICE_FAMILY': '1,2',
        'DEFINES_MODULE': 'YES',
    },

    'postbuilds': [
	{
            'postbuild_name' : 'Swiftlint',
            'inputs' : [],
            'outputs' : [],
            'action' : ['sh', '${SRCROOT}/<(platform_dir)Scripts/Swiftlint.sh', '${SRCROOT}/<(platform_dir)SupportFiles/Swiftlint/.swiftlint.yml'],
        },
    ],
}