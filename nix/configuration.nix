
  { config, pkgs, lib, ... }:

  {
    imports = ["${fetchTarball "https://github.com/NixOS/nixos-hardware/archive/936e4649098d6a5e0762058cb7687be1b2d90550.tar.gz" }/raspberry-pi/4"];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
        options = [ "noatime" ];
      };
    };

    networking = {
      hostName = "nixpi";
      nat = {
        enable = true;
        externalInterface = "eth0";
        internalInterfaces = [ "wg0" ];
      };
      nftables = {
        enable = true;
        rulesetFile = "/home/admin/nftables_config";
      };
      firewall = {
        enable = false;
        allowedTCPPorts = [ 22 30005 ];
        allowedUDPPorts = [ 30005 ];
      };
    };
  
    networking.wireguard.interfaces = {
      wg0 = {
        ips = [ "10.0.0.0/8" ];
        listenPort = 30005;
    
        postSetup = ''
          ${pkgs.nftables}/bin/nft add rule nat POSTROUTING ip saddr 10.0.0.0/8 oif eth0 masquerade
          '';
        postShutdown = ''
          ${pkgs.nftables}/bin/nft delete rule nat POSTROUTING ip saddr 10.0.0.0/8 oif eth0 masquerade
          '';
    
        privateKeyFile = "/home/admin/wireguard-keys/private";
    
        peers = [
          { # NixTop
            publicKey = "s0oldHe6jxMKQ3SwTboPGlz3tEAZ5NIrQEYY455oajk=";
            allowedIPs = [ "10.0.0.1/32" ];
          }
          { # Android
            publicKey = "sgWsqw4Y3d21XrkysAgxQbLUL3v2YlgJfuMggvvrMU0=";
            allowedIPs = [ "10.0.0.2/32" ];
          }
        ];
      };
    };
  
    environment.systemPackages = with pkgs; [ helix zellij git ];

    services.openssh.enable = true;

    users = {
      mutableUsers = false;
      users."admin" = {
        isNormalUser = true;
        hashedPassword = "$6$Hvo92DeZuMm2FHLO$ux3upNIqSmFKNW3RGr.Bg8c.ea0qdqYjJQ409T8SY0GTH4pnJTjFeGX43fmWGO5bpihwsk6GCcqp2EjqfQTwY.";
        extraGroups = [ "wheel" ];
      	openssh.authorizedKeys.keyFiles = [
      	  ./key1
      	];
      };
      users."guest" = {
        isNormalUser = true;
        password = "guest";
        extraGroups = [ "wheel" ];
      	openssh.authorizedKeys.keyFiles = [
      	  ./key1
      	];
      };
    };

    # Enable GPU acceleration
    hardware.raspberry-pi."4".fkms-3d.enable = true;
  }
