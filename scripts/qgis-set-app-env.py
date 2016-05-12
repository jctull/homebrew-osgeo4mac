#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
/***************************************************************************
 OSGeo4Mac Python startup script for setting env vars in dev builds and
 installs of QGIS when built off dependencies from homebrew-osgeo4mac tap
                              -------------------
        begin    : January 2014
        copyright: (C) 2014 Larry Shaffer
        email    : larrys at dakotacarto dot com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""

import os
import stat
import sys
import argparse
import subprocess
from collections import OrderedDict

HOME = os.path.expanduser('~')
GRASS_VERSION = '7.0.4'
OSG_VERSION = '3.4.0'
HOMEBREW_PREFIX = '/usr/local'
QGIS_LOG_DIR = HOME + '/Library/Logs/QGIS'
QGIS_LOG_FILE = QGIS_LOG_DIR + '/qgis-dev.log'


def env_vars(ap, hb, qb='', ql=''):
    options = OrderedDict()
    options['PATH'] = '{hb}/opt/gdal-20/bin:{hb}/bin:{hb}/sbin:' + os.environ['PATH']

    dyld_path = '{hb}/opt/gdal-20/lib:{hb}/opt/sqlite/lib:{hb}/opt/libxml2/lib:{hb}/lib'
    run_from_build = False
    if qb:
        qbr = os.path.realpath(qb)
        if qbr in ap:
            run_from_build = True
            dyld_path = '{0}/output/lib:{0}/PlugIns/qgis:'.format(qbr) + \
                        dyld_path

    # if QGIS_MACAPP_BUNDLE == 0, or running from build directory, find the
    # right frameworks and libs first
    if (run_from_build or
            not os.path.exists(ap + '/Contents/Frameworks/QtCore.framework')):
        options['DYLD_FRAMEWORK_PATH'] = \
            '{hb}/Frameworks:/System/Library/Frameworks'
        options['DYLD_VERSIONED_LIBRARY_PATH'] = dyld_path

    # isolate Python setup if Kyngchaos frameworks exist (they bogart sys.path)
    # this keeps /Library/Python/2.7/site-packages from being searched
    if (os.path.exists(hb + '/Frameworks/Python.framework') and
            os.path.exists('/Library/Frameworks/GDAL.framework')):
        options['PYQGIS_STARTUP'] = '{hb}/Library/Taps/osgeo/homebrew-osgeo4mac' \
                                    '/enviro/python_startup.py'
        options['PYTHONHOME'] = '{hb}/Frameworks/Python.framework/Versions/2.7'

    options['PYTHONPATH'] = '{hb}/opt/gdal-20/lib/python2.7/site-packages:' \
                            '{hb}/lib/python2.7/site-packages'
    options['GDAL_DRIVER_PATH'] = '{hb}/opt/gdal-20/lib/gdalplugins'
    options['GRASS_PREFIX'] = '{hb}/opt/grass-' + GRASS_VERSION
    options['OSG_LIBRARY_PATH'] = '{hb}/lib/osgPlugins-' + OSG_VERSION
    options['QGIS_LOG_FILE'] = ql

    for k, v in options.iteritems():
        options[k] = v.format(hb=hb)

    return options


def plist_bud(cmd, plist, quiet=False):
    out = open(os.devnull, 'w') if quiet else None
    subprocess.call(['/usr/libexec/PlistBuddy', '-c', cmd, plist],
                    stdout=out, stderr=out)


def arg_parser():
    parser = argparse.ArgumentParser(
        description="""\
            Script embeds Homebrew-prefix-relative environment variables in a
            development QGIS.app bundle in the LSEnvironment entity of the app's
            Info.plist. Running on app bundle from build or install directory,
            or whether Kyngchaos.com or Qt development package installers have
            been used, yeilds different results. QGIS_LOG_FILE is at (unless
            defined in env var or command option): {0}
            """.format(QGIS_LOG_FILE)
    )
    parser.add_argument('qgis_app_path',
                        help='path to app bundle (relative or absolute)')
    parser.add_argument(
        '-p', '--homebrew-prefix', dest='hb',
        metavar='homebrew_prefix',
        help='homebrew prefix path, or set HOMEBREW_PREFIX (/usr/local default)'
    )
    parser.add_argument(
        '-b', '--build-dir', dest='qb',
        metavar='qgis_build_dir',
        help='QGIS build directory'
    )
    parser.add_argument(
        '-l', '--qgis-log', dest='ql',
        metavar='qgis_log_file',
        help='QGIS debug output log file'
    )
    return parser


def main():
    # get defined args
    args = arg_parser().parse_args()

    ap = os.path.realpath(args.qgis_app_path)
    if not os.path.isabs(ap) or not os.path.exists(ap):
        print 'Application can not be resolved to an existing absolute path.'
        sys.exit(1)

    # QGIS Browser.app?
    browser = 'Browser.' in ap

    plist = ap + '/Contents/Info.plist'
    if not os.path.exists(plist):
        print 'Application Info.plist not found.'
        sys.exit(1)

    # generate list of environment variables
    hb_prefix = HOMEBREW_PREFIX
    if 'HOMEBREW_PREFIX' in os.environ:
        hb_prefix = os.environ['HOMEBREW_PREFIX']
    hb = os.path.realpath(args.hb) if args.hb else hb_prefix
    if not os.path.isabs(hb) or not os.path.exists(hb):
        print 'HOMEBREW_PREFIX not resolved to existing absolute path.'
        sys.exit(1)

    q_log = QGIS_LOG_FILE
    if 'QGIS_LOG_FILE' in os.environ:
        q_log = os.environ['QGIS_LOG_FILE']
    ql = os.path.realpath(args.ql) if args.ql else q_log
    try:
        if not os.path.exists(ql):
            if ql == os.path.realpath(QGIS_LOG_FILE):
                # ok to auto-create log's parent directories
                p_dir = os.path.dirname(ql)
                if not os.path.exists(p_dir):
                    os.makedirs(p_dir)
            subprocess.call(['/usr/bin/touch', ql])
    except OSError, e:
        print 'Could not create QGIS log file at: {0}'.format(ql)
        print 'Create an empty file at the indicated path for logging to work.'
        print >>sys.stderr, "Warning:", e

    qb = os.path.realpath(args.qb) if args.qb else ''
    if qb and (not os.path.isabs(qb) or not os.path.exists(qb)):
        print 'QGIS build directory not resolved to existing absolute path.'
        sys.exit(1)

    # write variables to Info.plist
    evars = env_vars(ap, hb, qb, ql)

    # opts_s = ''
    # for k, v in evars.iteritems():
    #     opts_s += '{0}={1}\n'.format(k, v)
    # print opts_s + '\n'

    # first delete any LSEnvironment setting, ignoring errors
    # CAUTION!: this may not be what you want, if the .app already has
    #           LSEnvironment settings
    plist_bud('Delete :LSEnvironment', plist, quiet=True)

    # re-add the LSEnvironment entry
    plist_bud('Add :LSEnvironment dict', plist)

    # add the variables
    for k, v in evars.iteritems():
        plist_bud("Add :LSEnvironment:{0} string '{1}'".format(k, v), plist)

    # set bundle identifier, so package installers don't accidentally install
    # updates into dev bundles
    app_id = 'qgis'
    app_name = 'QGIS'
    if browser:
        app_id += '-browser'
        app_name += ' Browser'
    plist_bud('Set :CFBundleIdentifier org.qgis.{0}-dev'.format(app_id), plist)

    # update modification date on app bundle, or changes won't take effect
    subprocess.call(['/usr/bin/touch', ap])

    # add environment-wrapped launcher shell script
    wrp_scr = ap + '/Contents/MacOS/{0}.sh'.format(app_id)

    # override vars that need to prepend existing vars
    evars['PATH'] = '{hb}/opt/gdal-20/bin:{hb}/bin:{hb}/sbin:$PATH'.format(hb=hb)
    evars['PYTHONPATH'] = \
        '{hb}/opt/gdal-20/lib/python2.7/site-packages:' \
        '{hb}/lib/python2.7/site-packages:$PYTHONPATH'.format(hb=hb)

    if os.path.exists(wrp_scr):
        os.remove(wrp_scr)

    with open(wrp_scr, 'a') as f:
        f.write('#!/bin/bash\n\n')

        # get runtime parent directory
        f.write('DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)\n\n')

        # add the variables
        for k, v in evars.iteritems():
            f.write('export {0}={1}\n'.format(k, v))

        f.write('\n"$DIR/{0}" "$@"\n'.format(app_name))

    os.chmod(wrp_scr, stat.S_IRUSR | stat.S_IWUSR | stat.S_IEXEC)

    print 'Done setting variables'

if __name__ == '__main__':
    main()
    sys.exit(0)