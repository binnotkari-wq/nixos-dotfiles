{ config, lib, pkgs, ... }:

{
  # Gestion de l'énergie et des fréquences
  # Le driver amd_pstate est bien plus efficace que l'ancien acpi-cpufreq sur Zen 2+
  # Active le support du Precision Boost et la gestion thermique
  boot.kernelParams = [ "amd_pstate=active" ];
  boot.kernelModules = [ "amd-pstate" "msr" ];
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
}
