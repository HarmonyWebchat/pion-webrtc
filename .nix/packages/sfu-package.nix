{
  lib,
  buildGo126Module,
  medooze-webrtc-sdp,
}:
buildGo126Module
  (
    finalAttrs:
    {
      pname = "spacebar-webrtc-pion";
      inherit (medooze-webrtc-sdp) version;

      src = ../../pion-sfu;
      vendorHash = "sha256-tthWbVeyM4lw9i1XQO++8yUO9+oNBP44bbXTQTSC/Uk=";

      meta = {
        description = "Spacebar Go WebRTC server";
        homepage = "https://github.com/spacebarchat/pion-webrtc";
        license = lib.licenses.agpl3Plus;
        mainProgram = "pion-sfu";
      };
    }
  )
