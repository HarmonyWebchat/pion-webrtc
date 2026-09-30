{
  buildNpmPackage,
  typescript,
}:
let
  package-source = ../../pion-signaling;
  package-manifest =
    builtins.fromJSON
      (builtins.readFile (package-source + "/package.json"));
in
  buildNpmPackage {
    pname = "spacebarchat-sfu-pion";
    version = package-manifest.version;

    nativeBuildInputs = [ typescript ];

    src = package-source;
    npmDepsHash = "sha256-mKI/2S0kaB2Z+r+9tH/KR4wIFfQYnPPd/bmKquuETWU=";
  }
