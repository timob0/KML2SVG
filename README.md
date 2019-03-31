# KML2SVG
XSLT based conversion of KML geospatial data format in to SVG suitable for processing with drawing apps. The main usecase is to convert routes / waypoints create in online map apps into vector graphics for further processing / printing.

The KML fileformat is based on XML and thus easy to process with a XSLT stylesheet processor. Therefore, this project mainly consists of the kml2svg.xlst stylesheet which defines the transformation from KML elements into SVG elements.

Included is a driver application in Java which essentially sets up the XSLT processor and handles files loading / saving.

To build and run:
1) Connect this repo to the Ecplise IDE
2) Create a lib subfolder and add the saxon XLST processor jars from saxonica.com. The free "HE" edition will do just fine, find it here: https://sourceforge.net/projects/saxon/files/Saxon-HE/9.9/
3) Build the project and run it, the included doc.kml and output.svg are sample data.
4) Use your own .kml file downloaded from Google maps or some other source
