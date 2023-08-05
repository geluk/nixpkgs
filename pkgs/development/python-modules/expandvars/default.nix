{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, setuptools
}:

buildPythonPackage rec {
  pname = "expandvars";
  version = "0.9.0";
  format = "pyproject";

  disabled = pythonOlder "3.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ag54IeVf8atE+MoItQ0rLQHAdqm8l52pQEZ8t/EFxWU=";
  };

  propagatedBuildInputs = [
    setuptools
  ];

  # The PyPi package does not supply any tests
  doCheck = false;

  pythonImportsCheck = [
    "expandvars"
  ];

  meta = with lib; {
    description = "Expand system variables Unix style";
    homepage = "https://github.com/sayanarijit/expandvars";
    license = licenses.mit;
    maintainers = with maintainers; [ geluk ];
  };
}
