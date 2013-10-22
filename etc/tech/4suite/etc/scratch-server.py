import sys, sha, getpass
from Ft.Server.Client import FtServerClientException
from Ft.Lib import Uri
from Ft.Server.Common import ResourceTypes, AclConstants
from Ft.Server.Client import Core
from Ft.Server.Client import SmartLogin


def Run():
    #user_name = raw_input("4SS superuser name: ")
    #passwdHash = sha.new(getpass.getpass("Password for %s: " % user_name)).hexdigest()
    print "In the following prompts, just hit enter if the given defaults are OK."
    container_name = raw_input("Name for the container to create [web]: ")
    if not container_name: container_name = 'web'
    server_port = raw_input("Port on which to host the HTTP server [8080]: ")
    if not server_port: server_port = '8080'
    server_name = raw_input("Brief name to identify the server [4ss]: ")
    if not server_name: server_name = '4ss'
    contact = raw_input("Contact e-mail address to display in case of error [root@localhost]: ")
    if not contact: contact = 'root@localhost'
    server_doc = SERVER_FILE%locals()

    try:
        try:
            commit = 0
            #Get the repository by logging in
            repo = SmartLogin()
            #repo = Core.GetRepository(user_name, passwdHash, 'localhost', 8803)
            cont = repo.createContainer('/' + container_name)
            cont.setAcl(AclConstants.WRITE_ACCESS, AclConstants.USERS_GROUP_NAME, AclConstants.ALLOWED)
            cont.setAcl(AclConstants.READ_ACCESS, AclConstants.USERS_GROUP_NAME, AclConstants.ALLOWED)
            cont.setAcl(AclConstants.READ_ACCESS, AclConstants.WORLD_GROUP_NAME, AclConstants.ALLOWED)
            doc = repo.createDocument('/' + container_name + '/server.xml',
                                      server_doc,
                                      imt='text/xml',
                                      docDef=None,
                                      forcedType=ResourceTypes.ResourceType.SERVER)
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


SERVER_FILE = """<Server xmlns="http://xmlns.4suite.org/reserved" xmlns:dc="http://purl.org/dc/elements/1.1#"
>
  <dc:Description>Scratch server</dc:Description>
  <Status running='1'/>
  <Module>Http</Module>
  <Handler>http_basic</Handler>
  <Port>%(server_port)s</Port>

  <!-- contact information -->
  <ServerAdmin>%(contact)s</ServerAdmin>
  <ServerName>%(server_name)s</ServerName>

  <!-- logging -->
  <LogLevel>notice</LogLevel>

  <DocumentRoot>/%(container_name)s</DocumentRoot>
</Server>
"""


if __name__ == "__main__":
    Run()

