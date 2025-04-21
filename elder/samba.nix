{
  enable = true;
  securityType = "user";
  settings = {
    global = {
      workgroup = "WORKGROUP";
      "server string" = "samba-nix";
      "netbios name" = "samba-nix";
      security = "user";
      "guest account" = "nobody";
    };
    shared = {
      path = "/smb/shared";
      browseable = "yes";
      "guest ok" = "no";
      "create mask" = "0644";
      "read only" = "no";
      "directory mask" = "0755";
      public = "yes";
      writeable = "yes";
    };
    readonly = {
      path = "/smb/ro-share";
      browseable = "yes";
      "guest ok" = "no";
      "create mask" = "0644";
      "read only" = "yes";
      "directory mask" = "0755";
      public = "yes";
      writeable = "no";
    };
    ecorous = {
      path = "/smb/ecorous-priv";
      browseable = "yes";
      "create mask" = "0755";
      "directory mask" = "0755";
      "valid users" = "ecorous";
      public = "no";
      writeable = "yes";
    };
    david = {
      path = "/smb/david-priv";
      browseable = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      "valid users" = "david ecorous";
      public = "no";
      writeable = "yes";
    };
    tirfarthoinn = {
      path = "/smb/tirfarthoinn-priv";
      browseable = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      "valid users" = "tirfarthoinn ecorous";
      public = "no";
      writeable = "yes";
    };
    noodle = {
      path = "/smb/noodle-priv";
      browseable = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      "valid users" = "noodle ecorous";
      public = "no";
      writeable = "yes";
    };
  };
}
