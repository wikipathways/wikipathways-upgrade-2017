#! /usr/bin/env nix-shell
#! nix-shell -i bash -p graphviz

# see https://stackoverflow.com/a/246128/5354298
get_script_dir() { echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; }
SCRIPT_DIR=$(get_script_dir)

nix_f="$SCRIPT_DIR/../default.nix"
svg_f="$SCRIPT_DIR/../docs/dependencies.svg"
txt_f="$SCRIPT_DIR/../docs/dependencies.txt"

nix-store -q $(nix-store -r $(nix-instantiate "$nix_f")) --graph | dot -Tsvg > "$svg_f"
nix-store -q $(nix-store -r $(nix-instantiate "$nix_f")) --tree | \
  sed "s/\/nix\/store\/[a-z0-9]*\-//g" | \
  sed "s/\s\[\.\.\.\]//g" \
  > "$txt_f"

sudo chown www-data:wpdevs "$svg_f" "$txt_f"
sudo chmod 664 "$svg_f" "$txt_f"
