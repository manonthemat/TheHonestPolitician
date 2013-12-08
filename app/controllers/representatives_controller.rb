class RepresentativesController < ApplicationController
  def index
  end

  def checkAddress
    if params[:address].blank?
      params[:address] = '2516 Cincinnati St, Los Angeles'
    end
    repr = getRepresentatives(params[:address])
    officials = repr[1]
    offices = {}
    offices[:cityOffices] = []
    offices[:countyOffices] = []
    offices[:stateOffices] = []
    offices[:federalOffices] = []
    offices[:otherOffices] = []
    repr[0].each do |k, office|
      if office['level'] == 'city'
        offices[:cityOffices] << office
      elsif office['level'] == 'county'
        offices[:countyOffices] << office
      elsif office['level'] == 'state'
        offices[:stateOffices] << office
      elsif office['level'] == 'federal'
        offices[:federalOffices] << office
      else
        offices[:otherOffices] << office
      end
    end
    offices.each do |k, v|
      v.to_enum.with_index(0).each do |a, index|
        p = a['officialIds']
        official = eval(officials[p[0]].to_s)
        offices[k.to_sym][index]['official_name'] = official['name']
        offices[k.to_sym][index]['official_address'] = official['address']
        offices[k.to_sym][index]['official_phones'] = official['phones']
        offices[k.to_sym][index]['official_urls'] = official['urls']
        offices[k.to_sym][index]['official_emails'] = official['emails']
        offices[k.to_sym][index]['official_party'] = official['party']
        offices[k.to_sym][index]['official_photoUrl'] = official['photoUrl']
        offices[k.to_sym][index]['official_channels'] = official['channels']
      end
    end

    @cityOffices = offices[:cityOffices]
    @countyOffices = offices[:countyOffices]
    @stateOffices = offices[:stateOffices]
    @federalOffices = offices[:federalOffices]
    @otherOffices = offices[:otherOffices]
  end

  def getRepresentatives(address)
    require "json"
    require "net/https"
    require "uri"
    url = "https://www.googleapis.com/civicinfo/us_v1/representatives/lookup?key=#{API_KEY}&fields=offices,officials"
    uri = URI.parse(url)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    @payload = { "address" => address,
                 "key" => API_KEY}.to_json
    request = Net::HTTP::Post.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    request.body = @payload
    response = https.request(request)
    parsedData = JSON.parse(response.body)
    @offices = parsedData['offices']
    @officials = parsedData['officials']
    return [@offices, @officials]
  end

  def getVotes
    @full_name = params[:full_name]
    require "json"
    require "net/http"
    require "uri"
    name = @full_name.split(' ')
    if name.length == 2
      first_name = name[0].capitalize
      last_name = name[1].capitalize
      rep_id = SUNLIGHT_API_ROOT + "/legislators?last_name=#{last_name}&first_name=#{first_name}&apikey=#{SUNLIGHT_KEY}&fields=bioguide_id"
    else
      if name[0].include?('.') == false and name[0].length > 2
        first_name = name[0].capitalize
        query_name = name[1].capitalize
      else
        first_name = name[1].capitalize
        query_name = name[2].capitalize
      end
      rep_id = SUNLIGHT_API_ROOT + "/legislators?query=#{query_name}&first_name=#{first_name}&apikey=#{SUNLIGHT_KEY}&fields=bioguide_id"
    end
    uri = URI.parse(rep_id)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
    response = http.request(request)
    begin
      @bio_id = JSON.parse(response.body)['results'][0]['bioguide_id']
      votes = SUNLIGHT_API_ROOT + "/votes?voter_ids.#{@bio_id}__exists=true&apikey=#{SUNLIGHT_KEY}&fields=question,vote_type,result,source"
      uri = URI.parse(votes)
      http = Net::HTTP.new(uri.host, uri.port)
      #request = Net::HTTP::Get.new(uri.request_uri, initheader = {'Content-Type' =>'application/json'})
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      @votes = JSON.parse(response.body)
    rescue Exception
      @bio_id = 'none'
      @votes = ''
    end
  end
end
