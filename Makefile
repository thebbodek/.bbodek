.PHONY: all ssh aws keys editor

# Default target
all: ssh aws keys editor

# SSH Configuration
ssh:
	@read -p "Do you want to proceed with SSH configuration? (y/n): " answer; \
	if [ "$$answer" = "y" ] || [ "$$answer" = "Y" ]; then \
		echo "Configuring SSH..."; \
		if [ -f ~/.ssh/config ]; then \
			if ! grep -q "^Include ~/.bbodek/ssh/config" ~/.ssh/config; then \
				sed -i '' '1i\
# Added by .bbodek/Makefile\
Include ~/.bbodek/ssh/config\
\
' ~/.ssh/config; \
			fi \
		else \
			echo "Include ~/.bbodek/ssh/config" > ~/.ssh/config; \
			chmod 600 ~/.ssh/config; \
		fi; \
		echo "SSH configured"; \
	else \
		echo "SSH configuration skipped"; \
	fi

# AWS Configuration
aws:
	@read -p "Do you want to proceed with AWS configuration? (y/n): " answer; \
	if [ "$$answer" = "y" ] || [ "$$answer" = "Y" ]; then \
		echo "Configuring AWS..."; \
		mkdir -p ~/.aws; \
		( \
			echo "### BBODEK ###"; \
			infisical run --env=local --path=/org -- envsubst < ~/.bbodek/aws/credentials.local.template; \
			echo ""; \
			infisical run --env=dev --path=/org -- envsubst < ~/.bbodek/aws/credentials.dev.template; \
			echo ""; \
			infisical run --env=prod --path=/org -- envsubst < ~/.bbodek/aws/credentials.prod.template; \
			echo "### BBODEK ###"; \
		) > ~/.bbodek/aws/credentials.temp; \
		if grep -q "### BBODEK ###" ~/.aws/credentials; then \
			echo "Overwriting ~/.bbodek/aws/credentials.*.template -> ~/.aws/credentials"; \
			START_LINE=$$(grep -n "### BBODEK ###" ~/.aws/credentials | head -1 | cut -d: -f1); \
			END_LINE=$$(grep -n "### BBODEK ###" ~/.aws/credentials | tail -1 | cut -d: -f1); \
			head -n $$((START_LINE-1)) ~/.aws/credentials > ~/.aws/credentials.tmp; \
			cat ~/.bbodek/aws/credentials.temp >> ~/.aws/credentials.tmp; \
			tail -n +$$((END_LINE+1)) ~/.aws/credentials >> ~/.aws/credentials.tmp; \
			mv ~/.aws/credentials.tmp ~/.aws/credentials; \
		else \
			echo "Appending ~/.bbodek/aws/credentials.*.template -> ~/.aws/credentials"; \
			cat ~/.bbodek/aws/credentials.temp >> ~/.aws/credentials; \
		fi; \
		rm ~/.bbodek/aws/credentials.temp; \
		echo "AWS configured"; \
	else \
		echo "AWS configuration skipped"; \
	fi

# Keys Configuration
keys:
	@read -p "Do you want to proceed with keys configuration? (y/n): " answer; \
	if [ "$$answer" = "y" ] || [ "$$answer" = "Y" ]; then \
		echo "Configuring keys..."; \
		for template in ~/.bbodek/keys/*.pem.template; do \
			if [ -f "$$template" ]; then \
				output_file="$${template%.template}"; \
				echo "Processing $$template -> $$output_file"; \
				touch "$$output_file"; \
				chmod 600 "$$output_file"; \
				infisical run --env=local --path=/_keys -- envsubst < "$$template" > "$$output_file"; \
				chmod 400 "$$output_file"; \
			fi \
		done; \
		echo "Keys configured"; \
	else \
		echo "Keys configuration skipped"; \
	fi

# Editor Configuration
editor:
	@read -p "Do you want to proceed with editor configuration? (y/n): " answer; \
	if [ "$$answer" = "y" ] || [ "$$answer" = "Y" ]; then \
		echo "Configuring editor..."; \
		CURSOR_SUPPORT_DIR="$$HOME/Library/Application Support/Cursor"; \
		if [ -d "$$CURSOR_SUPPORT_DIR" ]; then \
			mkdir -p "$$CURSOR_SUPPORT_DIR/User/snippets"; \
			SNIPPET_TARGET="$$CURSOR_SUPPORT_DIR/User/snippets/global.code-snippets"; \
			if [ -e "$$SNIPPET_TARGET" ] || [ -L "$$SNIPPET_TARGET" ]; then \
				read -p "[WARNING] A file already exists! do you want to overwrite? (y/n): " snippet_overwrite_answer; \
				if [ "$$snippet_overwrite_answer" = "y" ] || [ "$$snippet_overwrite_answer" = "Y" ]; then \
					rm "$$SNIPPET_TARGET"; \
					ln -s ~/.bbodek/editor/global.code-snippets "$$SNIPPET_TARGET"; \
				fi \
			else \
				ln -s ~/.bbodek/editor/global.code-snippets "$$SNIPPET_TARGET"; \
			fi \
		fi; \
		echo "Editor configured"; \
	else \
		echo "Editor configuration skipped"; \
	fi 