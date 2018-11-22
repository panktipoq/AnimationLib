{
    'variables' : {
        # Location of the platform relative to current directory - MUST be left empty or end with "/"
        # An example of its usage within gypi: '${SRC_ROOT}/<(platform_dir)SomeFolder' or '<(platform_dir)SomeFolder'
        'platform_dir': '',

        # The default version number for all targets of this project.
        'version': '12.2.0',

        # Fabric details which will be built into the project file as variables.
        'fabric_api_key%': '8cea57cad8f39f3960f3eb8efd9468cb9a808dfe',
        'fabric_secret%': '9399681b857b45b239751a3fadeac35291be0c45c3cda4b1a98f740880b51024',
    },

    'includes': [
        './Generation/Templates/Project.gypi',
        './Generation/PoqDemoApp.gypi',
        './Generation/PoqAnalytics.gypi',
        './Generation/PoqCart.gypi',
        './Generation/PoqPlatform.gypi',
        './Generation/PoqModuling.gypi',
        './Generation/PoqNetworking.gypi',
        './Generation/PoqUrbanAirship.gypi',
        './Generation/PoqUtilities.gypi',
    ],
}
