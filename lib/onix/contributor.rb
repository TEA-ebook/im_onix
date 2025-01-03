require 'onix/subset'

module ONIX
  class Contributor < Subset
    attr_accessor :name_before_key, :key_names, :person_name, :inverted_name, :role, :biography_note, :place, :sequence_number, :name_identifiers

    def initialize()
      @name_identifiers = []
    end

    # :category: High level
    # flatten person name (firstname lastname)
    def name
      if @person_name
        @person_name
      else
        if @key_names
          if @name_before_key
            "#{@name_before_key} #{@key_names}"
          else
            @key_names
          end
        end
      end
    end

    # :category: High level
    # inverted flatten person name
    def inverted_name
      @inverted_name
    end

    # :category: High level
    # biography string with HTML
    def biography
      @biography_note
    end

    # :category: High level
    # raw biography string without HTML
    def raw_biography
      if self.biography
        Helper.strip_html(self.biography).gsub(/\s+/," ")
      else
        nil
      end
    end

    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("SequenceNumber")
            @sequence_number=t.text.to_i
          when tag_match("NamesBeforeKey")
            @name_before_key=t.text
          when tag_match("KeyNames")
            @key_names=t.text
          when tag_match("PersonName")
            @person_name=t.text
          when tag_match("PersonNameInverted")
            @inverted_name=t.text
          when tag_match("BiographicalNote")
            @biography_note=t.text.strip
          when tag_match("ContributorRole")
            @role=ContributorRole.from_code(t.text)
          when tag_match("ContributorPlace")
            @place=ContributorPlace.from_xml(t)
          when tag_match("NameIdentifier")
            @name_identifiers.push ContributorNameIdentifier.from_xml(t)
        end
      end
    end

    class ContributorPlace < Subset
      attr_accessor :relator, :country_code

      def parse(p)
        p.children.each do |tag|
          case tag
            when tag_match('ContributorPlaceRelator')
              @relator=ContributorPlaceRelator.from_code(tag.text)
            when tag_match('CountryCode')
              @country_code=tag.text
          end
        end
      end
    end

    class ContributorNameIdentifier < Subset
      attr_accessor :name_id_type, :id_value, :id_type_name

      def parse(p)
        p.children.each do |tag|
          case tag
            when tag_match('NameIDType')
              @name_id_type = ContributorNameIdentifierNameIDType.from_code(tag.text)
            when tag_match('IDValue')
              @id_value = tag.text
            when tag_match('IDTypeName')
              @id_type_name = tag.text
          end
        end
      end
    end
  end
end
