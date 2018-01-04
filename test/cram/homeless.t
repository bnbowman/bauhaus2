
Check that UNIXHOME is not used in any cram test (sometimes it sneaks in there
when someone updates the test ouput)

  $ grep UNIXHOME ${TESTDIR}/../* -R --exclude=homeless.t --exclude=*.t.err
  [1]
