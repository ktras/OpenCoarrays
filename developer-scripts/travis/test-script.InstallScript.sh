#!/usr/bin/env bash

set -o errexit
set -o verbose
set -o pipefail
set -o nounset
set -o errtrace

__file=developer-scripts/travis/test-script.InstallScript.sh

# Error tracing
# requires `set -o errtrace`
__caf_err_report() {
  local error_code
  error_code=${?}
  echo "Error (code=${error_code}) in ${__file} in function ${1} on line ${2}." >&2
  false
  return ${error_code}
}
# Always provide an error backtrace
trap '__caf_err_report "${FUNCNAME:-.}" ${LINENO}' ERR

echo "Performing Travis-CI script phase for the OpenCoarrays installation script..."

./install.sh --yes-to-all -i "${HOME}/opencoarrays" -j 4 -f "$(type -P "${FC}")" -c "$(type -P "${CC}")" -C "$(type -P "${CXX}")"
if [[ -x "prerequisites/installations/cmake/*/bin/ctest" ]] ;then
    "prerequisites/installations/cmake/*/bin/ctest" --output-on-failure --schedule-random --repeat-until-fail "${NREPEAT:-5}"
else
    ctest --output-on-failure --schedule-random --repeat-until-fail "${NREPEAT:-5}"
fi

echo "Done."