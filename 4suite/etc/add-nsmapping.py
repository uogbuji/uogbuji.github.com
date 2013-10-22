import sys
from Ft.Server.Client import FtServerClientException
from Ft.Server.Client import Core
from Ft.Server import FTSERVER_NAMESPACE
from Ft.Server.Client import SmartLogin
from Ft.Server.Server.Drivers.PathImp import RepoPathToUri

DASHBOARD_NS = "http://chimezie.ogbuji.net/4ss/tools/dashboard/schema#"


def Run(prefix, ns):
    try:
        try:
            commit = 0
            #Get the repository by logging in
            repo = SmartLogin()
            model = repo.getModel()
            user = repo.getCurrentUser().getAbsolutePath()
            user = RepoPathToUri(user)
            stmts = model.complete(user, DASHBOARD_NS+"ns-mappings", None)
            if stmts:
                nsm_res = repo.fetchResource(stmts[0].object)
                nsm_res.xUpdate(ADD_NS_MAP_XUPDATE%locals())
                commit = 1
            else:
                print "No namespace mapping defined for this user"
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


ADD_NS_MAP_XUPDATE = """<?xml version="1.0"?>
<xupdate:modifications
  version="1.0"
  xmlns:xupdate="http://www.xmldb.org/xupdate"
  xmlns:fres='http://xmlns.4suite.org/reserved'
>
  <xupdate:append select="/fres:NsMappings" child="last()">
  <fres:NsMapping>
    <Prefix>%(prefix)s</Prefix>
    <Uri>%(ns)s</Uri>
  </fres:NsMapping>
  </xupdate:append>

</xupdate:modifications>
"""


if __name__ == "__main__":
    Run(sys.argv[1], sys.argv[2])

