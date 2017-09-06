require './c2mAPI'
c2m = C2MAPIRest.new("username","password","0")
c2m.jobId ="1234"
response = c2m.checkJobStatus()
print response.body
xml_doc  = Nokogiri::XML(response.body)
print xml_doc.xpath("//description/text()")
