require 'onix/identifier'

module ONIX
  class TitleElement < Subset
    attr_accessor :level, :title_prefix, :title_without_prefix, :title_text, :subtitle, :part_number

    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("TitleElementLevel")
            @level=TitleElementLevel.from_code(t.text)
          when tag_match("TitleText")
            @title_text=t.text
          when tag_match("TitlePrefix")
            @title_prefix=t.text
          when tag_match("TitleWithoutPrefix")
            @title_without_prefix=t.text
          when tag_match("Subtitle")
            @subtitle=t.text
          when tag_match("PartNumber")
            @part_number=t.text.to_i
        end
      end
    end

    # :category: High level
    # flatten title string
    def title
      if @title_text
        @title_text
      else
        if @title_without_prefix
          if @title_prefix
            "#{@title_prefix} #{@title_without_prefix}"
          else
            @title_without_prefix
          end
        end
      end
    end
  end

  class TitleDetail < Subset
    attr_accessor :type, :title_elements

    def initialize
      @title_elements=[]
    end

    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("TitleType")
            @type=TitleType.from_code(t.text)
          when tag_match("TitleElement")
            @title_elements << TitleElement.from_xml(t)
        end
      end
    end
  end

  class Collection < Subset
    attr_accessor :type, :identifiers, :title_details, :empty

    def initialize
      @empty=true
      @identifiers=[]
      @title_details=[]
    end

    # :category: High level
    # collection title string
    def title
      if collection_title_element
        collection_title_element.title
      end
    end

    # :category: High level
    # collection subtitle string
    def subtitle
      if collection_title_element
        collection_title_element.subtitle
      end
    end

    def collection_title_element
      distinctive_title=@title_details.select { |td| td.type.human=~/DistinctiveTitle/ }.first
      if distinctive_title
        distinctive_title.title_elements.select{ |te| te.level.human=~/CollectionLevel/ }.first
      end
    end
    
    def parse(n)
      @empty = n.children.empty?
      n.children.each do |t|
        case t
          when tag_match("CollectionIdentifier")
            @identifiers << Identifier.parse_identifier(t,"Collection")
          when tag_match("CollectionType")
            @type=CollectionType.from_code(t.text)
          when tag_match("TitleDetail")
            @title_details << TitleDetail.from_xml(t)
        end
      end
    end
  end

  # product part use full Product to provide file protection and file size
  class ProductPart < Subset
    attr_accessor :identifiers, :form, :form_details, :form_description, :content_types
    # full Product if referenced in ONIXMessage
    attr_accessor :product
    # this ProductPart is part of Product
    attr_accessor :part_of

    include EanMethods
    include ProprietaryIdMethods

    def initialize
      @identifiers = []
      @form_details = []
      @content_types = []
    end

    # :category: High level
    # digital file format string (Epub,Pdf,AmazonKindle)
    def file_format
      self.file_formats.first.human if self.file_formats.first
    end

    def file_mimetype
      if self.file_formats.first
        self.file_formats.first.mimetype
      end
    end

    def file_formats
      @form_details.select{|fd| fd.code =~ /^E1.*/}
    end

    def reflowable?
      return true if @form_details.select{|fd| fd.code == "E200"}.length > 0
      return false if @form_details.select{|fd| fd.code == "E201"}.length > 0
    end

    # :category: High level
    # part file description string
    def file_description
      @form_description
    end

    # :category: High level
    # raw part file description string without HTML
    def raw_file_description
      if @form_description
        Helper.strip_html(@form_description).gsub(/\s+/," ").strip
      else
        nil
      end
    end

    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("ProductIdentifier")
            @identifiers << Identifier.parse_identifier(t,"Product")
          when tag_match("ProductForm")
            @form=ProductForm.from_code(t.text)
          when tag_match("ProductFormDescription")
            @form_description=t.text
          when tag_match("ProductFormDetail")
            @form_details << ProductFormDetail.from_code(t.text)
          when tag_match("ProductContentType")
            @content_types << ProductContentType.from_code(t.text)
        end
      end

    end

    # :category: High level
    # Protection type string (None, Watermarking, DRM, AdobeDRM)
    def protection_type
      if product
        product.protection_type
      else
        if part_of
          part_of.protection_type
        else
          nil
        end
      end
    end

    # :category: High level
    # List of protections type string (None, Watermarking, DRM, AdobeDRM)
    def protections
      if product
        product.protections
      else
        if part_of
          part_of.protections
        else
          nil
        end
      end
    end

    # :category: High level
    # digital file filesize in bytes
    def filesize
      if product
        product.filesize
      else
        nil
      end
    end

  end

  class Extent < Subset
    attr_accessor :type, :value, :unit

    def bytes
      case @unit.human
        when "Bytes"
          @value.to_i
        when "Kbytes"
          (@value.to_f*1024).to_i
        when "Mbytes"
          (@value.to_f*1024*1024).to_i
        else
          nil
      end
    end

    def pages
      if @unit.human=="Pages"
        @value.to_i
      else
        nil
      end
    end

    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("ExtentType")
            @type=ExtentType.from_code(t.text)
          when tag_match("ExtentUnit")
            @unit=ExtentUnit.from_code(t.text)
          when tag_match("ExtentValue")
            @value=t.text
        end
      end
    end
  end

  class EpubUsageLimit < Subset
    attr_accessor :quantity, :unit

    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("EpubUsageUnit")
            @unit=EpubUsageUnit.from_code(t.text)
          when tag_match("Quantity")
            @quantity=t.text.to_i
        end
      end
    end
  end

  class EpubUsageConstraint < Subset
    attr_accessor :type, :status, :limits

    def initialize
      @limits=[]
    end

    def parse(drm)
      drm.children.each do |t|
        case t
          when tag_match("EpubUsageType")
            @type=EpubUsageType.from_code(t.text)
          when tag_match("EpubUsageStatus")
            @status=EpubUsageStatus.from_code(t.text)
          when tag_match("EpubUsageLimit")
            @limits << EpubUsageLimit.from_xml(t)
        end
      end

    end
  end

  class Language < Subset
    attr_accessor :role, :code
    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("LanguageRole")
            @role=LanguageRole.from_code(t.text)
          when tag_match("LanguageCode")
            @code=LanguageCode.from_code(t.text)
        end
      end

    end
  end

  class AudienceRange < Subset
    attr_accessor :limits
    def parse(n)
      @limits = Array.new
      qualifier = n.xpath("./AudienceRangeQualifier")
      precisions = n.xpath("./AudienceRangePrecision")
      values = n.xpath("./AudienceRangeValue")

      for i in 0..precisions.children.size-1
        @limits << { :qualifier => AudienceRangeQualifier.from_code(qualifier[0].content),
                     :precision => AudienceRangePrecision.from_code(precisions[i].content),
                     :value => values[i].content}
      end
    end
  end

  class ProductFormFeature < Subset
    attr_accessor :type, :value, :descriptions

    def initialize
      @descriptions=[]
    end

    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("ProductFormFeatureType")
            @type=ProductFormFeatureType.from_code(t.text)
          when tag_match("ProductFormFeatureValue")
            @value=t.text
          when tag_match("ProductFormFeatureDescription")
            @descriptions << t.text
        end
      end

    end

  end
  class DescriptiveDetail < Subset
    attr_accessor :title_details, :collection,
                  :languages,
                  :composition,
                  :form, :form_details, :form_features, :form_description, :content_types, :parts,
                  :edition_number,
                  :edition_types,
                  :contributors,
                  :subjects,
                  :collections,
                  :extents,
                  :epub_technical_protections, :epub_usage_constraints,
                  :audience_range

    def initialize
      @title_details=[]
      @text_contents=[]
      @parts=[]
      @contributors=[]
      @subjects=[]
      @collections=[]
      @extents=[]
      @epub_technical_protections=[]
      @epub_usage_constraints=[]
      @languages=[]
      @form_details=[]
      @form_features=[]
      @content_types=[]
      @edition_types=[]
      @audience_range=[]
    end

    # :category: High level
    # product title string
    def title
      product_title_element.title
    end

    # :category: High level
    # product subtitle string
    def subtitle
      product_title_element.subtitle
    end

    def product_title_element
      distinctive_title=@title_details.select { |td| td.type.human=~/DistinctiveTitle/ }.first
      if distinctive_title
        distinctive_title.title_elements.select{ |te| te.level.human=~/Product/ }.first
      end
    end

    def pages_extent
      @extents.select{|e| e.type.human=~/PageCount/ || e.type.human=~/NumberOfPage/}.first
    end

    def pages
      if pages_extent
        pages_extent.pages
      else
        nil
      end
    end

    def filesize_extent
      @extents.select{|e| e.type.human=="Filesize"}.first
    end

    def filesize
      if filesize_extent
        filesize_extent.bytes
      else
        nil
      end
    end

    def digital?
      if @form and @form.human=~/Digital/
        true
      else
        false
      end
    end

    def streaming?
      @form.code=="EC"
    end

    def audio?
      not audio_formats.empty?
    end

    def audio_format
      self.audio_formats.first.human if self.audio_formats.first
    end

    def audio_formats
      @form_details.select{|fd| fd.code =~ /^A.*/}
    end

    def bundle?
      @composition.human=="MultipleitemRetailProduct"
    end

    def file_format
      self.file_formats.first.human if self.file_formats.first
    end

    def file_mimetype
      if self.file_formats.first
        self.file_formats.first.mimetype
      end
    end

    def file_formats
      @form_details.select{|fd| fd.code =~ /^E1.*/}
    end

    def reflowable?
      return true if @form_details.select{|fd| fd.code == "E200"}.length > 0
      return false if @form_details.select{|fd| fd.code == "E201"}.length > 0
    end

    def file_description
      @form_description
    end

    def protection_type
      if @epub_technical_protections.length > 0
        if @epub_technical_protections.length == 1
          @epub_technical_protections.first.human
        else
          raise ExpectsOneButHasSeveral, @epub_technical_protections.map(&:type)
        end
      end
    end

    def protections
      return nil if @epub_technical_protections.length == 0

      @epub_technical_protections.map(&:human)
    end

    def language_of_text
      l=@languages.select{|l| l.role.human=="LanguageOfText"}.first
      if l
        l.code
      else
        nil
      end
    end

    def publisher_collection
      @collections.select{|c| c.type.human=="PublisherCollection"}.first
    end

    def publisher_collection_title
      if self.publisher_collection
        self.publisher_collection.title
      end

    end

    def bisac_categories
      @subjects.select{|s| s.scheme_identifier.human=="BisacSubjectHeading"}
    end

    def clil_categories
      @subjects.select{|s| s.scheme_identifier.human=="Clil"}
    end

    def proprietary_categories
      @subjects.select{|s| s.scheme_identifier.human=="ProprietarySubjectScheme"}
    end

    def keywords
      kws=@subjects.select{|s| s.scheme_identifier.human=="Keywords"}.map{|kw| kw.heading_text}.compact
      kws.map{|kw| kw.split(/;|,|\n/)}.flatten.map{|kw| kw.strip}
    end

    def illustrated?
      @edition_types.include?('ILL')
    end

    def enhanced?
      @edition_types.include?('ENH')
    end

    def digital_original?
      @edition_types.include?('DGO')
    end

    def parse(n)

      n.children.each do |t|
        case t
          when tag_match("TitleDetail")
            @title_details << TitleDetail.from_xml(t)
          when tag_match("Contributor")
            @contributors << Contributor.from_xml(t)
          when tag_match("Collection")
            @collections << Collection.from_xml(t)
          when tag_match("Extent")
            @extents << Extent.from_xml(t)
          when tag_match("EditionNumber")
            @edition_number=t.text.to_i
          when tag_match("EditionType")
            @edition_types << t.text
          when tag_match("Language")
            @languages << Language.from_xml(t)
          when tag_match("ProductComposition")
            @composition=ProductComposition.from_code(t.text)
          when tag_match("ProductForm")
            @form=ProductForm.from_code(t.text)
          when tag_match("ProductFormFeature")
            @form_features << ProductFormFeature.from_xml(t)
          when tag_match("ProductFormDescription")
            @form_description=t.text
          when tag_match("ProductFormDetail")
            @form_details << ProductFormDetail.from_code(t.text)
          when tag_match("ProductContentType")
            @content_types << ProductContentType.from_code(t.text)
          when tag_match("EpubTechnicalProtection")
            @epub_technical_protections << EpubTechnicalProtection.from_code(t.text)
          when tag_match("EpubUsageConstraint")
            @epub_usage_constraints << EpubUsageConstraint.from_xml(t)
          when tag_match("ProductPart")
            part=ProductPart.from_xml(t)
            part.part_of=self
            @parts << part
          when tag_match("Subject")
            @subjects << Subject.from_xml(t)
        when tag_match("AudienceRange")
            audience_ranges = AudienceRange.from_xml(t)
            audience_ranges.limits.each do |limit|
              @audience_range << {:qualifier => limit[:qualifier], :precision => limit[:precision], :value => limit[:value]}
            end
        end
      end

      end
    end
  end
