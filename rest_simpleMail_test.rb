require './c2mAPI'
c2m = C2MAPIRest.new("username","password","0") # set 0 for stage, 1 for production
c2m.addAddress("<First_name>John</First_name>
			  <Last_name>Doe</Last_name>
			  <Organization>My Business</Organization>
			  <Address1>123 None Street</Address1>
			  <Address2>Suite 210</Address2>
			  <Address3></Address3>
			  <City>Somewhere</City>
			  <State>Va</State>
			  <Zip>12345</Zip>
			  <Country_non-US></Country_non-US>")
c2m.addAddress("<First_name>John2</First_name>
			  <Last_name>Doe</Last_name>
			  <Organization>My Business</Organization>
			  <Address1>123 None Street</Address1>
			  <Address2>Suite 210</Address2>
			  <Address3></Address3>
			  <City>Somewhere</City>
			  <State>Va</State>
			  <Zip>12345</Zip>
			  <Country_non-US></Country_non-US>")
po = PrintOptions.new("Letter 8.5 x 11","Address on Separate Page","Next Day","#10 Double Window","Black and White","White 24#","Printing Both sides","First Class")
response = c2m.runAll("./test.pdf","MyFile",po,"2")
#print response.body
xml_doc  = Nokogiri::XML(response.body)
print xml_doc.xpath("//description/text()")
print "JobId: " + c2m.jobId.text + "\n\n"
print "DocumentId: " + c2m.documentId.text + "\n\n"
print "AddressId: " + c2m.addressListId.text + "\n\n"
