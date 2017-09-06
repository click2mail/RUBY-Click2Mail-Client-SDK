require './c2mAPI'
#change 0 to 1 for production
c2mBatch = C2MAPIBatch.new("username","password","0")
c2mBatch.batchId = "12345"
print c2mBatch.checkBatchStatus().body