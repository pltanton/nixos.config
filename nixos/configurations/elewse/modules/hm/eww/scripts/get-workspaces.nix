{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "get-workspaces";
  runtimeInputs = with pkgs; [ jq socat ];
  text = ''
    # shellcheck disable=SC2034
    spaces (){
    	WORKSPACE_WINDOWS=$(hyprctl workspaces -j | jq 'map({key: .id | tostring, value: .windows}) | from_entries')
    	seq 1 10 | jq --argjson windows "''${WORKSPACE_WINDOWS}" --slurp -Mc 'map(tostring) | map({id: ., windows: ($windows[.]//0)})'
    }
    spaces
    socat -u UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock - | while read -r; do
    	spaces
    done;
  '';
}