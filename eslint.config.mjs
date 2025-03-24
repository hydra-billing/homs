import { defineConfig } from "eslint/config";
import react from "eslint-plugin-react";
import typescriptEslint from "@typescript-eslint/eslint-plugin";
import globals from "globals";
import tsParser from "@typescript-eslint/parser";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
    baseDirectory: __dirname,
    recommendedConfig: js.configs.recommended,
    allConfig: js.configs.all
});

export default defineConfig([{
    files: [
        'app/javascript/**/*.{js,jsx}',
        'hbw/app/javascript/**/*.{js,jsx}'
    ],
    extends: compat.extends(
        "eslint:recommended",
        "airbnb-base",
        "plugin:react/recommended",
        "plugin:@typescript-eslint/eslint-recommended",
    ),

    plugins: {
        react,
        "@typescript-eslint": typescriptEslint
    },

    languageOptions: {
        globals: {
            ...globals.browser,
            ...globals.jquery,
            Application: true,
            I18n: true,
            modulejs: true,
            moment: true,
            node: true,
        },

        parser: tsParser,
    },

    settings: {
        react: {
            version: "16.14.0",
        },
    },

    rules: {
        camelcase: "off",
        "comma-dangle": [1, "only-multiline"],
        "class-methods-use-this": 0,
        "func-names": [1, "never"],
        "import/extensions": 0,
        "import/no-unresolved": 0,
        "key-spacing": [1, {
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

        "max-len": [1, {
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

        "space-before-function-paren": [1, "always"],

        "arrow-parens": ["error", "as-needed", {
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
