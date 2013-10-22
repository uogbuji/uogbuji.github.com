import sys
from Ft.Server.Client import FtServerClientException
from Ft.Server.Client import Core
from Ft.Server import FTSERVER_NAMESPACE
from Ft.Rdf.Statement import Statement
from Ft.Server.Common import ResourceTypes
from Ft.Server.Client import SmartLogin
from Ft.Server.Server.Drivers.PathImp import RepoPathToUri

DASHBOARD_NS = "http://chimezie.ogbuji.net/4ss/tools/dashboard/schema#"


def Run(path):
    try:
        try:
            commit = 0
            #Get the repository by logging in
            repo = SmartLogin()
            model = repo.getModel()
            user = repo.getCurrentUser().getAbsolutePath()
            user = RepoPathToUri(user)
            stmts = model.complete(user, DASHBOARD_NS+"ns-mappings", None)
            if not stmts:
                new_doc = repo.createDocument(
                    path, NS_MAPPING_TEMPLATE, imt='text/xml',
                    forcedType=ResourceTypes.ResourceType.XML_DOCUMENT)
                #container = new_doc.getParent().getAbsolutePath()
                #print container
                stmt = Statement(user, DASHBOARD_NS + "ns-mappings", path,
                                 scope=path)
                model.add(stmt)
                commit = 1
            else:
                print "This user already has a namespace mapping file: ", stmts[0].object
                
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


NS_MAPPING_TEMPLATE = """<?xml version="1.0" encoding="UTF-8"?>
<fres:NsMappings xmlns:fres="http://xmlns.4suite.org/reserved">
  <fres:NsMapping>
    <Prefix>dc</Prefix>
    <Uri>http://purl.org/dc/elements/1.1#</Uri>
  </fres:NsMapping>
  <fres:NsMapping>
    <Prefix>vcard</Prefix>
    <Uri>http://4suite.org/nexus/rdfs/vcard#</Uri>
  </fres:NsMapping>
  <fres:NsMapping>
    <Prefix>fschema</Prefix>
    <Uri>http://schemas.4suite.org/4ss#</Uri>
  </fres:NsMapping>
  <fres:NsMapping>
    <Prefix>rdf</Prefix>
    <Uri>http://www.w3.org/1999/02/22-rdf-syntax-ns#</Uri>
  </fres:NsMapping>
  <fres:NsMapping>
    <Prefix>rdfs</Prefix>
    <Uri>http://www.w3.org/2000/01/rdf-schema#</Uri>
  </fres:NsMapping>
  <fres:NsMapping>
    <Prefix>vtrav</Prefix>
    <Uri>http://rdfinference.org/versa/0/2/traverse/</Uri>
  </fres:NsMapping>
  <fres:NsMapping>
    <Prefix>vsort</Prefix>
    <Uri>http://rdfinference.org/versa/0/2/sort/</Uri>
  </fres:NsMapping>
  <fres:NsMapping>
    <Prefix>daml</Prefix>
    <Uri>http://www.daml.org/2001/03/daml+oil#</Uri>
  </fres:NsMapping>
</fres:NsMappings>
"""


if __name__ == "__main__":
    Run(sys.argv[1])

