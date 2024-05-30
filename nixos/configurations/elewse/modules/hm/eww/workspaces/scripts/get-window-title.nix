{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "get-window-title";
  runtimeInputs = with pkgs; [ jq socat coreutils ];
  text = ''
    hyprctl activewindow -j | jq --raw-output .title

    # shellcheck disable=SC2016
    socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - | stdbuf -o0 awk -F '>>|,' '/^activewindow>>/{print $3}'
  '';
}
