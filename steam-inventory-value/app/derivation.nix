{python3Packages}:
with python3Packages;
  buildPythonApplication rec {
    pname = "steam-inventory-value";
    version = "1.0.0";

    # If you have your sources locally, you can specify a path
    src = ./.;

    # Specify runtime dependencies for the package
    propagatedBuildInputs = [flask];

    # Copy template files to the output
    postInstall = ''
      cp -r $src/templates $out/bin/
    '';
  }
