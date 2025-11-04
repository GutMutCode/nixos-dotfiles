{ config, lib, pkgs, ... }:

{
  # PostgreSQL service configuration for Phoenix development
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;

    # Allow connections from localhost
    enableTCPIP = true;

    # Authentication configuration
    # Trust local connections for development convenience
    # IMPORTANT: For production, use md5 or scram-sha-256
    authentication = pkgs.lib.mkOverride 10 ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';

    # Initialize with development user and database
    # This ensures the postgres user can access the database
    ensureDatabases = [ ];
    ensureUsers = [
      {
        name = "gmc";
        ensureDBOwnership = true;
      }
    ];
  };
}
