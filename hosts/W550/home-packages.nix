# W550 用户级软件包（Home Manager 管理）。
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    firefox-esr
    obs-studio
    # google-chrome
    # ungoogled-chromium
    qutebrowser
    prismlauncher
    localsend
    imv
    mpv
    # vlc
    fluffychat

    zip
    xz
    unzip
    p7zip
    nmap

    ddcutil
    wl-clipboard
    gpu-screen-recorder
    brightnessctl
    cliphist
    matugen
    cava
    wlsunset
    bluez

    tuigreet

    # alacritty
    # ghostty
    openvpn
    xwayland-satellite

    inetutils
    neovim
    helix
    yazi
    btop
    fastfetch

    s-tui
    stress
    dmidecode

    gcc
    gdb

    android-tools
    docker-compose
  ];
}
