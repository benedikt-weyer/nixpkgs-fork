{
  lib,
  fetchFromGitHub,
  libGL,
  libX11,
  libXcursor,
  libXi,
  libXrandr,
  libXrender,
  libxkbcommon,
  copyDesktopItems,
  makeWrapper,
  makeDesktopItem,
  rustPlatform,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "iron-file";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "benedikt-weyer";
    repo = "iron-file";
    rev = "4f2d099d411254a3ad0890222d3280e236394ebf";
    hash = "sha256-LEZBwGCmdcpR/fh2CVcjef51RxicTo9zABf71ZiknmU=";
  };

  cargoHash = "sha256-WnViXYDX2xq3qlXS+c0OcwWgOWWrc65MIhUHLafDTaE=";

  cargoBuildFlags = [
    "--package"
    "iron-file-iced"
    "--package"
    "iron-file-backend"
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "iron-file";
      desktopName = "Iron File";
      comment = "File browser";
      exec = "iron-file-iced";
      icon = "iron-file";
      categories = [
        "System"
        "FileManager"
      ];
      mimeTypes = [ "inode/directory" ];
    })
  ];

  postInstall = ''
    install -Dm755 "$out/bin/iron-file-backend" \
      "$out/libexec/iron-file/iron-file-backend"
    install -Dm644 ${finalAttrs.src}/assets/iron-file.svg \
      "$out/share/icons/hicolor/scalable/apps/iron-file.svg"
    rm "$out/bin/iron-file-backend"
  '';

  preFixup = ''
    wrapProgram "$out/bin/iron-file-iced" \
      --set IRON_FILE_BACKEND_MODE prod \
      --set IRON_FILE_BACKEND_BIN "$out/libexec/iron-file/iron-file-backend" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libGL
          libX11
          libXcursor
          libXi
          libXrandr
          libXrender
          libxkbcommon
          vulkan-loader
          wayland
        ]
      }"
  '';

  doCheck = false;

  meta = {
    description = "File browser built with Iced";
    homepage = "https://github.com/benedikt-weyer/iron-file";
    license = lib.licenses.mit;
    mainProgram = "iron-file-iced";
    platforms = lib.platforms.linux;
  };
})
