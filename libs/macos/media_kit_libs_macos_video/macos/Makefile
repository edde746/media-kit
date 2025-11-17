all: Frameworks/*.xcframework Frameworks/.symlinks

MPV_XCFRAMEWORKS_VERSION=0.40.0-fix-9

TAR=tar
TAR_WILDCARDS_FLAG := $(shell ${TAR} --version 2>&1 | grep -q 'GNU' && echo "--wildcards" || echo "")

SED=sed
SED_INPLACE_FLAG := $(shell ${SED} --version 2>&1 | grep -q 'GNU' && echo "" || echo "''")

# Core mpv and FFmpeg frameworks from main MPVKit release (audio + video)
MPVKIT_FRAMEWORKS = Libmpv Libavcodec Libavdevice Libavfilter Libavformat Libavutil Libswresample Libswscale

# Video-specific frameworks from various MPVKit repositories (based on Package.swift)
EXTRA_FRAMEWORKS = \
	Libass:https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libass.xcframework.zip \
	Libuchardet:https://github.com/mpvkit/libuchardet-build/releases/download/0.0.8/Libuchardet.xcframework.zip \
	MoltenVK:https://github.com/mpvkit/moltenvk-build/releases/download/1.4.0-fix/MoltenVK.xcframework.zip \
	Libplacebo:https://github.com/mpvkit/libplacebo-build/releases/download/7.351.0-fix/Libplacebo.xcframework.zip \
	Libfreetype:https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libfreetype.xcframework.zip \
	Libfribidi:https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libfribidi.xcframework.zip \
	Libharfbuzz:https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libharfbuzz.xcframework.zip \
	gmp:https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/gmp.xcframework.zip \
	Libuavs3d:https://github.com/mpvkit/libuavs3d-build/releases/download/1.2.1/Libuavs3d.xcframework.zip \
	Libshaderc_combined:https://github.com/mpvkit/libshaderc-build/releases/download/2025.4.0/Libshaderc_combined.xcframework.zip \
	Libluajit:https://github.com/mpvkit/libluajit-build/releases/download/2.1.0/Libluajit.xcframework.zip \
	Libunibreak:https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libunibreak.xcframework.zip \
	gnutls:https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/gnutls.xcframework.zip \
	nettle:https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/nettle.xcframework.zip \
	hogweed:https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/hogweed.xcframework.zip \
	lcms2:https://github.com/mpvkit/libplacebo-build/releases/download/7.349.0/lcms2.xcframework.zip \
	Libdav1d:https://github.com/mpvkit/libdav1d-build/releases/download/1.4.3/Libdav1d.xcframework.zip \
	Libdovi:https://github.com/mpvkit/libdovi-build/releases/download/3.3.0/Libdovi.xcframework.zip \
	Libbluray:https://github.com/mpvkit/libbluray-build/releases/download/1.3.4/Libbluray.xcframework.zip

# Download all frameworks
.cache/xcframeworks/all-frameworks.done:
	mkdir -p .cache/xcframeworks
	rm -f .cache/xcframeworks/*.tmp .cache/xcframeworks/*.done
	@echo "Downloading core MPVKit frameworks..."
	@for framework in $(MPVKIT_FRAMEWORKS); do \
		echo "  Downloading $$framework.xcframework..."; \
		curl -L "https://github.com/edde746/MPVKit/releases/download/${MPV_XCFRAMEWORKS_VERSION}/$$framework-GPL.xcframework.zip" \
			-o .cache/xcframeworks/$$framework.zip.tmp; \
		mv .cache/xcframeworks/$$framework.zip.tmp .cache/xcframeworks/$$framework.xcframework.zip; \
	done
	@echo "Downloading video-specific frameworks..."
	@for entry in $(EXTRA_FRAMEWORKS); do \
		framework=$$(echo $$entry | cut -d: -f1); \
		url=$$(echo $$entry | cut -d: -f2-); \
		echo "  Downloading $$framework.xcframework..."; \
		curl -L "$$url" -o .cache/xcframeworks/$$framework.zip.tmp; \
		mv .cache/xcframeworks/$$framework.zip.tmp .cache/xcframeworks/$$framework.xcframework.zip; \
	done
	touch .cache/xcframeworks/all-frameworks.done

Frameworks/*.xcframework: .cache/xcframeworks/all-frameworks.done
	mkdir -p Frameworks
	rm -rf Frameworks/*.xcframework Frameworks/*.framework
	@echo "Installing core MPVKit frameworks..."
	@for framework in $(MPVKIT_FRAMEWORKS); do \
		echo "  Installing $$framework.xcframework..."; \
		unzip -q .cache/xcframeworks/$$framework.xcframework.zip -d Frameworks; \
		if [ "$$framework" = "Libmpv" ]; then \
			mv Frameworks/$$framework.xcframework Frameworks/Mpv.xcframework; \
			echo "  Renaming Libmpv.framework to Mpv.framework inside XCFramework..."; \
			find Frameworks/Mpv.xcframework -name "Libmpv.framework" -execdir sh -c 'mv Libmpv.framework Mpv.framework && mv Mpv.framework/Libmpv Mpv.framework/Mpv' \;; \
			echo "  Converting static Mpv framework to dynamic library..."; \
			for mpv_framework in $$(find Frameworks/Mpv.xcframework -name "Mpv.framework"); do \
				mpv_binary="$$mpv_framework/Mpv"; \
				if [ -f "$$mpv_binary" ]; then \
					echo "    Converting $$mpv_binary to dynamic library..."; \
					temp_dir=$$(mktemp -d); \
					cd "$$temp_dir"; \
					ar -x "$$mpv_binary"; \
					clang -shared -fPIC \
						-arch arm64 -arch x86_64 \
						-mmacosx-version-min=10.9 \
						-install_name "@rpath/Mpv.framework/Mpv" \
						*.o -o Mpv_dynamic 2>/dev/null || echo "    Warning: Failed to convert $$mpv_binary"; \
					if [ -f Mpv_dynamic ]; then \
						mv Mpv_dynamic "$$mpv_binary"; \
						echo "    Successfully converted $$mpv_binary"; \
					fi; \
					cd - >/dev/null; \
					rm -rf "$$temp_dir"; \
				fi; \
			done; \
		fi; \
	done
	@echo "Installing video-specific frameworks..."
	@for entry in $(EXTRA_FRAMEWORKS); do \
		framework=$$(echo $$entry | cut -d: -f1); \
		echo "  Installing $$framework.xcframework..."; \
		unzip -q .cache/xcframeworks/$$framework.xcframework.zip -d Frameworks; \
		if [ "$$framework" = "MoltenVK" ]; then \
			echo "  MoltenVK is a static library, copying to Frameworks root"; \
			cp Frameworks/$$framework.xcframework/macos-arm64_x86_64/libMoltenVK.a Frameworks/; \
		fi; \
	done
	touch Frameworks/*.xcframework

Frameworks/.symlinks: Frameworks/*.xcframework
	rm -rf Frameworks/.symlinks
	mkdir -p Frameworks/.symlinks/mpv
	${SED} -i ${SED_INPLACE_FLAG} 's/\r$$//g' create_framework_symlinks.sh # remove CRLF line terminator added by Flutter packaging (https://github.com/media-kit/media-kit/issues/338)
	sh create_framework_symlinks.sh Frameworks/Mpv.xcframework/macos-arm64_x86_64/Mpv.framework Frameworks/.symlinks/mpv

.PHONY: clean
clean:
	rm -rf .cache
	rm -f ./Headers/mpv/*.h
	rm -rf ./Frameworks/*.xcframework ./Frameworks/*.framework