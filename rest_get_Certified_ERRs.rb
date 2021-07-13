require './c2mAPI'
c2m = C2MAPIRest.new("username","password","0") # set 0 for stage, 1 for production
c2m.jobId = "440779"
response = c2m.jobReturnReceiptZip("440779.zip","./return_receipts/")
c2m.extract_zip("./return_receipts/440779.zip","./return_receipts/440779/")
