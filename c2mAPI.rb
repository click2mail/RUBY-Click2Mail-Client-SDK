require 'net/http'
require 'uri'
require 'nokogiri'
require 'net/http/post/multipart'
require 'open-uri'
class C2MAPIRest
 attr_accessor :mode,:jobId,:documentId,:addressListId
	def initialize(username,pw,mode)
		@username = username
		@pw = pw
		@mode = mode
		@restUrl = "https://rest.click2mail.com"
		@stageUrl = "https://stage-rest.click2mail.com"
		@xmlTop = "<addressList><addressListName>{{addressListName}}</addressListName><addressMappingId>{{addressMappingId}}</addressMappingId><addresses>"
		@xmlBottom = "</addresses></addressList>"
		@xmlMiddle = ""
	end
	def addAddress(xmlAddress)
		
		@xmlMiddle +="<address>" + xmlAddress + "</address>"
	end
	def createAddressListXML(addressListName,addressMappingId)
		@xml =	@xmlTop.sub("{{addressListName}}",addressListName)
		@xml = @xml.sub("{{addressMappingId}}",addressMappingId)
		@xml += @xmlMiddle
		@xml += @xmlBottom
		return @xml
	#	print @xml
	end
	def getRestURL()
		if @mode == "0"
			return @stageUrl
		else
			return @restUrl
		end 
	end
	def documentCreate(filePath,fileName,po)
		@po = po
		url = getRestURL()
		uri = URI.parse(url + "/molpro/documents")
		
		#File.open("./test.pdf") do |pdf|
			request = Net::HTTP::Post::Multipart.new uri, "file" => UploadIO.new(File.new(filePath), "application/pdf", filePath),"documentName" => fileName,"documentClass" => po.documentClass,"documentFormat" => "PDF"
			
		#end
		request.basic_auth(@username, @pw)
		#request.content_type = "application/xml"

		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		#print response.body
		if Integer(response.code) > 299
			return response
		end
		xml_doc  = Nokogiri::XML(response.body)
		@documentId = xml_doc.xpath("//id/text()")
		return response
		#print "DOCUMENTID #@documentId"
		#print "\n\n"
	end
	def addressListCreate(addressListName,addressMappingId)
		url = getRestURL()
		uri = URI.parse(url + "/molpro/addressLists")
		
		request = Net::HTTP::Post.new(uri)
		request.basic_auth(@username, @pw)
		request.content_type = "application/xml"
		request.body = createAddressListXML(addressListName,addressMappingId)

		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		#print response.body
		if Integer(response.code) > 299
			return response
		end
		xml_doc  = Nokogiri::XML(response.body)
		@addressListId = xml_doc.xpath("//id/text()")
		return response	
		#print "ADDRESSID #@addressListId\n\n"
	end
	def jobCreate()
		url = getRestURL()
		uri = URI.parse(url + "/molpro/jobs")
		request =  Net::HTTP::Post.new( uri)
		form_data = URI.encode_www_form(:documentClass=> @po.documentClass,:layout =>@po.layout,:productionTime => @po.productionTime,:envelope => @po.envelope,:color =>@po.color,:paperType =>@po.paperType,:printOption=> @po.printOption,:documentId => @documentId,:addressId => @addressListId)
		request.body = form_data	
		#end
		request.basic_auth(@username, @pw)
		#request.content_type = "application/xml"

		req_options = {
		 use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		if Integer(response.code) > 299
			return response
		end
		xml_doc  = Nokogiri::XML(response.body)
		@jobId = xml_doc.xpath("//id/text()")
		return response
		#if Integer(@jobId.text) > 0
		#	print "Successful Job Created"
		#		print "\n\n"
		#	end	
	end
	def jobSubmit()
		url = getRestURL()
		uri = URI.parse(url + "/molpro/jobs/#@jobId/submit")
		request =  Net::HTTP::Post.new( uri)
		form_data = URI.encode_www_form(:billingType => 'User Credit')
		request.body = form_data	
		#end
		request.basic_auth(@username, @pw)
		#request.content_type = "application/xml"

		req_options = {
		 use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		return response
	end
	def jobCheckStatus()
		url = getRestURL()
		uri = URI.parse(url + "/molpro/jobs/#@jobId/")

		#print URI.encode_www_form([["documentClass", "Letter 8.5 x 11"],["layout","Address on Separate Page"],["productionTime","Next Day"],["envelope","#10 Double Window"],["color","Black and White"],["paperType","White 24#"],["printOption", "Printing Both sides"],["documentId",$documentId],["addressId" , $addressId]])
		#params = [["documentClass", "Letter 8.5 x 11"],["layout","Address on Separate Page"],["productionTime","Next Day"],["envelope","#10 Double Window"],["color","Black and White"],["paperType","White 24#"],["printOption", "Printing Both sides"],["documentId",$documentId],["addressId" , $addressId]]
		request =  Net::HTTP::Get.new( uri)
		#form_data = URI.encode_www_form(:billingType => 'User Credit')
		#rquest.body = form_data	
		#end
		request.basic_auth(@username, @pw)
		#request.content_type = "application/xml"

		req_options = {
		 use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		return  response
		#xml_doc  = Nokogiri::XML(response.body)

		#print xml_doc.xpath("//description/text()")
		#print "\n\n"
		#print "\n\n"
	end
	def runAll(filepath,filename,printoptions,addressmappingId)
		string = ('a'..'z').to_a.shuffle[0,8].join
		print "Creating Document\n\n"
		response = documentCreate(filepath,filename,printoptions)
		if Integer(response.code) > 299
			return response
		end
		print "Creating AddressList\n\n"
		response=addressListCreate(string,addressmappingId)
		if Integer(response.code) > 299
			return response
		end
		print "Creating Job\n\n"
		response=jobCreate()
		if Integer(response.code) > 299
			return response
		end
		print "Submitting Job\n\n"
		response=jobSubmit()
		if Integer(response.code) > 299
			return response
		end
		return jobCheckStatus()	
	end
end
class C2MAPIBatch
 attr_accessor :mode,:batchId,:addressListId
	def initialize(username,pw,mode)
		@username = username
		@pw = pw
		@mode = mode
		@batchId = "0"
		@stageBatchURL = "https://stage-batch.click2mail.com"
		@batchURL = "https://batch.click2mail.com"
		@jobs = []
	end
	def addJob (job)
#Here I try to add an object blog, post an array of objects
        @jobs.push(job)
    end	
	def getBatchURL()
		if @mode == "0"
			return @stageBatchURL
		else
			return @batchURL
		end 
	end 
	def createBatch()
		url = getBatchURL()
		uri = URI.parse(url + "/v1/batches")
		request =  Net::HTTP::Post.new( uri)
		request.basic_auth(@username, @pw)

		req_options = {
		 use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		if Integer(response.code) > 299
			return response
		end
	
		xml_doc  = Nokogiri::XML(response.body)
		@batchId = xml_doc.xpath("//id/text()")
		return response
	end
	def uploadBatchPDF(filePath)
		@fileName = filePath
	    url = getBatchURL()
		uri = URI.parse(url + "/v1/batches/#@batchId")
		request = Net::HTTP::Put.new(uri)
		request.content_type = "application/pdf"
		request.body = ""
		request.body << File.read(filePath)
		request.basic_auth(@username, @pw)
		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		return response
	end
	def uploadBatchXML()
		#print createPostXML().delete("\r\n").delete("\t")
		url = getBatchURL()
		uri = URI.parse(url + "/v1/batches/#@batchId")
		request = Net::HTTP::Put.new(uri)
		request.content_type = "application/xml"
		request.body = ""
		request.body << createPostXML().delete("\r\n").delete("\t")
		request.basic_auth(@username, @pw)
		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		return response
	end
	def submitBatch()
		url = getBatchURL() + "/v1/batches/#$batchId"
		uri = URI.parse(url)

		request = Net::HTTP::Post.new(uri)

		request.basic_auth(@username, @pw)
		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		return response
	end
	def checkBatchStatus()
		url = getBatchURL() + "/v1/batches/#@batchId"
		uri = URI.parse(url)

		request = Net::HTTP::Get.new(uri)
		request.basic_auth(@username, @pw)
		req_options = {
		  use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end
		return response
	end
	def createPostXML()
		@postXML = "<batch>
						<username>#@username</username>
						<password>#@pw</password>
						<filename>#@fileName</filename>
						<appSignature>test</appSignature>"
		@jobs.each do |item|
		@postXML +=	"
		<job>
			<startingPage>" + item.startingPage + "</startingPage>
			<endingPage>" + item.endingPage + "</endingPage>
			<printProductionOptions>
				<documentClass>" + item.printOption.documentClass + "</documentClass>
				<layout>" + item.printOption.layout + "</layout>
				<productionTime>" + item.printOption.productionTime + "</productionTime>
				<envelope>" + item.printOption.envelope + "</envelope>
				<color>" + item.printOption.color + "</color>
				<paperType>" + item.printOption.paperType + "</paperType>
				<printOption>" + item.printOption.printOption + "</printOption>
				<mailClass>" + item.printOption.mailClass + "</mailClass>
			</printProductionOptions>
			<recipients>"
			
			item.recipients.recipients.each do |recipient|
				@postXML += "<address>
					<name>" + recipient.name + "</name>
					<organization>" + recipient.name + "</organization>
					<address1>" + recipient.address1 + "</address1>
					<address2>" + recipient.address2 + "</address2>
					<address3>" + recipient.address3 + "</address3>
					<city>" + recipient.city + "</city>
					<state>" + recipient.state + "</state>
					<postalCode>" + recipient.postalCode + "</postalCode>
					<country>" + recipient.country + "</country>
				</address>"
			end
			@postXML += "</recipients>
		</job>"
			
		end
		@postXML += "</batch>"	
		#print @postXML.delete("\r\n").delete("\t")
		return @postXML
	end
	def runAll(filePath)
		response = createBatch()
		if Integer(response.code) > 299
			return response
		end
		response = uploadBatchPDF(filePath)
		if Integer(response.code) > 299
			return response
		end
		response = uploadBatchXML()
		if Integer(response.code) > 299
			return response
		end	
		response = submitBatch()
		if Integer(response.code) > 299
			return response
		end
		return checkBatchStatus()
	end
end
class Recipients
    attr_accessor :recipients
	def initialize
        @recipients = []
    end
    def addRecipient (newRecipients)
#Here I try to add an object blog, post an array of objects
        @recipients.push(newRecipients)
    end
end

class PrintOptions
  attr_accessor :documentClass, :layout,:productionTime,:envelope,:paperType,:printOption,:mailClass,:color
  def initialize(documentClass, layout,productionTime,envelope,color,paperType,printOption,mailClass)
    @documentClass = documentClass
    @layout   = layout
	@productionTime = productionTime
	@envelope = envelope
	@color = color
	@paperType = paperType
	@printOption = printOption
	@mailClass = mailClass
  end
end
class Recipient
    attr_accessor :name,:organization,:address1,:address2,:address3,:city,:state,:postalCode,:country
	def initialize(name,organization,address1,address2,address3,city,state,postalCode,country)
        @name = name
		@organization = organization
		@address1 = address1
		@address2 = address2
		@address3 = address3
		@city = city
		@state = state
		@postalCode = postalCode
		@country = country
    end
end
class Job
		attr_accessor :startingPage, :endingPage,:printOption,:recipients
	def initialize(startingPage,endingPage,printOption,recipients)
		@startingPage = startingPage
		@endingPage   = endingPage
		@printOption = printOption
		@recipients = recipients
	end	
end