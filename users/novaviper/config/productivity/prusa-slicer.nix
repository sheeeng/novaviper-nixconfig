{
  config,
  myLib,
  pkgs,
  ...
}:
let
  myself = "novaviper";
in
{
  xdg.mimeApps = {
    associations = {
      added = {
        "x-scheme-handler/prusaslicer" = "PrusaSlicerURLProtocol.desktop";
        "model/stl" = "PrusaSlicer.desktop";
      };
    };
    defaultApplications = {
      "x-scheme-handler/prusaslicer" = "PrusaSlicerURLProtocol.desktop";
      "model/stl" = "PrusaSlicer.desktop";
    };
  };

  xdg.configFile = {
    "PrusaSlicer/printer" = myLib.dots.mkDotsSymlink {
      inherit config;
      user = myself;
      source = "PrusaSlicer/printer";
      recursive = true;
    };
    "PrusaSlicer/print" = myLib.dots.mkDotsSymlink {
      inherit config;
      user = myself;
      source = "PrusaSlicer/print";
      recursive = true;
    };
    "PrusaSlicer/physical_printer" = myLib.dots.mkDotsSymlink {
      inherit config;
      user = myself;
      source = "PrusaSlicer/physical_printer";
      recursive = true;
    };
    "PrusaSlicer/filament" = myLib.dots.mkDotsSymlink {
      inherit config;
      user = myself;
      source = "PrusaSlicer/filament";
      recursive = true;
    };
    "PrusaSlicer/bed_models" = myLib.dots.mkDotsSymlink {
      inherit config;
      user = myself;
      source = "PrusaSlicer/bed_models";
      recursive = true;
    };
  };

  home.packages = with pkgs; [ prusa-slicer ];
}
