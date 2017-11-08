import os
import logging

log = logging.getLogger(__name__)

def str2bool(val):
    if not isinstance(val, str):
        raise TypeError("Can only cast from str to bool")
    try:
        intv = int(val)
        return bool(intv)
    except ValueError:
        # Not an int
        pass
    falses = ['false', 'none', 'null', 'no', 'n']
    trues = ['true', 'yes', 'y']
    loval = val.lower()
    for word in falses:
        if word in loval:
            return False
    for word in trues:
        if word in loval:
            return True

def which(exe):
    if os.path.exists(exe) and os.access(exe, os.X_OK):
        return exe
    path = os.getenv('PATH')
    for this_path in path.split(os.path.pathsep):
        this_path = os.path.join(this_path, exe)
        if os.path.exists(this_path) and os.access(this_path, os.X_OK):
            return this_path
    return None


def parse_exe_or_module(cmd, exe_name, module_prefix, libs_only=None,
                        env='NOT_IN_ENV'):
    """Parse an executable and module out of a command string or env variable.
    Requires a module_prefix for identification, as well as a default
    executable name. Optionally provide a libs_only version of the module, or
    an ENV key, the value of which we parse as 'cmd'.
    module_prefix can be a tuple. The first entry will be the preferred module
    to pull from, but subsequent ones can be detected in cmd and used
    """
    if not isinstance(module_prefix, (tuple, list)):
        module_prefix = (module_prefix,)
    if not isinstance(exe_name, (tuple, list)):
        exe_name = [exe_name for _ in module_prefix]
    found = False
    if cmd:
        if which(cmd.split()[0]):
            # we are provided an executable that has an abs path or is in PATH
            found = True
            exe = [os.path.abspath(cmd.split()[0])]
            exe.extend(cmd.split()[1:])
            exe = ' '.join(exe)
            module = module_prefix[0]
            if not libs_only is None:
                module = '/'.join([module, libs_only])
            else:
                module = '/'.join([module, 'mainline'])
            log.info("PATH provided, using {m} and {e}".format(
                m=module, e=exe))
            module += '\n'
        elif cmd.split()[0].startswith(module_prefix):
            # we want a module but are potentially supplying args
            found = True
            if len(cmd.split()) > 1:
                exe = ' '.join(cmd.split()[1:])
            else:
                # or no args, in which case we need to use a default exe
                for i, opt in enumerate(module_prefix):
                    if cmd.split()[0].startswith(opt):
                        module = i
                exe = exe_name[module]
            module = cmd.split()[0]
            log.info("Module provided, using {m} and {e}".format(
                m=module[:-1], e=exe))
        elif cmd.split()[0] in exe_name:
            # we want the mainline module, but are potentially supplying args
            found = True
            exe = cmd
            module = '{}/mainline\n'.format(
                module_prefix[exe_name.index(cmd.split()[0])])
            log.info("Exe provided, using {m} and {e}".format(
                m=module[:-1], e=exe))
    elif env in os.environ:
        # we can use an ENV variable, treating it like a new cmd. Just don't
        # pass the env back in...
        found = True
        exe, module = parse_exe_or_module(os.environ[env], exe_name,
                                          module_prefix, libs_only=libs_only)
    if not found:
        # fallback on mainline module
        log.warn("{} not specified or not found, using mainline module".format(exe_name))
        exe = exe_name[0]
        module = "{}/mainline\n".format(module_prefix[0])
    return exe, module
