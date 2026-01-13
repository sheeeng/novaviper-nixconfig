{
  config,
  lib,
  myLib,
  ...
}:
{
  sops.secrets."wifi.conf" = myLib.secrets.mkSecretFile {
    source = "wifi.conf";
    format = "binary";
    subDir = [
      "hosts"
      "${config.networking.hostName}"
    ];
  };

  networking.wireless.enable = true;

  networking.wireless.interfaces = [ "wlp2s0" ];

  networking.wireless.secretsFile = config.sops.secrets."wifi.conf".path;

  networking.wireless.networks."ext:home_ssid".pskRaw = "ext:home_pskRaw";
}
