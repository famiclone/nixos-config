{ config, lib, pkgs, ... }:

{
  imports = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "brinstar"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/Kyiv";

   users.users.famiclone = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
		  	neovim
		  	vim
		  	curl
		  	tmux
		  	btop
		 ];
   };

  # List packages installed in system profile. To search, run:
   environment.systemPackages = with pkgs; [
		 zsh
		 git
     vim
     wget
     podman
     podman-compose
		 cockpit
		 samba
   ];
	
	nix.settings.experimental-features = "nix-command flakes";
	
	virtualisation = {
		podman = {
			enable = true;
			dockerCompat = true;
			defaultNetwork.settings = {
				dns_enabled = true;
			};
		};
	
		oci-containers = {
			backend = "podman";
			containers = {
				homepage = {
					image = "ghcr.io/benphelps/homepage:latest";	
					autoStart = true;
					volumes = [
      			"/mnt/storage/config/homepage:/app/config"
      			"/mnt/storage/config/homepage/assets:/app/public/icons"
					];
					ports = [
						"3000:3000"
					];	
				};

				jellyfin = {
					image = "lscr.io/linuxserver/jellyfin:latest";	
					autoStart = true;
					volumes = [
						"/mnt/storage/config/jellyfin:/config"
						"/mnt/storage/storage/movies/tvseries:/data/tvshows"
						"/mnt/storage/storage/movies/movies:/data/movies"
						"/mnt/storage/storage/books:/data/books"
						"/mnt/storage/storage/photos:/data/photos"
						"/mnt/storage/storage/music/_Sorted_:/data/music"
						"/mnt/storage/storage/video:/data/video"
					];
					ports = [
						"8096:8096"
					];	
					environment = {
						PUID = "1000";
						PGID = "1000";
						TZ = "Etc/UTC";
					};
				};

				kavita = {
					image = "jvmilazz0/kavita:latest";	
					autoStart = true;
					volumes = [
						"/mnt/storage/storage/books:/books"
						"/mnt/storage/storage/books/comics:/comics"
						"/mnt/storage/config/kavita:/kavita/config"
					];
					ports = [
						"5009:5000"
					];	
				};

				deluge = {
					image = "lscr.io/linuxserver/deluge:latest";
					autoStart = true;
					volumes = [
						"/mnt/storage/config/deluge:/config"
						"/mnt/storage/storage/downloads:/downloads"
					];
					ports = [
						"8112:8112"
						"6881:6881"
						"6881:6881/udp"
					];
					environment = {
						PUID = "1000";
						PGID = "1000";
						TZ = "Etc/UTC";
						DELUGE_LOGLEVEL = "error";
					};
				};

				slskd = {
					image = "slskd/slskd";	
					autoStart = true;
					volumes = [
						"/mnt/storage/config/slskd:/app"
						"/mnt/storage/storage/music/_Sorted_:/music"
						"/mnt/storage/storage/downloads:/downloads"
					];
					ports = [
						"5030:5030"
						"5031:5031"
						"50300:50300"
					];	
					environment = {
						SLSKD_REMOTE_CONFIGURATION = "true";
					};
				};

				homeassistant = {
					image = "lscr.io/linuxserver/homeassistant:latest";	
					autoStart = true;
					volumes = [
						"/mnt/storage/config/homeassistant:/config"
					];
					ports = [
						"8123:8123"
					];	
					environment = {
						PUID = "1000";
						PGID = "1000";
						TZ = "Etc/UTC";
					};
					extraOptions = [ "--network=host" ];
				};

				navidrome = {
					image = "deluan/navidrome:latest";
					autoStart = true;
					ports = [ "9990:4533" ];
					environment = {
						PUID = "1000";
						PGID = "1000";
						ND_SCANSCHEDULE = "1h";
						ND_LOGLEVEL = "info";
						ND_SESSIONTIMEOUT = "24h";
					};
					volumes = [
						"/mnt/storage/config/navidrome:/data"
						"/mnt/storage/storage/music/_Sorted_:/music:ro"
					];
				};

			#	traefik= {
			#		image = "traefik";
			#		autoStart = true;
			#		cmd = [
			#			"--api.insecure=true"
			#			"--providers.docker=true"
			#			"--providers.docker.exposedbydefault=false"
			#			"--entrypoints.web.address=:80"
			#			"--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
			#			"--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare"
			#			"--certificatesresolvers.letsencrypt.acme.email=denys@famiclone.dev"
			#			# HTTP
			#			"--entrypoints.web.address=:80"
			#			"--entrypoints.web.http.redirections.entrypoint.to=websecure"
			#			"--entrypoints.web.http.redirections.entrypoint.scheme=https"
			#			"--entrypoints.websecure.address=:443"
			#			# HTTPS
			#			"--entrypoints.websecure.http.tls=true"
			#			"--entrypoints.websecure.http.tls.certResolver=letsencrypt"
			#			"--entrypoints.websecure.http.tls.domains[0].main=darkspace.store"
			#			"--entrypoints.websecure.http.tls.domains[0].sans=*darkspace.store"

			#		];
			#		extraOptions = [
			#			# Proxying Traefik itself
			#			"-l=traefik.enable=true"
			#			"-l=traefik.http.routers.traefik.rule=Host(`proxy.darkspace.store`)"
			#			"-l=traefik.http.services.traefik.loadbalancer.server.port=8080"
			#			"-l=homepage.group=Services"
			#			"-l=homepage.name=Traefik"
			#			"-l=homepage.icon=traefik.svg"
			#			"-l=homepage.href=https://proxy.darkspace.store"
			#			"-l=homepage.description=Reverse proxy"
			#			"-l=homepage.widget.type=traefik"
			#			"-l=homepage.widget.url=http://traefik:8080"
			#		];
			#		ports = [
			#			"443:443"
			#			"80:80"
			#		];
			#		environmentFiles = [
			#		];
			#		volumes = [
      #    	"/var/run/podman/podman.sock:/var/run/docker.sock:ro"
			#			"/mnt/storage/config/traefik/acme.json:/acme.json"
			#		];
			#	};
			};
		};
	};

	services = {
		samba = {
			enable = true;
			securityType = "user";
			openFirewall = true;

			shares = {
				storage = {
					path = "/mnt/storage/storage";
					browseable = true;
					readOnly = false;
					guestOk = true;
				};
				config = {
					path = "/mnt/storage/config";
					browseable = true;
					readOnly = false;
					guestOk = true;
				};
			};
		};

		samba-wsdd = {
			enable = true;
			openFirewall = true;
		};
	};

	services.cockpit.enable = true;
	services.cockpit.openFirewall = true;
	services.cockpit.port = 9090;

	programs = {
		zsh = {
			enable = true;
		};
		neovim = {
			enable = true;
			configure = {
				customRC = ''
					set relativenumber
				'';
			};
		};
	};

  services.openssh.enable = true;

  networking.firewall.allowedTCPPorts = [ 
		8123
		80
		443
	];
  networking.firewall.enable = true;
	networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';
  system.stateVersion = "24.05"; # Did you read the comment?
}

