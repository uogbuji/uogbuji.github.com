from __future__ import generators
from xml.dom import Node
from Ft.Server.Server.Xslt.Ns import *

NSS = [SCORE_NS,
       #HTTP_NS,
       RDF_NS,
      ]

#{(ns-uri, local-name): [(old-attr-name1, new-attr-name1), (old-attr-name2, new-attr-name2)...]}
API_CHANGES = {
    (RDF_NS, 'visualize'): [('output-uri', 'output-path'), ('resource-uri', 'resource-path')],
    (RDF_NS, 'deserialize-and-add'): [('uri', 'path'), ('base-uri', 'base-path')],
    (RDF_NS, 'deserialize-and-remove'): [('uri', 'path'), ('base-uri', 'base-path')],
    (RDF_NS, 'complete'): [('src-uri', 'scope')],
    (RDF_NS, 'remove'): [('src-uri', 'scope')],
    (RDF_NS, 'add'): [('src-uri', 'scope')],
    (SCORE_NS, 'create-uri-reference'): [('uri', 'path'), ('base-uri', 'base-path')],
    (SCORE_NS, 'create-document'): [('uri', 'path'), ('base-uri', 'base-path')],
    (SCORE_NS, 'create-rawfile'): [('uri', 'path'), ('base-uri', 'base-path')],
    (SCORE_NS, 'create-group'): [('base-uri', 'base-path')],
    (SCORE_NS, 'create-user'): [('base-uri', 'base-path')],
    (SCORE_NS, 'create-container'): [('base-uri', 'base-path')],
    (SCORE_NS, 'create-user'): [('base-uri', 'base-path')],
    (SCORE_NS, 'delete-resource'): [('uri', 'path')],
    (SCORE_NS, 'add-member'): [('uri', 'path'), ('member-uri', 'member-path')],
    (SCORE_NS, 'add-alias'): [('base-uri', 'resource-path'), ('path', 'alias-path')],
    (SCORE_NS, 'set-content'): [('uri', 'path')],
    (SCORE_NS, 'set-acl'): [('uri', 'path')],
    (SCORE_NS, 'add-acl'): [('uri', 'path')],
    (SCORE_NS, 'mark-temporary'): [('uri', 'path')],
    (SCORE_NS, 'x-update'): [('uri', 'path')],
    #(, ''): [('uri', 'path'), ('base-uri', 'base-path')],
    }

def doc_order_iterator(node):
    yield node
    for child in node.childNodes:
        for cn in doc_order_iterator(child):
            yield cn
    return


def doc_order_iterator_filter(node, filter_func):
    if filter_func(node):
        yield node
    for child in node.childNodes:
        for cn in doc_order_iterator_filter(child, filter_func):
            yield cn
    return


if __name__ == "__main__":
    import sys
    fname = sys.argv[1]
    print "Processing %s ..."%fname
    file = open(fname, 'r')
    content = file.read()
    file.close()
    from Ft.Xml.Domlette import NonvalidatingReader, Print
    doc = NonvalidatingReader.parseString(content, fname)
    for node in doc_order_iterator_filter(doc, lambda x: x.nodeType == Node.ELEMENT_NODE and x.namespaceURI in NSS):
        if API_CHANGES.has_key((node.namespaceURI, node.localName)):
            #print "Updating API for ", node.nodeName
            for old, new in API_CHANGES[(node.namespaceURI, node.localName)]:
                if node.hasAttributeNS(None, old):
                    print "In element", node.nodeName, "rename attribute", old, "to", new
                #if value:
                #    node.getAttributeNS(None, new, value)
                #node.removeAttributeNS(None, old)
    #fname = sys.argv[1]
    #file = open(fname, 'w')
    #Print(doc, stream=file)
    #file.close()

