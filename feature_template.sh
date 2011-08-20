#!/bin/bash

# Feature Template
# This script will ask you all the questions to build a feature. Which one can easily look at the gentoo documentation and copy the information to answer the questions.
# A simple script this one is, so you might have to roll up your sleeves and write some bash code to add any questions the user might need to enter and any case statements.
# Look in the features folder for references.


directory_name="$( cd "$( dirname "$0" )" && pwd )"

function print_step
{
	echo -e "\033[32m* \033[1;37m$1 \033[00m"	
}

function save_variables
{	
	#Done right now.
	# 2 arrays one for variables and the other gentoo_commander paste to scipt and your done!


	variables_array=(
	PACKAGES
	);

	gentoo_commander_array=(
	pre_chroot
	pre_install
	make_config
	use_flags
	post_install
	post_message
	);

	#Just Writing a bash file, which then can be executed by gentoo_deployment.sh, if it in the features folder
	print_step "Creating $filename file"
	print_step "Saving commands in $directory_name/features/$filename"
	echo -e "#!/bin/bash\n\n# $filename\n# $description\n# $URL\n\n" > "$directory_name/features/$filename"

	for name in ${variables_array[@]}; do
		var=`eval echo $\`echo $name\``
		echo "$name=$var" >> "$directory_name/features/$filename"
	done

	for name in ${gentoo_commander_array[@]}; do
		var=`eval echo $\`echo $name\``
		echo "gentoo_commander $name $var" >> "$directory_name/features/$filename"
	done

	print_step "Done!"
}

	echo -e "\n\033[32mFeature Template Script\033[0m - Create bash scripts which can be executed by the gentoo_commander function in gentoo_deployment.sh script\n\n"

	echo "This script is a questionnaire for fulfilling most of the features describe on gentoo.org. There is 9 easy parameters (currently) for what commands should execute and what messages to echo to the user for attention."
	echo "Pick a Gentoo article and collect all the necessary changes (mostly bash commands) to make this feature work."
	echo "All of those changes/bash commands can be place in ALL 9 parameters. Cool huh. However it is your job to concatenate the commands together."
	echo -e "\033[32mExample\033[34m echo \\\"exec ck-launch-session gnome-session\\\" > /root/.xinitrc \033[31m&&\033[1;0m"
	echo -e "Notice: Skip any that don't apply to the feature and encapsulate in \033[31mquotes\033[0m.\n\n"

	echo -e "Filename for the feature. \033[32mExample\033[34m distcc.sh\033[0m"
	read -p "Filename:" filename;

	echo -e "Description for what the feature provides and where to find out more about it"
	read -p "Description:" description;

	echo -e "URL of the article your are copying for a feature. \033[32mExample\033[34m http://www.gentoo.org/doc/en/power-management-guide.xml \033[0m" 	
	read -p "URL:" URL;

	echo -e "\nCommand string of anything that needs to be run before chrooting into a fresh Gentoo install"
	read -p "gentoo_commander pre_chroot " pre_chroot;

	echo -e "\npre_install is for any commands that need to run before packages are emerged for the feature"
	read -p "gentoo_commander pre_install " pre_install;

	echo -e "\nPackages to be emerged";
	read -p "PACKAGES=" PACKAGES;

	echo -e "\nmake_config is usaully left alone. Best to leave as a post_message"
	read -p "gentoo_commander make_config " make_config;

	echo -e "\nuse_flags is the flags necessary to use the feature. Example Gnome needs the use flag \033[34mgtk\033[1;0m"
	read -p "gentoo_commander use_flags " use_flags;

	echo -e "\npost_install is for any commands that need to run after packages are emerged for the feature"
	read -p "gentoo_commander post_install " post_install;

	echo -e "\npost_message is to alert the user in order to use the feature"
	read -p "gentoo_commander post_message " post_message;

	save_variables;


