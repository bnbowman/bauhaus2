Test execution of the IsoSeqRC0 workflow on one very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../..
  $ CWD=`pwd`
  $ echo working directory $CWD
  * (glob)

  $ bauhaus2 --no-smrtlink --noGrid generate -w SV-FY1679 -t ${BH_ROOT}/test/data/sv-fy1679.csv -o sv
  Validation and input resolution succeeded.
  Generated runnable workflow to "sv"

  $ (cd sv && ./run.sh >/dev/null 2>&1)

Check reports.
  $ cd ${CWD}/sv/reports/SV
  $ ls call_in_true.png 2>&1 >/dev/null && echo $?
  0
  $ ls call_not_true.png 2>&1 >/dev/null && echo $?
  0
  $ ls call_not_true_in_ignored.png 2>&1 >/dev/null && echo $?
  0
  $ ls false_discovery_num.png 2>&1 >/dev/null && echo $?
  0
  $ ls false_discovery_rate.png 2>&1 >/dev/null && echo $?
  0
  $ ls plt.csv 2>&1 >/dev/null && echo $?
  0
  $ ls report.Rd 2>&1 >/dev/null && echo $?
  0
  $ ls report.json 2>&1 >/dev/null && echo $?
  0
