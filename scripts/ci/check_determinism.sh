#!/usr/bin/env bash
set -eu

run_file="$(mktemp)"
run_file_2="$(mktemp)"

echo "Running deterministic build/test pass #1"
lake build >/dev/null
lake exe test-runner | sed 's/[0-9][0-9]*ms/<time>/g' >"${run_file}"

echo "Running deterministic build/test pass #2"
lake build >/dev/null
lake exe test-runner | sed 's/[0-9][0-9]*ms/<time>/g' >"${run_file_2}"

if ! diff -u "${run_file}" "${run_file_2}" >/dev/null; then
  echo "Determinism check failed: normalized test output differs between runs."
  diff -u "${run_file}" "${run_file_2}" || true
  exit 1
fi

echo "Determinism check passed."
