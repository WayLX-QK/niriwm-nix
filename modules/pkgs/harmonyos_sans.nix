{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "harmonyos-sans";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "WayLX-QK";
    repo = "HarmonyOS_Sans";
    rev = "v${finalAttrs.version}";
    hash = "sha256-I6RUDpNhEfPKp+XKnz1AoGGzRhW4EveN3kQ39ENfvkQ=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 $(find . -name "*.ttf") -t $out/share/fonts/truetype/HarmonyOS_Sans

    runHook postInstall
  '';

  meta = with lib; {
    description = "HarmonyOS Sans font family";
    homepage = "https://github.com/WayLX-QK/HarmonyOS_Sans";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [];
  };
})