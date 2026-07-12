// Snapshot of eslint-config-airbnb-base@15.0.0 rules, inlined into the project.
//
// The package is abandoned (last published November 2021, peerDependency eslint ^7 || ^8),
// so the rules are copied here as-is. Differences from the original:
//   • deprecated formatting rules renamed to @stylistic/* (core will drop them in ESLint 11);
//   • lines-around-directive → @stylistic/padding-line-between-statements (options rewritten);
//   • no-new-symbol → no-new-native-nonconstructor, no-new-object → no-object-constructor;
//   • dropped: no-return-await (no replacement); global-require, no-buffer-constructor,
//     no-new-require, no-path-concat (node rules, not needed on the frontend);
//     no-spaced-func, newline-after-var, newline-before-return (disabled deprecated aliases);
//     padding-line-between-statements — airbnb has it turned off, and after the rename it
//     would collapse into the same key as the active lines-around-directive, overwriting it,
//     so only the active @stylistic/padding-line-between-statements entry is kept.
//
// import/* rules require eslint-plugin-import, registered in eslint.config.mjs.
// The project's local overrides live in a separate layer in eslint.config.mjs — that way an
// entry like `'camelcase': off` changes only severity while keeping the options from here.

export default {
  "accessor-pairs": "off",
  "array-callback-return": [
    "error",
    {
      "allowImplicit": true
    }
  ],
  "block-scoped-var": "error",
  "complexity": [
    "off",
    20
  ],
  "class-methods-use-this": [
    "error",
    {
      "exceptMethods": []
    }
  ],
  "consistent-return": "error",
  "curly": [
    "error",
    "multi-line"
  ],
  "default-case": [
    "error",
    {
      "commentPattern": "^no default$"
    }
  ],
  "default-case-last": "error",
  "default-param-last": "error",
  "dot-notation": [
    "error",
    {
      "allowKeywords": true
    }
  ],
  "@stylistic/dot-location": [
    "error",
    "property"
  ],
  "eqeqeq": [
    "error",
    "always",
    {
      "null": "ignore"
    }
  ],
  "grouped-accessor-pairs": "error",
  "guard-for-in": "error",
  "max-classes-per-file": [
    "error",
    1
  ],
  "no-alert": "warn",
  "no-caller": "error",
  "no-case-declarations": "error",
  "no-constructor-return": "error",
  "no-div-regex": "off",
  "no-else-return": [
    "error",
    {
      "allowElseIf": false
    }
  ],
  "no-empty-function": [
    "error",
    {
      "allow": [
        "arrowFunctions",
        "functions",
        "methods"
      ]
    }
  ],
  "no-empty-pattern": "error",
  "no-eq-null": "off",
  "no-eval": "error",
  "no-extend-native": "error",
  "no-extra-bind": "error",
  "no-extra-label": "error",
  "no-fallthrough": "error",
  "@stylistic/no-floating-decimal": "error",
  "no-global-assign": [
    "error",
    {
      "exceptions": []
    }
  ],
  "no-native-reassign": "off",
  "no-implicit-coercion": [
    "off",
    {
      "boolean": false,
      "number": true,
      "string": true,
      "allow": []
    }
  ],
  "no-implicit-globals": "off",
  "no-implied-eval": "error",
  "no-invalid-this": "off",
  "no-iterator": "error",
  "no-labels": [
    "error",
    {
      "allowLoop": false,
      "allowSwitch": false
    }
  ],
  "no-lone-blocks": "error",
  "no-loop-func": "error",
  "no-magic-numbers": [
    "off",
    {
      "ignore": [],
      "ignoreArrayIndexes": true,
      "enforceConst": true,
      "detectObjects": false
    }
  ],
  "@stylistic/no-multi-spaces": [
    "error",
    {
      "ignoreEOLComments": false
    }
  ],
  "no-multi-str": "error",
  "no-new": "error",
  "no-new-func": "error",
  "no-new-wrappers": "error",
  "no-nonoctal-decimal-escape": "error",
  "no-octal": "error",
  "no-octal-escape": "error",
  "no-param-reassign": [
    "error",
    {
      "props": true,
      "ignorePropertyModificationsFor": [
        "acc",
        "accumulator",
        "e",
        "ctx",
        "context",
        "req",
        "request",
        "res",
        "response",
        "$scope",
        "staticContext"
      ]
    }
  ],
  "no-proto": "error",
  "no-redeclare": "error",
  "no-restricted-properties": [
    "error",
    {
      "object": "arguments",
      "property": "callee",
      "message": "arguments.callee is deprecated"
    },
    {
      "object": "global",
      "property": "isFinite",
      "message": "Please use Number.isFinite instead"
    },
    {
      "object": "self",
      "property": "isFinite",
      "message": "Please use Number.isFinite instead"
    },
    {
      "object": "window",
      "property": "isFinite",
      "message": "Please use Number.isFinite instead"
    },
    {
      "object": "global",
      "property": "isNaN",
      "message": "Please use Number.isNaN instead"
    },
    {
      "object": "self",
      "property": "isNaN",
      "message": "Please use Number.isNaN instead"
    },
    {
      "object": "window",
      "property": "isNaN",
      "message": "Please use Number.isNaN instead"
    },
    {
      "property": "__defineGetter__",
      "message": "Please use Object.defineProperty instead."
    },
    {
      "property": "__defineSetter__",
      "message": "Please use Object.defineProperty instead."
    },
    {
      "object": "Math",
      "property": "pow",
      "message": "Use the exponentiation operator (**) instead."
    }
  ],
  "no-return-assign": [
    "error",
    "always"
  ],
  "no-script-url": "error",
  "no-self-assign": [
    "error",
    {
      "props": true
    }
  ],
  "no-self-compare": "error",
  "no-sequences": "error",
  "no-throw-literal": "error",
  "no-unmodified-loop-condition": "off",
  "no-unused-expressions": [
    "error",
    {
      "allowShortCircuit": false,
      "allowTernary": false,
      "allowTaggedTemplates": false
    }
  ],
  "no-unused-labels": "error",
  "no-useless-call": "off",
  "no-useless-catch": "error",
  "no-useless-concat": "error",
  "no-useless-escape": "error",
  "no-useless-return": "error",
  "no-void": "error",
  "no-warning-comments": [
    "off",
    {
      "terms": [
        "todo",
        "fixme",
        "xxx"
      ],
      "location": "start"
    }
  ],
  "no-with": "error",
  "prefer-promise-reject-errors": [
    "error",
    {
      "allowEmptyReject": true
    }
  ],
  "prefer-named-capture-group": "off",
  "prefer-regex-literals": [
    "error",
    {
      "disallowRedundantWrapping": true
    }
  ],
  "radix": "error",
  "require-await": "off",
  "require-unicode-regexp": "off",
  "vars-on-top": "error",
  "@stylistic/wrap-iife": [
    "error",
    "outside",
    {
      "functionPrototypeMethods": false
    }
  ],
  "yoda": "error",
  "for-direction": "error",
  "getter-return": [
    "error",
    {
      "allowImplicit": true
    }
  ],
  "no-async-promise-executor": "error",
  "no-await-in-loop": "error",
  "no-compare-neg-zero": "error",
  "no-cond-assign": [
    "error",
    "always"
  ],
  "no-console": "warn",
  "no-constant-condition": "warn",
  "no-control-regex": "error",
  "no-debugger": "error",
  "no-dupe-args": "error",
  "no-dupe-else-if": "error",
  "no-dupe-keys": "error",
  "no-duplicate-case": "error",
  "no-empty": "error",
  "no-empty-character-class": "error",
  "no-ex-assign": "error",
  "no-extra-boolean-cast": "error",
  "@stylistic/no-extra-parens": [
    "off",
    "all",
    {
      "conditionalAssign": true,
      "nestedBinaryExpressions": false,
      "returnAssign": false,
      "ignoreJSX": "all",
      "enforceForArrowConditionals": false
    }
  ],
  "@stylistic/no-extra-semi": "error",
  "no-func-assign": "error",
  "no-import-assign": "error",
  "no-inner-declarations": "error",
  "no-invalid-regexp": "error",
  "no-irregular-whitespace": "error",
  "no-loss-of-precision": "error",
  "no-misleading-character-class": "error",
  "no-obj-calls": "error",
  "no-promise-executor-return": "error",
  "no-prototype-builtins": "error",
  "no-regex-spaces": "error",
  "no-setter-return": "error",
  "no-sparse-arrays": "error",
  "no-template-curly-in-string": "error",
  "no-unexpected-multiline": "error",
  "no-unreachable": "error",
  "no-unreachable-loop": [
    "error",
    {
      "ignore": []
    }
  ],
  "no-unsafe-finally": "error",
  "no-unsafe-negation": "error",
  "no-unsafe-optional-chaining": [
    "error",
    {
      "disallowArithmeticOperators": true
    }
  ],
  "no-unused-private-class-members": "off",
  "no-useless-backreference": "error",
  "no-negated-in-lhs": "off",
  "require-atomic-updates": "off",
  "use-isnan": "error",
  "valid-jsdoc": "off",
  "valid-typeof": [
    "error",
    {
      "requireStringLiterals": true
    }
  ],
  "callback-return": "off",
  "handle-callback-err": "off",
  "no-mixed-requires": [
    "off",
    false
  ],
  "no-process-env": "off",
  "no-process-exit": "off",
  "no-restricted-modules": "off",
  "no-sync": "off",
  "@stylistic/array-bracket-newline": [
    "off",
    "consistent"
  ],
  "@stylistic/array-element-newline": [
    "off",
    {
      "multiline": true,
      "minItems": 3
    }
  ],
  "@stylistic/array-bracket-spacing": [
    "error",
    "never"
  ],
  "@stylistic/block-spacing": [
    "error",
    "always"
  ],
  "@stylistic/brace-style": [
    "error",
    "1tbs",
    {
      "allowSingleLine": true
    }
  ],
  "camelcase": [
    "error",
    {
      "properties": "never",
      "ignoreDestructuring": false
    }
  ],
  "capitalized-comments": [
    "off",
    "never",
    {
      "line": {
        "ignorePattern": ".*",
        "ignoreInlineComments": true,
        "ignoreConsecutiveComments": true
      },
      "block": {
        "ignorePattern": ".*",
        "ignoreInlineComments": true,
        "ignoreConsecutiveComments": true
      }
    }
  ],
  "@stylistic/comma-dangle": [
    "error",
    {
      "arrays": "always-multiline",
      "objects": "always-multiline",
      "imports": "always-multiline",
      "exports": "always-multiline",
      "functions": "always-multiline"
    }
  ],
  "@stylistic/comma-spacing": [
    "error",
    {
      "before": false,
      "after": true
    }
  ],
  "@stylistic/comma-style": [
    "error",
    "last",
    {
      "exceptions": {
        "ArrayExpression": false,
        "ArrayPattern": false,
        "ArrowFunctionExpression": false,
        "CallExpression": false,
        "FunctionDeclaration": false,
        "FunctionExpression": false,
        "ImportDeclaration": false,
        "ObjectExpression": false,
        "ObjectPattern": false,
        "VariableDeclaration": false,
        "NewExpression": false
      }
    }
  ],
  "@stylistic/computed-property-spacing": [
    "error",
    "never"
  ],
  "consistent-this": "off",
  "@stylistic/eol-last": [
    "error",
    "always"
  ],
  "@stylistic/function-call-argument-newline": [
    "error",
    "consistent"
  ],
  "@stylistic/function-call-spacing": [
    "error",
    "never"
  ],
  "func-name-matching": [
    "off",
    "always",
    {
      "includeCommonJSModuleExports": false,
      "considerPropertyDescriptor": true
    }
  ],
  "func-names": "warn",
  "func-style": [
    "off",
    "expression"
  ],
  "@stylistic/function-paren-newline": [
    "error",
    "multiline-arguments"
  ],
  "id-denylist": "off",
  "id-length": "off",
  "id-match": "off",
  "@stylistic/implicit-arrow-linebreak": [
    "error",
    "beside"
  ],
  "@stylistic/indent": [
    "error",
    2,
    {
      "SwitchCase": 1,
      "VariableDeclarator": 1,
      "outerIIFEBody": 1,
      "FunctionDeclaration": {
        "parameters": 1,
        "body": 1
      },
      "FunctionExpression": {
        "parameters": 1,
        "body": 1
      },
      "CallExpression": {
        "arguments": 1
      },
      "ArrayExpression": 1,
      "ObjectExpression": 1,
      "ImportDeclaration": 1,
      "flatTernaryExpressions": false,
      "ignoredNodes": [
        "JSXElement",
        "JSXElement > *",
        "JSXAttribute",
        "JSXIdentifier",
        "JSXNamespacedName",
        "JSXMemberExpression",
        "JSXSpreadAttribute",
        "JSXExpressionContainer",
        "JSXOpeningElement",
        "JSXClosingElement",
        "JSXFragment",
        "JSXOpeningFragment",
        "JSXClosingFragment",
        "JSXText",
        "JSXEmptyExpression",
        "JSXSpreadChild"
      ],
      "ignoreComments": false
    }
  ],
  "@stylistic/jsx-quotes": [
    "off",
    "prefer-double"
  ],
  "@stylistic/key-spacing": [
    "error",
    {
      "beforeColon": false,
      "afterColon": true
    }
  ],
  "@stylistic/keyword-spacing": [
    "error",
    {
      "before": true,
      "after": true,
      "overrides": {
        "return": {
          "after": true
        },
        "throw": {
          "after": true
        },
        "case": {
          "after": true
        }
      }
    }
  ],
  "@stylistic/line-comment-position": [
    "off",
    {
      "position": "above",
      "ignorePattern": "",
      "applyDefaultPatterns": true
    }
  ],
  "@stylistic/linebreak-style": [
    "error",
    "unix"
  ],
  "@stylistic/lines-between-class-members": [
    "error",
    "always",
    {
      "exceptAfterSingleLine": false
    }
  ],
  "@stylistic/lines-around-comment": "off",
  "@stylistic/padding-line-between-statements": [
    "error",
    {
      "blankLine": "always",
      "prev": "directive",
      "next": "*"
    }
  ],
  "max-depth": [
    "off",
    4
  ],
  "@stylistic/max-len": [
    "error",
    100,
    2,
    {
      "ignoreUrls": true,
      "ignoreComments": false,
      "ignoreRegExpLiterals": true,
      "ignoreStrings": true,
      "ignoreTemplateLiterals": true
    }
  ],
  "max-lines": [
    "off",
    {
      "max": 300,
      "skipBlankLines": true,
      "skipComments": true
    }
  ],
  "max-lines-per-function": [
    "off",
    {
      "max": 50,
      "skipBlankLines": true,
      "skipComments": true,
      "IIFEs": true
    }
  ],
  "max-nested-callbacks": "off",
  "max-params": [
    "off",
    3
  ],
  "max-statements": [
    "off",
    10
  ],
  "@stylistic/max-statements-per-line": [
    "off",
    {
      "max": 1
    }
  ],
  "@stylistic/multiline-comment-style": [
    "off",
    "starred-block"
  ],
  "@stylistic/multiline-ternary": [
    "off",
    "never"
  ],
  "new-cap": [
    "error",
    {
      "newIsCap": true,
      "newIsCapExceptions": [],
      "capIsNew": false,
      "capIsNewExceptions": [
        "Immutable.Map",
        "Immutable.Set",
        "Immutable.List"
      ]
    }
  ],
  "@stylistic/new-parens": "error",
  "@stylistic/newline-per-chained-call": [
    "error",
    {
      "ignoreChainWithDepth": 4
    }
  ],
  "no-array-constructor": "error",
  "no-bitwise": "error",
  "no-continue": "error",
  "no-inline-comments": "off",
  "no-lonely-if": "error",
  "@stylistic/no-mixed-operators": [
    "error",
    {
      "groups": [
        [
          "%",
          "**"
        ],
        [
          "%",
          "+"
        ],
        [
          "%",
          "-"
        ],
        [
          "%",
          "*"
        ],
        [
          "%",
          "/"
        ],
        [
          "/",
          "*"
        ],
        [
          "&",
          "|",
          "<<",
          ">>",
          ">>>"
        ],
        [
          "==",
          "!=",
          "===",
          "!=="
        ],
        [
          "&&",
          "||"
        ]
      ],
      "allowSamePrecedence": false
    }
  ],
  "@stylistic/no-mixed-spaces-and-tabs": "error",
  "no-multi-assign": [
    "error"
  ],
  "@stylistic/no-multiple-empty-lines": [
    "error",
    {
      "max": 1,
      "maxBOF": 0,
      "maxEOF": 0
    }
  ],
  "no-negated-condition": "off",
  "no-nested-ternary": "error",
  "no-object-constructor": "error",
  "no-plusplus": "error",
  "no-restricted-syntax": [
    "error",
    {
      "selector": "ForInStatement",
      "message": "for..in loops iterate over the entire prototype chain, which is virtually never what you want. Use Object.{keys,values,entries}, and iterate over the resulting array."
    },
    {
      "selector": "ForOfStatement",
      "message": "iterators/generators require regenerator-runtime, which is too heavyweight for this guide to allow them. Separately, loops should be avoided in favor of array iterations."
    },
    {
      "selector": "LabeledStatement",
      "message": "Labels are a form of GOTO; using them makes code confusing and hard to maintain and understand."
    },
    {
      "selector": "WithStatement",
      "message": "`with` is disallowed in strict mode because it makes code impossible to predict and optimize."
    }
  ],
  "@stylistic/no-tabs": "error",
  "no-ternary": "off",
  "@stylistic/no-trailing-spaces": [
    "error",
    {
      "skipBlankLines": false,
      "ignoreComments": false
    }
  ],
  "no-underscore-dangle": [
    "error",
    {
      "allow": [],
      "allowAfterThis": false,
      "allowAfterSuper": false,
      "enforceInMethodNames": true
    }
  ],
  "no-unneeded-ternary": [
    "error",
    {
      "defaultAssignment": false
    }
  ],
  "@stylistic/no-whitespace-before-property": "error",
  "@stylistic/nonblock-statement-body-position": [
    "error",
    "beside",
    {
      "overrides": {}
    }
  ],
  "@stylistic/object-curly-spacing": [
    "error",
    "always"
  ],
  "@stylistic/object-curly-newline": [
    "error",
    {
      "ObjectExpression": {
        "minProperties": 4,
        "multiline": true,
        "consistent": true
      },
      "ObjectPattern": {
        "minProperties": 4,
        "multiline": true,
        "consistent": true
      },
      "ImportDeclaration": {
        "minProperties": 4,
        "multiline": true,
        "consistent": true
      },
      "ExportDeclaration": {
        "minProperties": 4,
        "multiline": true,
        "consistent": true
      }
    }
  ],
  "@stylistic/object-property-newline": [
    "error",
    {
      "allowAllPropertiesOnSameLine": true
    }
  ],
  "one-var": [
    "error",
    "never"
  ],
  "@stylistic/one-var-declaration-per-line": [
    "error",
    "always"
  ],
  "operator-assignment": [
    "error",
    "always"
  ],
  "@stylistic/operator-linebreak": [
    "error",
    "before",
    {
      "overrides": {
        "=": "none"
      }
    }
  ],
  "@stylistic/padded-blocks": [
    "error",
    {
      "blocks": "never",
      "classes": "never",
      "switches": "never"
    },
    {
      "allowSingleLineBlocks": true
    }
  ],
  "prefer-exponentiation-operator": "error",
  "prefer-object-spread": "error",
  "@stylistic/quote-props": [
    "error",
    "as-needed",
    {
      "keywords": false,
      "unnecessary": true,
      "numbers": false
    }
  ],
  "@stylistic/quotes": [
    "error",
    "single",
    {
      "avoidEscape": true
    }
  ],
  "require-jsdoc": "off",
  "@stylistic/semi": [
    "error",
    "always"
  ],
  "@stylistic/semi-spacing": [
    "error",
    {
      "before": false,
      "after": true
    }
  ],
  "@stylistic/semi-style": [
    "error",
    "last"
  ],
  "sort-keys": [
    "off",
    "asc",
    {
      "caseSensitive": false,
      "natural": true
    }
  ],
  "sort-vars": "off",
  "@stylistic/space-before-blocks": "error",
  "@stylistic/space-before-function-paren": [
    "error",
    {
      "anonymous": "always",
      "named": "never",
      "asyncArrow": "always"
    }
  ],
  "@stylistic/space-in-parens": [
    "error",
    "never"
  ],
  "@stylistic/space-infix-ops": "error",
  "@stylistic/space-unary-ops": [
    "error",
    {
      "words": true,
      "nonwords": false,
      "overrides": {}
    }
  ],
  "@stylistic/spaced-comment": [
    "error",
    "always",
    {
      "line": {
        "exceptions": [
          "-",
          "+"
        ],
        "markers": [
          "=",
          "!",
          "/"
        ]
      },
      "block": {
        "exceptions": [
          "-",
          "+"
        ],
        "markers": [
          "=",
          "!",
          ":",
          "::"
        ],
        "balanced": true
      }
    }
  ],
  "@stylistic/switch-colon-spacing": [
    "error",
    {
      "after": true,
      "before": false
    }
  ],
  "@stylistic/template-tag-spacing": [
    "error",
    "never"
  ],
  "unicode-bom": [
    "error",
    "never"
  ],
  "@stylistic/wrap-regex": "off",
  "init-declarations": "off",
  "no-catch-shadow": "off",
  "no-delete-var": "error",
  "no-label-var": "error",
  "no-restricted-globals": [
    "error",
    {
      "name": "isFinite",
      "message": "Use Number.isFinite instead https://github.com/airbnb/javascript#standard-library--isfinite"
    },
    {
      "name": "isNaN",
      "message": "Use Number.isNaN instead https://github.com/airbnb/javascript#standard-library--isnan"
    },
    "addEventListener",
    "blur",
    "close",
    "closed",
    "confirm",
    "defaultStatus",
    "defaultstatus",
    "event",
    "external",
    "find",
    "focus",
    "frameElement",
    "frames",
    "history",
    "innerHeight",
    "innerWidth",
    "length",
    "location",
    "locationbar",
    "menubar",
    "moveBy",
    "moveTo",
    "name",
    "onblur",
    "onerror",
    "onfocus",
    "onload",
    "onresize",
    "onunload",
    "open",
    "opener",
    "opera",
    "outerHeight",
    "outerWidth",
    "pageXOffset",
    "pageYOffset",
    "parent",
    "print",
    "removeEventListener",
    "resizeBy",
    "resizeTo",
    "screen",
    "screenLeft",
    "screenTop",
    "screenX",
    "screenY",
    "scroll",
    "scrollbars",
    "scrollBy",
    "scrollTo",
    "scrollX",
    "scrollY",
    "self",
    "status",
    "statusbar",
    "stop",
    "toolbar",
    "top"
  ],
  "no-shadow": "error",
  "no-shadow-restricted-names": "error",
  "no-undef": "error",
  "no-undef-init": "error",
  "no-undefined": "off",
  "no-unused-vars": [
    "error",
    {
      "vars": "all",
      "args": "after-used",
      "ignoreRestSiblings": true
    }
  ],
  "no-use-before-define": [
    "error",
    {
      "functions": true,
      "classes": true,
      "variables": true
    }
  ],
  "arrow-body-style": [
    "error",
    "as-needed",
    {
      "requireReturnForObjectLiteral": false
    }
  ],
  "@stylistic/arrow-parens": [
    "error",
    "always"
  ],
  "@stylistic/arrow-spacing": [
    "error",
    {
      "before": true,
      "after": true
    }
  ],
  "constructor-super": "error",
  "@stylistic/generator-star-spacing": [
    "error",
    {
      "before": false,
      "after": true
    }
  ],
  "no-class-assign": "error",
  "@stylistic/no-confusing-arrow": [
    "error",
    {
      "allowParens": true
    }
  ],
  "no-const-assign": "error",
  "no-dupe-class-members": "error",
  "no-duplicate-imports": "off",
  "no-new-native-nonconstructor": "error",
  "no-restricted-exports": [
    "error",
    {
      "restrictedNamedExports": [
        "default",
        "then"
      ]
    }
  ],
  "no-restricted-imports": [
    "off",
    {
      "paths": [],
      "patterns": []
    }
  ],
  "no-this-before-super": "error",
  "no-useless-computed-key": "error",
  "no-useless-constructor": "error",
  "no-useless-rename": [
    "error",
    {
      "ignoreDestructuring": false,
      "ignoreImport": false,
      "ignoreExport": false
    }
  ],
  "no-var": "error",
  "object-shorthand": [
    "error",
    "always",
    {
      "ignoreConstructors": false,
      "avoidQuotes": true
    }
  ],
  "prefer-arrow-callback": [
    "error",
    {
      "allowNamedFunctions": false,
      "allowUnboundThis": true
    }
  ],
  "prefer-const": [
    "error",
    {
      "destructuring": "any",
      "ignoreReadBeforeAssign": true
    }
  ],
  "prefer-destructuring": [
    "error",
    {
      "VariableDeclarator": {
        "array": false,
        "object": true
      },
      "AssignmentExpression": {
        "array": true,
        "object": false
      }
    },
    {
      "enforceForRenamedProperties": false
    }
  ],
  "prefer-numeric-literals": "error",
  "prefer-reflect": "off",
  "prefer-rest-params": "error",
  "prefer-spread": "error",
  "prefer-template": "error",
  "require-yield": "error",
  "@stylistic/rest-spread-spacing": [
    "error",
    "never"
  ],
  "sort-imports": [
    "off",
    {
      "ignoreCase": false,
      "ignoreDeclarationSort": false,
      "ignoreMemberSort": false,
      "memberSyntaxSortOrder": [
        "none",
        "all",
        "multiple",
        "single"
      ]
    }
  ],
  "symbol-description": "error",
  "@stylistic/template-curly-spacing": "error",
  "@stylistic/yield-star-spacing": [
    "error",
    "after"
  ],
  "import/no-unresolved": [
    "error",
    {
      "commonjs": true,
      "caseSensitive": true
    }
  ],
  "import/named": "error",
  "import/default": "off",
  "import/namespace": "off",
  "import/export": "error",
  "import/no-named-as-default": "error",
  "import/no-named-as-default-member": "error",
  "import/no-deprecated": "off",
  "import/no-extraneous-dependencies": [
    "error",
    {
      "devDependencies": [
        "test/**",
        "tests/**",
        "spec/**",
        "**/__tests__/**",
        "**/__mocks__/**",
        "test.{js,jsx}",
        "test-*.{js,jsx}",
        "**/*{.,_}{test,spec}.{js,jsx}",
        "**/jest.config.js",
        "**/jest.setup.js",
        "**/vue.config.js",
        "**/webpack.config.js",
        "**/webpack.config.*.js",
        "**/rollup.config.js",
        "**/rollup.config.*.js",
        "**/gulpfile.js",
        "**/gulpfile.*.js",
        "**/Gruntfile{,.js}",
        "**/protractor.conf.js",
        "**/protractor.conf.*.js",
        "**/karma.conf.js",
        "**/.eslintrc.js"
      ],
      "optionalDependencies": false
    }
  ],
  "import/no-mutable-exports": "error",
  "import/no-commonjs": "off",
  "import/no-amd": "error",
  "import/no-nodejs-modules": "off",
  "import/first": "error",
  "import/imports-first": "off",
  "import/no-duplicates": "error",
  "import/no-namespace": "off",
  "import/extensions": [
    "error",
    "ignorePackages",
    {
      "js": "never",
      "mjs": "never",
      "jsx": "never"
    }
  ],
  "import/order": [
    "error",
    {
      "groups": [
        [
          "builtin",
          "external",
          "internal"
        ]
      ]
    }
  ],
  "import/newline-after-import": "error",
  "import/prefer-default-export": "error",
  "import/no-restricted-paths": "off",
  "import/max-dependencies": [
    "off",
    {
      "max": 10
    }
  ],
  "import/no-absolute-path": "error",
  "import/no-dynamic-require": "error",
  "import/no-internal-modules": [
    "off",
    {
      "allow": []
    }
  ],
  "import/unambiguous": "off",
  "import/no-webpack-loader-syntax": "error",
  "import/no-unassigned-import": "off",
  "import/no-named-default": "error",
  "import/no-anonymous-default-export": [
    "off",
    {
      "allowArray": false,
      "allowArrowFunction": false,
      "allowAnonymousClass": false,
      "allowAnonymousFunction": false,
      "allowLiteral": false,
      "allowObject": false
    }
  ],
  "import/exports-last": "off",
  "import/group-exports": "off",
  "import/no-default-export": "off",
  "import/no-named-export": "off",
  "import/no-self-import": "error",
  "import/no-cycle": [
    "error",
    {
      "maxDepth": "∞"
    }
  ],
  "import/no-useless-path-segments": [
    "error",
    {
      "commonjs": true
    }
  ],
  "import/dynamic-import-chunkname": [
    "off",
    {
      "importFunctions": [],
      "webpackChunknameFormat": "[0-9a-zA-Z-_/.]+"
    }
  ],
  "import/no-relative-parent-imports": "off",
  "import/no-unused-modules": [
    "off",
    {
      "ignoreExports": [],
      "missingExports": true,
      "unusedExports": true
    }
  ],
  "import/no-import-module-exports": [
    "error",
    {
      "exceptions": []
    }
  ],
  "import/no-relative-packages": "error",
  "strict": [
    "error",
    "never"
  ]
};
