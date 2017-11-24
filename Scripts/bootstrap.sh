#!/bin/sh
set -eu

read -p "Do you want to install misplaced views and focused tests pre-commit hook? " -n 1 -r
echo
if [[ $REPLY =~ ^[YySs]$ ]]
then
	sh Scripts/install_pre_commit.sh
fi

echo "Verifying Xcode Command Line Tools..."
if ! xcode-select -p ; then
	echo "You need Xcode Command Line Tools for this project, installing..."
	xcode-select --install
fi

echo "Verifying bundler gem..."
if ! gem which bundler ; then
	echo "You need bundler gem for this project, installing..."
	sudo gem install bundler
	echo "Bundler gem installed!"
fi

echo "Installing Swift dependencies..."
swift package resolve
echo "Generating project..."
xcodegen
echo "Installing Ruby dependencies..."
bundle install
echo "Installing CocoaPods dependencies..."
pod install
echo "All dependencies installed!"

read -p "Do you want to use fastlane tools? " -n 1 -r
echo
if [[ $REPLY =~ ^[YySs]$ ]]
then
	echo "Configuring fastlane..."
	bundle exec fastlane init
	echo "Configuring snapshot..."
	bundle exec fastlane snapshot init
	echo "Ready for fastlane tools!"
	
	read -p "Do you want to use danger? " -n 1 -r
	echo
	if [[ $REPLY =~ ^[YySs]$ ]]
	then
		echo "Configuring danger..."
		bundle exec danger init
		echo "Ready for danger!"
	fi
fi

echo "Committing..."
git add .
git commit -qam "First Commit"
echo "Committed!"

echo "Creating qa branch..."
git checkout -b qa
echo "Creating develop branch..."
git checkout -b develop

echo
echo "Everything ready, enjoy your new Intelygenz project! 🍻"
