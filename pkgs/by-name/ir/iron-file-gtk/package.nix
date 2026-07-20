{
  lib,
  fetchFromGitHub,
  gtk4,
  makeWrapper,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "iron-file-gtk";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "benedikt-weyer";
    repo = "iron-file";
    rev = "ac26d99f2761043378f23ed77b829761e7261664";
    hash = "sha256-TGFFBxlzbEuudH6+tiPbI48Un9sTUVjLsHbKPw1ZO3s=";
  };

  cargoHash = "sha256-WnViXYDX2xq3qlXS+c0OcwWgOWWrc65MIhUHLafDTaE=";

  cargoBuildFlags = [
    "--package"
    "iron-file-gtk"
    "--package"
    "iron-file-backend"
  ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [ gtk4 ];

  postInstall = ''
    install -Dm755 "$out/bin/iron-file-backend" \
      "$out/libexec/iron-file/iron-file-backend"
    rm "$out/bin/iron-file-backend"
  '';

  preFixup = ''
    wrapProgram "$out/bin/iron-file-gtk" \
      --set IRON_FILE_BACKEND_MODE prod \
      --set IRON_FILE_BACKEND_BIN "$out/libexec/iron-file/iron-file-backend"
  '';

  doCheck = false;

  meta = {
    description = "File browser built with GTK4";
    homepage = "https://github.com/benedikt-weyer/iron-file";
    license = lib.licenses.mit;
    mainProgram = "iron-file-gtk";
    platforms = lib.platforms.linux;
  };
})
