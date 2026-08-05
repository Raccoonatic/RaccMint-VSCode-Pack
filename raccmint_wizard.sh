#!/bin/bash

#1. Get the latest VSCode

curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o $HOME/Downloads/vscode_latest.deb

#2. Install VSCode

sudo apt install $HOME/Downloads/vscode_latest.deb

#3. Delete the downloaded file

rm -rf $HOME/Downloads/vscode_latest.deb

#4. Get the RaccMint pack

git clone git@github.com:Raccoonatic/RaccMint-VSCode-Pack.git $HOME/RaccMintPack

#5. Create the VSCode extensions folder if it doesn't exist

mkdir -p $HOME/.vscode/extensions

#6. Install the extensions from the RaccMint pack

xargs -n 1 code --install-extension < $HOME/RaccMintPack/Assets/extensions.txt

#7. Create the VSCode settings folder if it doesn't exist

mkdir -p $HOME/.config/Code/User

#8. Copy the settings.json file from the RaccMint pack to the VSCode settings folder

cp $HOME/RaccMintPack/Config/settings.json $HOME/.config/Code/User

	#8.1. Update the Config files with the local $HOME, $USER, $HEADER_NAME & $HEADER_EMAIL variables.
echo "\nThis pack installs a custom version of the 42 Header, that you can call with CTRL+ALT+H. To personalize it, please enter your name and email below.\n"
read -p "Enter your Name for the Header art: " HEADER_NAME
read -p "Enter your Email for the Header art: " HEADER_EMAIL
export HEADER_NAME
export HEADER_EMAIL
envsubst '$HOME $HEADER_NAME $HEADER_EMAIL' < $HOME/RaccMintPack/Config/settings.json > "$HOME/.config/Code/User/settings.json"

#9. Copy the Custom CSS and JS scripts.

cp $HOME/RaccMintPack/Config/raccmint-custom-vscode.css $HOME/.config/Code/User
cp $HOME/RaccMintPack/Config/raccmint-vscode-script.js $HOME/.config/Code/User

echo "Configuration files deployed and dynamically personalized for $HEADER_NAME!"

#10. Copy the new image .svg for the file explorer.

cp $HOME/RaccMintPack/Assets/minty-icon.svg $HOME/.config/Code/User

#11. Replace the default VSCode pixmap.

sudo cp $HOME/RaccMintPack/Assets/code.png /usr/share/pixmaps

#12. Create local Launcher.

mkdir -p "$HOME/.local/share/applications"
cp /usr/share/applications/code.desktop "$HOME/.local/share/applications/"

#13. Replace the default VSCode icon, name, and comment in the local launcher.

APP_FILE="$HOME/.local/share/applications/code.desktop"
# Replace Icon
sed -i "s|^Icon=.*$|Icon=$HOME/.config/Code/User/minty-icon.svg|" "$APP_FILE"
# Replace Name
sed -i 's/^Name=.*$/Name=RaccMint/' "$APP_FILE"
# Replace Comment
sed -i 's/^Comment=.*$/Comment=Code editing. The Mapache way/' "$APP_FILE"

#14. Unlock the core files for the Custom CSS and JS.

sudo chown -R $USER:$USER /usr/share/code/

#15. Enable the Custom CSS and JS.

	# 15.1. Define the target directory the extension will patch
TARGET_DIR="/usr/share/code/resources/app/out/vs/code/electron-sandbox/workbench"

	# 15.2. Snapshot the current modification time of the folder
OLD_TIME=$(stat -c %Y "$TARGET_DIR" 2>/dev/null || echo "0")

	# 15.3. Fire the ENABLE command
code --open-url "vscode://command/extension.enableCustomCSS"

	# 15.4. The Polling Loop (Wait dynamically until the timestamp changes)
TIMEOUT=20
ELAPSED=0
echo "Waiting for extension to patch core files..."

while [ "$OLD_TIME" -eq "$(stat -c %Y "$TARGET_DIR" 2>/dev/null || echo "0")" ]; do
    sleep 1
    ELAPSED=$((ELAPSED + 1))

    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Warning: Timeout reached. The theme might already be applied or failed."
        break
    fi
done

	# 15.5. File change detected! Safe to kill.
echo "Patch applied successfully! Closing VS Code..."
killall code

#16. Reload the Custom CSS and JS.

	# 16.1. Target directory for the extension's changes
TARGET_DIR="/usr/share/code/resources/app/out/vs/code/electron-sandbox/workbench"

	# 16.2. Snapshot the current timestamp before triggering the reload
OLD_TIME=$(stat -c %Y "$TARGET_DIR" 2>/dev/null || echo "0")

	# 16.3. Fire the RELOAD command via URL handler
code --open-url "vscode://command/extension.updateCustomCSS"

	# 16.4. Dynamic polling loop (waits patiently until the files are successfully rewritten)
TIMEOUT=20
ELAPSED=0
echo "Waiting for custom CSS/JS to reload and patch..."

while [ "$OLD_TIME" -eq "$(stat -c %Y "$TARGET_DIR" 2>/dev/null || echo "0")" ]; do
    sleep 1
    ELAPSED=$((ELAPSED + 1))

    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Warning: Timeout reached. Closing VS Code anyway."
        break
    fi
done

	# 16.5. Safe to close
echo "Reload complete! Closing VS Code..."
killall code

#17. Update 42 header for the RaccMint pack Ascii art.

	# 17.1. Set your prefix and search directory ($HOME is safe inside quotes)
PREFIX="kube.42header"
SEARCH_DIR="$HOME/.vscode/extensions"

	# 17.2. Enable nullglob
shopt -s nullglob

	# 17.3. Fill an array with matches (Adding slashes safely here)
MATCHES=("$SEARCH_DIR"/"$PREFIX"*/)

	# 17.4. Disable nullglob
shopt -u nullglob

	# 17.5. Count how many items are in the array
COUNT=${#MATCHES[@]}

	# 17.6. Evaluate the results
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

	# 17.7. Write to the file
echo "" > "${TARGET_PATH}out/src/header.js"
cat > "${TARGET_PATH}out/src/header.js" << 'EOF'
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
echo "RaccMint pack installed successfully! Coding has never felt so fresh!"
