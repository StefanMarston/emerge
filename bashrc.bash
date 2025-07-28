emerge() {
    show_help() {
        cat <<EOF
Usage: emerge [options] <package>

Options:
  -S          Install package
  -C          Remove package
  -s          Search for package
  -i          Show package info
  --sync      Update package lists (apt update)
  -u          Upgrade all packages
  --depclean  Remove unused packages
  -p          Pretend (dry run)
  -h, --help  Show this help message

You will be asked to choose a backend:
  [1] apt
  [2] flatpak
  [3] snap
EOF
    }

    ask_source() {
        echo "Choose source for operation:"
        echo "  [1] apt"
        echo "  [2] flatpak"
        echo "  [3] snap"
        read -rp "Enter choice [1-3]: " CHOSEN_SOURCE
    }
    
    show_dependencies() {
    		printf "\n%-10s %-30s %-50s\n" "Deps" "Usage" "Installation"
    		printf "%-10s %-30s %-50s\n" "──────────" "──────────────────────────────" "──────────────"
    		printf "%-10s %-30s %-50s\n" "apt" "Debian/-based packages"
    		printf "%-10s %-30s %-50s\n" "flatpak" "Install from Flatpak" "emerge -S flatpak (1)"
    		printf "%-10s %-30s %-50s\n" "flathub" "Flatpak repository" "https://flathub.org/setup"
    		printf "%-10s %-30s %-50s\n" "snap" "Install packages from Snap" "https://snapcraft.io/docs/installing-snap-on-ubuntu"
   		 printf "%-10s %-30s %-50s\n" "brew" "Homebrew CLI-tools" "https://brew.sh/"
   		 echo ""
    		echo "Tip: Use 'emerge -S package' and choose [1–3] to install via apt, flatpak or snap."
	}

    cmd="$1"
    shift || true
    args=("$@")

    case "$cmd" in
    	-d|--dep|--dependencies)
            show_dependencies
            ;;
        -h|--help)
            show_help
            ;;
        --sync)
            sudo apt update
            ;;
        -u)
            sudo apt upgrade
            ;;
        --depclean)
            sudo apt autoremove
            ;;
        -p)
            echo "[pretend] Would perform action on: ${args[*]}"
            ;;
        -i|--info)
            if [ -z "${args[*]}" ]; then
                echo "No package specified for info."
                return 1
            fi
            apt show "${args[@]}"
            ;;
        -s|--search)
            if [ -z "${args[*]}" ]; then
                echo "No search term given."
                return 1
            fi
            ask_source
            case "$CHOSEN_SOURCE" in
                1) apt-cache search "${args[@]}" ;;
                2) flatpak search "${args[@]}" ;;
                3) snap search "${args[@]}" ;;
                *) echo "Invalid selection." ;;
            esac
            ;;
        -S)
            if [ -z "${args[*]}" ]; then
                echo "No package specified for installation."
                return 1
            fi
            ask_source
            case "$CHOSEN_SOURCE" in
                1) sudo apt install "${args[@]}" ;;
                2) flatpak install -y flathub "${args[@]}" ;;
                3) sudo snap install "${args[@]}" ;;
                *) echo "Invalid selection." ;;
            esac
            ;;
        -C)
            if [ -z "${args[*]}" ]; then
                echo "No package specified for removal."
                return 1
            fi
            ask_source
            case "$CHOSEN_SOURCE" in
                1) sudo apt remove "${args[@]}" ;;
                2) flatpak uninstall -y "${args[@]}" ;;
                3) sudo snap remove "${args[@]}" ;;
                *) echo "Invalid selection." ;;
            esac
            ;;
        *)
            echo "emerge: unknown or unsupported flag '$cmd'"
            echo "Try 'emerge --help' for more information."
            ;;
    esac
}