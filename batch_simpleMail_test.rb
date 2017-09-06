require './c2mAPI'
#change 0 to 1 for production
c2mBatch = C2MAPIBatch.new("username","password","0")
rList =Recipients.new() #address list for batch
r = Recipient.new("John Smith","test company","1234 Test St","","","Oak Brook","IL","60523","")
rList.addRecipient(r) #add above address to list

po = PrintOptions.new("Letter 8.5 x 11","Address on Separate Page","Next Day","#10 Double Window","Black and White","White 24#","Printing Both sides","First Class")
job = Job.new("1", "3",po,rList)#pages 1 to 3 will goo to the above address using these print options
c2mBatch.addJob(job)

rList =Recipients.new()
r = Recipient.new("John Smith2","test company","1234 Test St","","","Oak Brook","IL","60523","")
rList.addRecipient(r)
r = Recipient.new("John Smith3","test company","1234 Test St","","","Oak Brook","IL","60523","")
rList.addRecipient(r)
job = Job.new("4", "10",po,rList)#pages 4 to 10 will goo to the above addresses using these print options
response = c2mBatch.runAll("./test.pdf")
xml_doc  = Nokogiri::XML(response.body)
print "BatchId: " + xml_doc.xpath("//id/text()").text
