{ config, pkgs, ... }:

{
   users.users.david = {
      isNormalUser = true;
      description = "David";
      extraGroups = [ "networkmanager" "wheel" ];
   };

   # Login screen
   services.greetd = {
     enable = true;
     settings = {
       default_session = {
         command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --remember-session";
       };
     };
   };

   # Firewall
   networking.firewall.enable = true;
}
