#!/usr/bin/env bats

function artillery() {
  if [ -n "ISTANBUL" ]
  then
    istanbul cover ./bin/artillery "$@"
  else
    ./bin/artillery "$@"
  fi
}

@test "If we report specifying output, no browser is opened" {
  HTML_OUT=`mktemp`
  ./bin/artillery report -o $HTML_OUT test/scripts/report.json | grep "Report generated: $HTML_OUT"
  [ $? -eq 0 ]
  [ -f $HTML_OUT ]
}

@test "Running with no arguments prints out usage information" {
  ./bin/artillery | grep Usage
  [ $? -eq 0 ]
}

@test "artillery -V prints the right version number" {
  version1=$(./bin/artillery -V)
  version2=$(grep version package.json | tr -d '"version:, ''"')
  [[ $version1 = $version2 ]]
}

@test "Running with no target and no -e should exit with an error" {
  ./bin/artillery run test/scripts/environments.json | grep "No target"
  [ $? -eq 0 ]
}

@test "Can run a quick HTTP test with 'artillery quick'" {
  ./bin/artillery quick -d 10 -r 1 -o `mktemp` https://artillery.io | grep 'all scenarios completed'
  [ $? -eq 0 ]
}

@test "Can specify output filename for artillery quick" {
  JSON_REPORT=`mktemp`
  ./bin/artillery quick -d 1 -r 1 -o $JSON_REPORT https://artillery.io | grep "Log file: $JSON_REPORT"
  [ $? -eq 0 ]
}

@test "Run a simple script" {
  ./bin/artillery run ./test/scripts/hello.json | grep 'all scenarios completed'
  [ $? -eq 0 ]
}

@test "Run a script with one payload" {
  ./bin/artillery run ./test/scripts/single_payload.json -p ./test/scripts/pets.csv | grep 'all scenarios completed'
  [ $? -eq 0 ]
}

@test "Run a script with multiple payloads" {
  ./bin/artillery run ./test/scripts/multiple_payloads.json | grep 'all scenarios completed'
  [ $? -eq 0 ]
}

@test "Run a script using default options (output)" {
  ./bin/artillery run ./test/scripts/hello.json | grep "Log file: artillery_report_*"
  [ $? -eq 0 ]
}

@test "Run a script overwriting default options (output)" {
  ./bin/artillery run ./test/scripts/hello.json -o artillery_report_custom | grep 'Log file: artillery_report_custom.json'
  [ $? -eq 0 ]
}
