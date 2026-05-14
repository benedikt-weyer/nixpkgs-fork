{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "openwhispr";
  version = "1.7.0";

  src = fetchurl {
    url = "https://github.com/OpenWhispr/openwhispr/releases/download/v${version}/OpenWhispr-${version}-linux-x86_64.AppImage";
    hash = "sha256-Fugr2nrIkSHwnDZVwtV+CWwZ50PbI0Amrm1VXFcW6K4=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    libsecret
    wl-clipboard
    wtype
    xclip
    xdotool
    ydotool
  ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/open-whispr.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/open-whispr.png \
      -t $out/share/icons/hicolor/256x256/apps

    substituteInPlace $out/share/applications/open-whispr.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} %U'
  '';

  meta = {
    description = "Privacy-first desktop voice dictation, meeting transcription, and notes app";
    longDescription = ''
      OpenWhispr is a cross-platform desktop application for voice dictation,
      meeting transcription, notes, and AI-assisted actions.
    '';
    homepage = "https://github.com/OpenWhispr/openwhispr";
    changelog = "https://github.com/OpenWhispr/openwhispr/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "openwhispr";
    maintainers = [ lib.maintainers."benedikt-weyer" ];
    platforms = [ "x86_64-linux" ];
  };
}
