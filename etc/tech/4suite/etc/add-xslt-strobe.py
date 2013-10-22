import sys, sha, getpass
from Ft.Server.Client import FtServerClientException
from Ft.Lib import Uri
from Ft.Server.Client import Core
from Ft.Server.Client.Core import Util

def Run(path):
    try:
        try:
            commit = 0
            repo = Util.SmartLogin()
    #doc = repo.fetchResource(args['path'],traverseAliases = not options.has_key('no-traverse'))
            repo.addXsltStrobe(path)
            commit = 1

        finally:
            try:
                if commit:
                    repo.txCommit()
                else:
                    repo.txRollback()
            except:
                pass

    except FtServerClientException, e:
        print e

if __name__ == "__main__":
    Run(sys.argv[1])

