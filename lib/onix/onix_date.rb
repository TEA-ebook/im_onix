module ONIX
  # FIXME : support only 00,01,05 and 14 date format
  class OnixDate < Subset
    attr_accessor :format, :date

    def parse(n)
      @format=DateFormat.from_code("00")
      date_txt=nil
      @date=nil
      n.children.each do |t|
        case t
          when tag_match("DateFormat")
            @format=DateFormat.from_code(t.text)
          when tag_match("Date")
            date_txt=t.text
            @format=DateFormat.from_code(t.attribute('dateformat').text) unless t.attribute('dateformat').nil?
        end
      end

      code_format=format_from_code(@format.code)
      text_format=format_from_string(date_txt)

      format=code_format

      if code_format!=text_format
#        puts "EEE date #{n.text} (#{text_format}) do not match code #{@format.code} (#{code_format})"
        format=text_format
      end

      begin
      if format
      case @format.code
        when "00"
          @date=Date.strptime(date_txt, format)
        when "01"
          @date=Date.strptime(date_txt, format)
        when "05"
          @date=Date.strptime(date_txt, format)
        when "14"
          @date=Time.strptime(date_txt, format)
        else
          @date=nil
      end
      end
      rescue
        # invalid date
      end
    end

    def format_from_code(code)
      case code
      when "00"
        "%Y%m%d"
      when "01"
        "%Y%m"
      when "05"
        "%Y"
      when "14"
        "%Y%m%dT%H%M%S%z"
      else
        nil
      end
    end

    def format_from_string(str)
      case str
        when /^\d{4}\d{2}\d{2}T\d{2}\d{2}\d{2}/
          "%Y%m%dT%H%M%S%z"
        when /^\d{4}\-\d{2}\-\d{2}$/
          "%Y-%m-%d"
        when /^\d{4}\d{2}\d{2}$/
          "%Y%m%d"
        when /^\d{4}\d{2}$/
          "%Y%m"
        when /^\d{4}$/
          "%Y"
        else
          nil
      end
    end


    def time
      @date.to_time
    end

  end
end
