{ lib
, buildPythonPackage
, copyDesktopItems
, fetchurl
, makeDesktopItem
, fetchFromGitHub
, nix-update-script
, python
, baycomp
, bottleneck
, chardet
, cython
, httpx
, joblib
, keyring
, keyrings-alt
, matplotlib
, numpy
, openpyxl
, opentsne
, orange-canvas-core
, orange-widget-base
, pandas
, pyqtgraph
, pyqtwebengine
, python-louvain
, pyyaml
, qt5
, qtconsole
, requests
, scikit-learn
, scipy
, sphinx
, serverfiles
, xlrd
, xlsxwriter
}:

let
self = buildPythonPackage rec {
    pname = "orange3";
    version = "3.35.0";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = "biolab";
      repo = "orange3";
      rev = "refs/tags/${version}";
      hash = "sha256-dj/Z4uOjA4nidd45dnHZDyHZP6Fy/MGC8asqOPV7U7A=";
    };

    postPatch = ''
      sed -i 's;\(scikit-learn\)[^$]*;\1;g' requirements-core.txt
      sed -i 's;pyqtgraph[^$]*;;g' requirements-gui.txt # TODO: remove after bump with a version greater than 0.13.1
    '';

    nativeBuildInputs = [
      copyDesktopItems
      cython
      qt5.wrapQtAppsHook
      sphinx
    ];

    enableParallelBuilding = true;

    propagatedBuildInputs = [
      numpy
      scipy
      chardet
      openpyxl
      opentsne
      qtconsole
      bottleneck
      matplotlib
      joblib
      requests
      keyring
      scikit-learn
      pandas
      pyqtwebengine
      serverfiles
      orange-canvas-core
      python-louvain
      xlrd
      xlsxwriter
      httpx
      pyqtgraph
      orange-widget-base
      keyrings-alt
      pyyaml
      baycomp
    ];

    # FIXME: ImportError: cannot import name '_variable' from partially initialized module 'Orange.data' (most likely due to a circular import) (/build/source/Orange/data/__init__.py)
    doCheck = false;

    pythonImportsCheck = [ "Orange" "Orange.data._variable" ];

    desktopItems = [
      (makeDesktopItem {
        name = "orange";
        exec = "orange-canvas";
        desktopName = "Orange Data Mining";
        genericName = "Data Mining Suite";
        comment = "Explore, analyze, and visualize your data";
        icon = "orange-canvas";
        mimeTypes = [ "application/x-extension-ows" ];
        categories = [ "Science" "Education" "ArtificialIntelligence" "DataVisualization" "NumericalAnalysis" "Qt" ];
        keywords = [ "Machine Learning" "Scientific Visualization" "Statistical Analysis" ];
      })
    ];

    postInstall = ''
      wrapProgram $out/bin/orange-canvas \
        "${"$"}{qtWrapperArgs[@]}"
      mkdir -p $out/share/icons/hicolor/{256x256,48x48}/apps
      cp distribute/icon-256.png $out/share/icons/hicolor/256x256/apps/orange-canvas.png
      cp distribute/icon-48.png $out/share/icons/hicolor/48x48/apps/orange-canvas.png
    '';

    passthru = {
      updateScript = nix-update-script { };
      tests.unittests = self.overridePythonAttrs (old: {
        pname = "${old.pname}-tests";
        format = "other";

        preCheck = ''
          export HOME=$(mktemp -d)
          export QT_PLUGIN_PATH="${qt5.qtbase.bin}/${qt5.qtbase.qtPluginPrefix}"
          export QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins";
          export QT_QPA_PLATFORM=offscreen

          rm Orange -rf
          cp -r ${self}/${python.sitePackages}/Orange .
          chmod +w -R .

          rm Orange/tests/test_url_reader.py # uses network
          rm Orange/tests/test_ada_boost.py # broken: The 'base_estimator' parameter of AdaBoostRegressor must be an object implementing 'fit' and 'predict' or a str among {'deprecated'}. Got None instead.
        '';

        checkPhase = ''
          runHook preCheck
          ${python.interpreter} -m unittest -b -v ./Orange/**/test*.py
          runHook postCheck
        '';

        postInstall = "";

        doBuild = false;
        doInstall = false;

        nativeBuildInputs = [ self ] ++ old.nativeBuildInputs;
      });
    };

    meta = {
      mainProgram = "orange-canvas";
      description = "Data mining and visualization toolbox for novice and expert alike";
      homepage = "https://orangedatamining.com/";
      license = [ lib.licenses.gpl3Plus ];
      maintainers = [ lib.maintainers.lucasew ];
    };
  };
in self
