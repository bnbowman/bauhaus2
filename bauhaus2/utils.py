import os, stat, itertools, os.path as op, jinja2

def mkdirp(path):
    try:
        os.makedirs(path)
    except OSError:
        # "path already exists", presumably... should verify
        pass

def chmodPlusX(path):
    originalStat = os.stat(path).st_mode
    os.chmod(path, originalStat | stat.S_IXUSR)

def listConcat(lsts):
    return list(itertools.chain(*lsts))

def readFile(path):
    return open(path).read()

def writeFile(path, content):
    with open(path, "w") as f:
        f.write(content)

def quote(s):
    return '"%s"' % s

def renderTemplate(inPath, outPath, **kwargs):
    template = jinja2.Template(readFile(inPath))
    writeFile(outPath, template.render(**kwargs))
