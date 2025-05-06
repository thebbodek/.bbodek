#!/bin/bash

CURRENT_DIR=$(pwd)
BBODEK_DIR=$(eval echo ~/.bbodek)

if [ "$CURRENT_DIR" != "$BBODEK_DIR" ]; then
    echo "Error: Current directory is not ~/.bbodek"
    exit 1
fi

# ssh
read -p "Do you want to proceed with SSH configuration? (y/n): " ssh_answer
if [[ "$ssh_answer" == "y" || "$ssh_answer" == "Y" ]]; then
    echo "Configuring SSH..."
    if [ -f ~/.ssh/config ]; then
        if ! grep -q "^Include ~/.bbodek/ssh/config" ~/.ssh/config; then
            sed -i '' '1i\
    # Added by .bbodek/initialize.sh\
    Include ~/.bbodek/ssh/config\
    \
    ' ~/.ssh/config
    fi
    else
        echo "Include ~/.bbodek/ssh/config" > ~/.ssh/config
        chmod 600 ~/.ssh/config
    fi
    echo "SSH configured"
else
    echo "SSH configuration skipped"
fi

# aws
read -p "Do you want to proceed with AWS configuration? (y/n): " aws_answer
if [[ "$aws_answer" == "y" || "$aws_answer" == "Y" ]]; then
    echo "Configuring AWS..."
    mkdir -p ~/.aws
    cat > ~/.bbodek/aws/credentials.temp << EOF
### BBODEK ###

$(infisical run --env=local --path=/org -- envsubst < ~/.bbodek/aws/credentials.local.template)

$(infisical run --env=dev --path=/org -- envsubst < ~/.bbodek/aws/credentials.dev.template)

$(infisical run --env=prod --path=/org -- envsubst < ~/.bbodek/aws/credentials.prod.template)

### BBODEK ###
EOF
    if grep -q "### BBODEK ###" ~/.aws/credentials; then
        echo "Overwriting ~/.bbodek/aws/credentials.*.template -> ~/.aws/credentials"
        START_LINE=$(grep -n "### BBODEK ###" ~/.aws/credentials | head -1 | cut -d: -f1)
        END_LINE=$(grep -n "### BBODEK ###" ~/.aws/credentials | tail -1 | cut -d: -f1)

        head -n $((START_LINE-1)) ~/.aws/credentials > ~/.aws/credentials.tmp
        cat ~/.bbodek/aws/credentials.temp >> ~/.aws/credentials.tmp
        tail -n +$((END_LINE+1)) ~/.aws/credentials >> ~/.aws/credentials.tmp
        mv ~/.aws/credentials.tmp ~/.aws/credentials
    else
        echo "Appending ~/.bbodek/aws/credentials.*.template -> ~/.aws/credentials"
        cat ~/.bbodek/aws/credentials.temp >> ~/.aws/credentials
    fi
    rm ~/.bbodek/aws/credentials.temp
    echo "AWS configured"
else
    echo "AWS configuration skipped"
fi

# keys
read -p "Do you want to proceed with keys configuration? (y/n): " keys_answer
if [[ "$keys_answer" == "y" || "$keys_answer" == "Y" ]]; then
    echo "Configuring keys..."
    for template in ~/.bbodek/keys/*.pem.template; do
        if [ -f "$template" ]; then
            output_file="${template%.template}"
            echo "Processing $template -> $output_file"
            chmod 600 "$output_file"
            infisical run --env=local --path=/_keys -- envsubst < "$template" > "$output_file"
            chmod 400 "$output_file"
        fi
    done
    echo "Keys configured"
else
    echo "Keys configuration skipped"
fi

# editor
read -p "Do you want to proceed with editor configuration? (y/n): " editor_answer
if [[ "$editor_answer" == "y" || "$editor_answer" == "Y" ]]; then
    echo "Configuring editor..."
    CURSOR_SUPPORT_DIR="$HOME/Library/Application Support/Cursor"
    if [ -d "$CURSOR_SUPPORT_DIR" ]; then
        mkdir -p "$CURSOR_SUPPORT_DIR/User/snippets"

        SNIPPET_TARGET="$CURSOR_SUPPORT_DIR/User/snippets/global.code-snippets"

        if [ -e "$SNIPPET_TARGET" ] || [ -L "$SNIPPET_TARGET" ]; then
            read -p "[WARNING] A file already exists! do you want to overwrite? (y/n): " snippet_overwrite_answer
            if [[ "$snippet_overwrite_answer" == "y" || "$snippet_overwrite_answer" == "Y" ]]; then
                rm "$SNIPPET_TARGET"
                ln -s ~/.bbodek/editor/global.code-snippets "$SNIPPET_TARGET"
            fi
        else
            ln -s ~/.bbodek/editor/global.code-snippets "$SNIPPET_TARGET"
        fi
    fi
    echo "Editor configured"
else
    echo "Editor configuration skipped"
fi
