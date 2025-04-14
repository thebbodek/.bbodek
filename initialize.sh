#!/bin/bash

# ssh
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

# aws
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

# keys
for template in ~/.bbodek/keys/*.pem.template; do
    if [ -f "$template" ]; then
        output_file="${template%.template}"
        echo "Processing $template -> $output_file"
        chmod 600 "$output_file"
        infisical run --env=local --path=/_keys -- envsubst < "$template" > "$output_file"
        chmod 400 "$output_file"
    fi
done
