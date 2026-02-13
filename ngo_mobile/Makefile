.PHONY: help setup clean build run analyze test lint fmt

help:
	@echo "NGO Agent Mobile App - Available Commands"
	@echo "=========================================="
	@echo ""
	@echo "Setup & Install:"
	@echo "  make setup          - Install dependencies & build files"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Development:"
	@echo "  make analyze        - Run flutter analyze"
	@echo "  make lint           - Run linter (included in analyze)"
	@echo "  make fmt            - Format code"
	@echo "  make test           - Run unit tests"
	@echo ""
	@echo "Build & Run:"
	@echo "  make run            - Run on emulator/device"
	@echo "  make run-release    - Run in release mode"
	@echo "  make build-apk      - Build Android APK"
	@echo "  make build-appbundle - Build Android App Bundle"
	@echo "  make build-ios      - Build iOS app"
	@echo ""

setup:
	@echo "📦 Installing Flutter dependencies..."
	flutter pub get
	@echo "🔧 Generating build files..."
	flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
	@echo "✅ Setup complete!"

clean:
	@echo "🗑️  Cleaning build artifacts..."
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/
	@echo "✅ Clean complete!"

analyze:
	@echo "🔍 Running analysis..."
	flutter analyze

lint: analyze
	@echo "✅ Analysis complete!"

fmt:
	@echo "📝 Formatting code..."
	dart format --line-length=100 lib/ test/
	@echo "✅ Formatting complete!"

test:
	@echo "🧪 Running tests..."
	flutter test
	@echo "✅ Tests complete!"

run:
	@echo "🚀 Running app..."
	flutter run

run-release:
	@echo "🚀 Running app (Release mode)..."
	flutter run --release

build-apk:
	@echo "📦 Building Android APK..."
	flutter build apk --release
	@echo "✅ APK built: build/app/outputs/flutter-apk/app-release.apk"

build-appbundle:
	@echo "📦 Building Android App Bundle..."
	flutter build appbundle --release
	@echo "✅ Bundle built: build/app/outputs/bundle/release/app-release.aab"

build-ios:
	@echo "📦 Building iOS app..."
	flutter build ipa --release
	@echo "✅ iOS build complete!"

all: clean setup analyze test
	@echo "✅ All checks passed!"
