public class XMLParserClass{

    public Map<String, String> xmlDataMap = new Map<String,String>(); 

    public String generateXML(){

        Dom.Document doc = new Dom.Document();

        Dom.Xmlnode rootNode = doc.createRootElement('SampleXMLReport', null, null);
        Dom.Xmlnode headerNode = rootNode.addChildElement('header', null, null);

        //assign header attributes

        headerNode.setAttribute('id', 'ParentNode');

        Dom.Xmlnode childNode = headerNode.addChildElement('detail', null, null);

        childNode.setAttribute('id','ChildNode');
        childNode.setAttribute('Amount','4000');

        return doc.toXmlString();
    }
    // Above method generated below xml file which we are going to parse
    /* XML FILE
    <?xml version="1.0" encoding="UTF-8"?>
      <SampleXMLReport>
        <header id="ParentNode">
          <detail id="ChildNode" Amount="4000" />
        </header>
    </SampleXMLReport>
    */

    /**
     * iterateThroughXML
     * This method traverse through the xml, read the data from XML.
     * @return void.
     **/

    private void iterateThroughXML(DOM.XMLNode node){

        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT){
        
            if(node.getName().equalsIgnoreCase('detail')){
                if (node.getAttributeCount() > 0) {
                  xmlDataMap.put(node.getAttributeValue(node.getAttributeKeyAt(0), node.getAttributeKeyNsAt(0)), node.getAttributeValue(node.getAttributeKeyAt(1), node.getAttributeKeyNsAt(1)));
                }
            }

            for (Dom.XMLNode child: node.getChildElements())
              iterateThroughXML(child);
        }
    }

    public void parserXML(String toParse){

        xmlDataMap = new Map<String,String>();
        DOM.Document doc = new DOM.Document();
        
        try{
        
            doc.load(toParse);
            DOM.XMLNode root = doc.getRootElement();
            iterateThroughXML(root);
        }catch(Exception ex){

            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(msg);
       } 
    }
}