require './wrappers/restclientWrapper'
require 'nokogiri'
require 'json'

class Meralco

	def initialize(session = nil)
		@session = session
	end

  def download(options)
    rest = RestclientWrapper.new()

    url = "https://company.meralco.com.ph/views/ajax"

    place = 216 # Makati
    today = Date.today
    for i in 0..6 do
      start_date = (today + i).strftime("%m/%d/%Y")
      payload = <<-PAYLOAD.gsub(/\s+/, "").strip
        field_service_maintenance_loc_target_id=#{place}
        &date_range_filter=#{start_date}
        &view_name=maintenance_schedule_shared
        &view_display_id=block_1
        &ajax_page_state[libraries]=addtoany/addtoany,better_exposed_filters/auto_submit,better_exposed_filters/datepickers,better_exposed_filters/general,core/html5shiv,core/jquery.ui.datepicker,default/font-awesome,default/global-fonts,default/global-styling,default/js-footer,default/js-header,default/js-node-page,meralco_configuration/meralco_configuration.ereport,meralco_content/show-more-less,meralco_webform/webform,mosaic/mosaic,mosaic/mosaic.cookienotice,profiling/tracker,system/base,views/views.ajax,views/views.module,views_infinite_scroll/views-infinite-scroll
      PAYLOAD

      response = rest.post(url, payload, @session)
      response = response.split(',"data":')[1]

      puts "\n----------".blue
      if response.include? 'No results found'
        puts "\n#{(today + i).strftime("%m/%d/%Y (%A)")}: No power interruptions".green
      else
        response = response.split('u0022field-content\u0022\u003E\u003C')
        puts "\nWhen: ".yellow + response[1].split('data-a2a-title=\u0022')[1].split('\u0022')[0].gsub(' \u2013 ', '-').strip.red
        puts "\nWhere: ".yellow
        puts "\t" + response[2].split('BETWEEN')[1].split('\u003C')[0].gsub('\u2013', ' - ').strip.red
        portions = response[2].split('Portion of')
        portions.each { |portion|
          portion = portion.split('\u003C')[0].gsub('\u00f1', 'ñ').gsub('\u00a0', '').strip
          puts "\n\tPortion of " + portion unless portion.include? '\u003E'
        }
        puts "\nReason: ".yellow + response[3].split('u003EREASON\u003C\/strong\u003E: ')[1].split('\u003C')[0].strip
      end
    end
	end

end
