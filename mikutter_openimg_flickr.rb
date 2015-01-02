# -*- coding: utf-8 -*-

require 'uri'
require 'base58'
require 'net/http'
require 'rexml/document'

Plugin.create(:mikutter_openimg_flickr) do
  on_boot do |service|
    #Flickr thumbnail
    defimageopener("Flickr",/www\.flickr\.com\/photos\//) { |url|
      begin
        photo = url.match(/\/photos\/[\w\-_@]+\/(\w+)/)[1]
        open(FlickrAPI(photo))
      rescue => ex
      end
    }

    defimageopener("Flickr short URL",/flic\.kr\//) { |url|
      begin
        enc = url.match(/\/p\/(\w+)/)[1]
        photo = Base58.decode(enc)
        open(FlickrAPI(photo))
      rescue => ex
      end
    }
  end

  def FlickrAPI(photo)
    ses = Net::HTTP.new('www.flickr.com',443)
    ses.use_ssl = true
    ses.verify_mode = OpenSSL::SSL::VERIFY_NONE
    ses.start{ |session|
      apikey = '9874567293c02ee697ce3c607d29ef82'
      path = "/services/rest/?method=flickr.photos.getInfo&api_key=#{apikey}&photo_id=#{photo}&format=rest"
      response = session.get(path)
      return nil if (response == nil || response.code.to_i != 200)
      doc = REXML::Document.new(response.body)
      return nil if (doc.root.attributes['stat'] != 'ok')
      attr = doc.root.elements['photo'].attributes
      return "http://farm#{attr['farm']}.static.flickr.com/#{attr['server']}/#{attr['id']}_#{attr['secret']}_m.jpg"
    }
  end

end
