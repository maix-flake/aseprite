{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: (
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      stdenv = pkgs.clangStdenv;
      skia-src = pkgs.fetchzip {
        url = "https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-Linux-Release-x64-libstdc++.zip";
        hash = "sha256-XKezRDn2OYlztMe9P9rhZ3YyQjg/o0qBYRr/kCF8JH8=";
        stripRoot = false;
      };
      aseprite-src = pkgs.fetchzip {
        url = "https://github.com/aseprite/aseprite/releases/download/v1.3.7/Aseprite-v1.3.7-Source.zip";
        hash = "sha256-D3u+LzF0470YmU+vnpzRBn7i4CPUCasRdX7EsUyG5qk=";
        stripRoot = false;
      };
    in {
      packages."x86_64-linux".default = stdenv.mkDerivation {
        name = "aseprite";
        version = "1.3.7";
        src = "${aseprite-src}";
        nativeBuildInputs = with pkgs; [
          clang
          cmake
          unzip
          ninja
          xorg.libX11.dev
          xorg.libXcursor.dev
          xorg.libXi.dev
          xorg.libXi.out
          libGL
          fontconfig
          libwebp
          freetype
          harfbuzz
          mesa
          libglvnd.dev
        ];

        packages = with pkgs; [
          xorg.libX11.dev
          xorg.libXcursor.dev
          xorg.libXi.dev
          xorg.libXi.out
          libglvnd.dev
          xorg.xorgproto.out
          mesa
          libGL
          fontconfig
          libwebp
          openssl.dev
          pkg-config
          freetype
          harfbuzz
        ];

        cmakeFlags = [
          ''-DCMAKE_BUILD_TYPE=RelWithDebInfo''
          ''-DCMAKE_EXE_LINKER_FLAGS:String="-stdlib=libstdc++"''
          ''-DLAF_BACKEND=skia''
          ''-DSKIA_DIR=${skia-src}/''
          ''-DSKIA_LIBRARY_DIR=${skia-src}/out/Release-x64''
          ''-DSKIA_LIBRARY=${skia-src}/out/Release-x64/libskia.a''
          ''-DWEBP_LIBRARIES=${pkgs.libwebp}/lib/libwebp.so''
          ''-DHARFBUZZ_LIBRARY=${pkgs.harfbuzz}/lib/libharfbuzz.so''
          ''-DFREETYPE_LIBRARY=${pkgs.freetype}/lib/libfreetype.so''

          #"-DX11_X11_INCLUDE_PATH=${pkgs.xorg.xorgproto.out}/include/X11"
          #"-DX11_X11_LIB=${pkgs.xorg.libX11.out}/lib/libX11.so"

          #"-DX11_INCLUDE_PATH=${pkgs.xorg.libX11.dev}/include/X11/"

          #"-DX11_Xcursor_INCLUDE_PATH=${pkgs.xorg.libXcursor}/include/"
          #"-DX11_Xcursor_LIB=${pkgs.xorg.libXcursor.out}/lib/libXcursor.so"

          #"-DX11_Xi_INCLUDE_PATH=${pkgs.xorg.libXi.dev}/include/X11/extensions/"
          #"-DX11_Xi_LIB=${pkgs.xorg.libXi}/lib/libXi.so"
        ];
        #buildPhase = ''
        #  #exit 1
        #  mkdir build
        #  cd build
        #  ninja aseprite
        #'';
        installPhase = ''
          mkdir $out
          mkdir $out/bin
          mkdir $out/share
          mkdir $out/share/aseprite
          mkdir $out/share/applications
          mkdir $out/share/mime
          mkdir $out/share/mime/packages
          mv bin/aseprite $out/bin
          mv bin/* $out/share/aseprite
          cp ${./aseprite.desktop} $out/share/applications/
          cp ${./aseprite.xml} $out/share/mime/packages/
        '';
      };
    }
  );
}
