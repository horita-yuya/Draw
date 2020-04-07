.PHONY: bundle
bundle:
	rbenv exec bundle install --path vendor/bundle

.PHONY: pod-release
pod-release:
	rbenv exec bundle exec pod trunk push DrawingKit.podspec