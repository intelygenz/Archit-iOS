#!/usr/bin/env bash
set -eu

diff-index() {
  git diff-index -p -M --cached HEAD -- "$@"
}

failed=0

test_pattern='\b(fdescribe|fit|fcontext|xdescribe|xit|xcontext)\b'
test_glob='*Tests.swift *Specs.swift'
if diff-index $test_glob | grep '^+' | egrep "$test_pattern" >/dev/null 2>&1
then
  echo "COMMIT REJECTED for fdescribe/fit/fcontext/xdescribe/xit/xcontext." >&2
  echo "Remove focused and disabled tests before committing." >&2
  git grep -E "$test_pattern" $test_glob || true >&2
  echo '----' >&2
  failed=1
fi

misplaced_pattern='misplaced="YES"'
misplaced_glob='*.xib *.storyboard'
if diff-index $misplaced_glob | grep '^+' | egrep "$misplaced_pattern" >/dev/null 2>&1
then
  echo "COMMIT REJECTED for misplaced views. Correct them before committing." >&2
  git grep -E "$misplaced_pattern" $misplaced_glob || true >&2
  echo '----' >&2
  failed=1
fi

exit $failed
