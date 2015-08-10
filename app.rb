# app.rb

# Login to nutshell.
$nutshell = NutshellCrmAPI::Client.new($username, $apiKey)


# Get all companies in nutshell.
companies = []
i = 0
loop do
	i+=1
	response = $nutshell.find_accounts([], nil, nil, 100, i, false)
	break if response.length == 0
	companies.concat(response)
end

# Filter companies that have no people
# associated with them.
companies_without_primary_contact = []
companies.each do |company|
	tags = []
	company['contacts'].each do |contact| 
		contact = $nutshell.get_contact(contact['id'])
		tags.concat contact['tags']
		# Break if primary contact exsists
		break if tags.include? 'Primary Contact'
	end

	unless tags.include? 'Primary Contact'
		companies_without_primary_contact.push company['name']
	end
	sleep(0.6)
end

# Create spreadsheet with missing companies.
CSV.open("companies_without_primary_contact.csv", "wb") do |csv|
	companies_without_primary_contact.each do |company|
		csv << [].push(company["name"])
	end
end


# Print message to Jenkins
puts "################################################"
puts "You have #{companies_without_primary_contact.length} companies without a primary contact."
puts "################################################"