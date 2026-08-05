#!/bin/bash

# 1. Set your prefix and search directory ($HOME is safe inside quotes)
PREFIX="kube.42header"
SEARCH_DIR="$HOME/.vscode/extensions"

# 2. Enable nullglob
shopt -s nullglob

# 3. Fill an array with matches (Adding slashes safely here)
MATCHES=("$SEARCH_DIR"/"$PREFIX"*/)

# 4. Disable nullglob
shopt -u nullglob

# 5. Count how many items are in the array
COUNT=${#MATCHES[@]}

# 6. Evaluate the results
if [ "$COUNT" -eq 0 ]; then
    echo "Error: No directory found starting with '$PREFIX'." >&2
    exit 1
elif [ "$COUNT" -gt 1 ]; then
    echo "Error: Ambiguous! Multiple directories found starting with '$PREFIX':" >&2
    printf "  - %s\n" "${MATCHES[@]}" >&2
    exit 1
else
    # Exactly one match found!
    # Save the FULL path so we can write to it later
    TARGET_PATH="${MATCHES[0]}"
    
    echo "Success! Header updated in: $TARGET_PATH"
fi

# 7. Write to the file

echo "" > "${TARGET_PATH}out/src/header.js"
cat > "${TARGET_PATH}out/src/header.js" << EOF
"use strict";
var moment = require("moment");
var delimiters_1 = require("./delimiters");
var genericTemplate = "\n********************************************************************************\n*                                                                              *\n*                                                    ▒▓              ▓▒        *\n*    $FILENAME__________________________________    ▒▒ ▓▓▓        ▓▓▓ ▒▒       *\n*                                                   ▒▒▒░░▒▒░▓░░▓░▒▒░░▒▒▒       *\n*    By: $AUTHOR________________________________     █░  ░░░ ░░ ░░░  ░█        *\n*                                                    ███████░░░░███████        *\n*    Created: $CREATEDAT_________ by $CREATEDBY_    ░▒▒██ ▓  ██  ▓ ██▒▒░       *\n*    Updated: $UPDATEDAT_________ by $UPDATEDBY_        ▒ ░██  ██░ ▒           *\n*                                                          ██████              *\n*                                                                              *\n********************************************************************************\n".substring(1);
var getTemplate = function (languageId) {
    var _a = delimiters_1.languageDemiliters[languageId], left = _a[0], right = _a[1];
    var width = left.length;
    return genericTemplate
        .replace(new RegExp("^(.{" + width + "})(.*)(.{" + width + "})$", 'gm'), left + '$2' + right);
};
var pad = function (value, width) {
    return value.concat(' '.repeat(width)).substr(0, width);
};
var formatDate = function (date) {
    return date.format('YYYY/MM/DD HH:mm:ss');
};
var parseDate = function (date) {
    return moment(date, 'YYYY/MM/DD HH:mm:ss');
};
exports.supportsLanguage = function (languageId) {
    return languageId in delimiters_1.languageDemiliters;
};
exports.extractHeader = function (text) {
    var headerRegex = "^(.{80}\n){10}";
    var match = text.match(headerRegex);
    return match ? match[0] : null;
};
var fieldRegex = function (name) {
    return new RegExp("^((?:.*\\\n)*.*)(\\$" + name + "_*)", '');
};
var getFieldValue = function (header, name) {
    var _a = genericTemplate.match(fieldRegex(name)), _ = _a[0], offset = _a[1], field = _a[2];
    return header.substr(offset.length, field.length);
};
var setFieldValue = function (header, name, value) {
    var _a = genericTemplate.match(fieldRegex(name)), _ = _a[0], offset = _a[1], field = _a[2];
    return header.substr(0, offset.length)
        .concat(pad(value, field.length))
        .concat(header.substr(offset.length + field.length));
};
EOF
