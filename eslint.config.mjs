import { defineConfig } from "eslint/config";
import react from "eslint-plugin-react";
import typescriptEslint from "@typescript-eslint/eslint-plugin";
import stylistic from "@stylistic/eslint-plugin";
import importPlugin from "eslint-plugin-import";
import globals from "globals";
import tsParser from "@typescript-eslint/parser";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";
import airbnbRules from "./eslint.airbnb-rules.mjs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

const FILES = [
    'app/javascript/**/*.{js,jsx}',
    'hbw/app/javascript/**/*.{js,jsx}'
];

export default defineConfig([{
    files: FILES,
    extends: compat.extends(
        "eslint:recommended",
        "plugin:react/recommended",
        "plugin:@typescript-eslint/eslint-recommended",
    ),

    plugins: {
        react,
        "@typescript-eslint": typescriptEslint,
        "@stylistic": stylistic,
        import: importPlugin
    },

    languageOptions: {
        globals: {
            // airbnb-base declared env: { node: true, es6: true }, which FlatCompat expanded
            // into globals. Without them console/require and Promise/Map/Set/Symbol vanish → no-undef.
            ...globals.node,
            ...globals.es2015,
            ...globals.browser,
            ...globals.jquery,
            Application: true,
            I18n: true,
            moment: true,
            node: true,
        },

        parser: tsParser,
    },

    settings: {
        react: {
            version: "16.14.0",
        },

        // Came from eslint-config-airbnb-base/rules/imports.js.
        // Without 'import/ignore' the plugin goes off resolving imports into node_modules.
        'import/resolver': {
            node: {
                extensions: ['.mjs', '.js', '.json'],
            },
        },
        'import/extensions': ['.js', '.mjs', '.jsx'],
        'import/core-modules': [],
        'import/ignore': ['node_modules', '\\.(coffee|scss|css|less|hbs|svg|json)$'],
    },

    rules: airbnbRules,
},
{
    // Separate layer: an entry like `camelcase: "off"` changes only severity and keeps the
    // options from the previous layer. Within a single rules object a spread would overwrite them
    // along with their options.
    files: FILES,

    rules: {
        camelcase: "off",
        "@stylistic/comma-dangle": [1, "only-multiline"],
        "class-methods-use-this": 0,
        "func-names": [1, "never"],
        "import/extensions": 0,
        "import/no-unresolved": 0,
        "@stylistic/key-spacing": [1, {
            singleLine: {
                beforeColon: false,
                afterColon: true,
            },

            multiLine: {
                beforeColon: false,
                afterColon: true,
                align: "value",
            },
        }],

        "@stylistic/max-len": [1, {
            code: 121,
            ignoreComments: true,
        }],

        "no-alert": 0,
        "no-underscore-dangle": 0,
        "no-unused-vars": "off",
        "@typescript-eslint/no-unused-vars": ["error"],
        "no-use-before-define": "off",
        "@typescript-eslint/no-use-before-define": ["error"],
        "no-else-return": 0,

        "no-param-reassign": ["error", {
            props: false,
        }],

        radix: [2, "as-needed"],
        "react/display-name": 0,

        "react/prop-types": [1, {
            skipUndeclared: true,
        }],

        "@stylistic/space-before-function-paren": [1, "always"],

        "@stylistic/arrow-parens": ["error", "as-needed", {
            requireForBlockBody: true,
        }],

        "max-classes-per-file": ["error", 3],

        "prefer-destructuring": ["error", {
            object: true,
            array: false,
        }],

        curly: [1, "all"],
    },
}]);
