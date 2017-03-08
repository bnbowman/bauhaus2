
def subreadsPlan(ct, args):
    # In greater generality, this could include a bax2bam conversion
    # possibility to enable integration of RSII data; or we could even
    # run the basecaller, if we have trace input specified; or we
    # could re-call adapters... lots of possibilities.
    assert not ct.inputsAreMapped
    return [ "collect-subreads.snake" ]
