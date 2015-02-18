require 'onix/helper'
require 'onix/code'
require 'onix/entity'
require 'onix/descriptive_detail'
require 'onix/publishing_detail'
require 'onix/collateral_detail'
require 'onix/related_material'
require 'onix/supporting_resource'
require 'onix/subject'
require 'onix/contributor'
require 'onix/product_supply'
require 'onix/territory'
require 'onix/error'

module ONIX
  class Product < Subset
    # Record reference
    attr_accessor :record_reference
    # NotificationType object
    attr_accessor :notification_type
    # product Identifier object array
    attr_accessor :identifiers
    # RelatedMaterial object
    attr_accessor :related_material
    # DescriptiveDetail object
    attr_accessor :descriptive_detail
    # PublishingDetail object
    attr_accessor :publishing_detail
    # CollateralDetail object
    attr_accessor :collateral_detail
    # ProductSupply object array
    attr_accessor :product_supplies

    # default LanguageCode from ONIXMessage
    attr_accessor :default_language_of_text
    # default code from ONIXMessage
    attr_accessor :default_currency_code


    include EanMethods
    include ProprietaryIdMethods

    # :category: High level
    # product title string
    def title
      @descriptive_detail.title
    end

    # :category: High level
    # product subtitle string
    def subtitle
      @descriptive_detail.subtitle
    end

    # :category: High level
    # product description string including HTML
    def description
      if @collateral_detail
        @collateral_detail.description
      else
        nil
      end
    end

    # :category: High level
    # product larger front cover URL string
    def frontcover_url
      if @collateral_detail
        @collateral_detail.frontcover_url
      end
    end

    # :category: High level
    # product larger front cover last updated date
    def frontcover_last_updated
      if @collateral_detail
        @collateral_detail.frontcover_last_updated
      end
    end

    # :category: High level
    # product larger front cover mimetype
    def frontcover_mimetype
      if @collateral_detail
        @collateral_detail.frontcover_mimetype
      end
    end

    # :category: High level
    # ePub sample URL string
    def epub_sample_url
      if @collateral_detail
        @collateral_detail.epub_sample_url
      end
    end

    # :category: High level
    # ePub sample last updated date
    def epub_sample_last_updated
      if @collateral_detail
        @collateral_detail.epub_sample_last_updated
      end
    end

    # :category: High level
    # ePub sample mimetype
    def epub_sample_mimetype
      if @collateral_detail
        @collateral_detail.epub_sample_mimetype
      end
    end

    # :category: High level
    # product edition number
    def edition_number
      @descriptive_detail.edition_number
    end

    # product LanguageCode of text
    def language_of_text
      @descriptive_detail.language_of_text || @default_language_of_text
    end

    # :category: High level
    # product language code string of text (eg: fre)
    def language_code_of_text
      if self.language_of_text
        self.language_of_text.code
      end
    end

    # :category: High level
    # product language name string of text (eg: French)
    def language_name_of_text
      if self.language_of_text
        self.language_of_text.human
      end
    end

    # :category: High level
    # publisher collection title
    def publisher_collection_title
      @descriptive_detail.publisher_collection_title
    end

    def subjects
      @descriptive_detail.subjects
    end

    # BISAC categories Subject
    def bisac_categories
      @descriptive_detail.bisac_categories
    end

    # :category: High level
    # BISAC categories identifiers string array (eg: FIC000000)
    def bisac_categories_codes
      self.bisac_categories.map{|c| c.code}.uniq
    end

    # CLIL categories Subject
    def clil_categories
      @descriptive_detail.clil_categories
    end

    # :category: High level
    # CLIL categories identifier string array
    def clil_categories_codes
      self.clil_categories.map{|c| c.code}.uniq
    end

    # :category: High level
    # keywords string array
    def keywords
      @descriptive_detail.keywords
    end

    # :category: High level
    # Protection type string (None, Watermarking, Drm, AdobeDrm)
    def protection_type
      @descriptive_detail.protection_type
    end

    # :category: High level
    # product has DRM ?
    def drmized?
      if @descriptive_detail.protection_type =~ /Drm/
        true
      else
        false
      end
    end

    # :category: High level
    # is product digital ?
    def digital?
      @descriptive_detail.digital?
    end

    # :category: High level
    # is product a bundle of multiple parts ?
    def bundle?
      @descriptive_detail.bundle?
    end

    def sold_separately?
      @product_supplies.map{|ps| ps.supply_details.map{|sd| sd.sold_separately?}.flatten}.flatten.uniq.first
    end

    # :category: High level
    # bundle ProductPart array
    def parts
      @descriptive_detail.parts
    end

    # :category: High level
    # digital file filesize in bytes
    def filesize
      @descriptive_detail.filesize
    end

    # :category: High level
    # digital file format string (Epub,Pdf,Mobipocket)
    def file_format
      @descriptive_detail.file_format
    end

    # :category: High level
    # digital file mimetype (Epub,Pdf,Mobipocket)
    def file_mimetype
      @descriptive_detail.file_mimetype
    end

    # :category: High level
    # digital file description string
    def file_description
      @descriptive_detail.file_description
    end

    # :category: High level
    # raw file description string without HTML
    def raw_file_description
      if @descriptive_detail.file_description
        Helper.strip_html(@descriptive_detail.file_description).gsub(/\s+/," ").strip
      else
        nil
      end
    end

    # :category: High level
    # page count
    def pages
      @descriptive_detail.pages
    end

    # :category: High level
    # raw book description string without HTML
    def raw_description
      if self.description
        Helper.strip_html(self.description).gsub(/\s+/," ").strip
      else
        nil
      end
    end

    def publishers
      if @publishing_detail
        @publishing_detail.publishers
      else
        []
      end
    end

    def publisher
      if @publishing_detail
        @publishing_detail.publisher
      else
        nil
      end
    end

    # :category: High level
    # publisher name string, if multiple publishers are found, then they are concatenated with " / "
    def publisher_name
      if self.publishers.length > 0
        self.publishers.map{|p| p.name}.join(" / ")
      end
    end

    # :category: High level
    # publisher GLN string, nil if multiple publishers are found
    def publisher_gln
      if self.publishers.length==1
        self.publisher.gln
      end
    end

    def imprint
      if @publishing_detail
        @publishing_detail.imprint
      else
        nil
      end
    end

    # :category: High level
    # imprint name string
    def imprint_name
      if self.imprint
        self.imprint.name
      else
        nil
      end
    end

    # :category: High level
    # imprint GLN string
    def imprint_gln
      if self.imprint
        self.imprint.gln
      end
    end

    def distributors
      @product_supplies.map{|ps| ps.distributors}.flatten.uniq{|d| d.name}
    end

    # product distributor
    def distributor
      if self.distributors.length > 0
      if self.distributors.length==1
        self.distributors.first
      else
        raise ExpectsOneButHasSeveral, self.distributors.map(&:name)
      end
      else
        nil
      end
    end

    # :category: High level
    # product distributor name string
    def distributor_name
      if self.distributor
        self.distributor.name
      else
        nil
      end
    end

    # :category: High level
    # product distributor GLN string
    def distributor_gln
      if self.distributor
        self.distributor.gln
      else
        nil
      end
    end

    # :category: High level
    # paper linking RelatedProduct
    def part_of_product
      if @related_material
        @related_material.part_of_products.first
      end
    end

      # :category: High level
    # paper linking RelatedProduct
    def print_product
      if @related_material
        @related_material.print_products.first
      end
    end

    # DEPRECATED see print_product instead
    def paper_linking
      self.print_product
    end

    # :category: High level
    # date of publication
    def publication_date
      if @publishing_detail
        @publishing_detail.publication_date
      end
    end

    # :category: High level
    # product countries rights string array
    def countries_rights
      countries=[]
      if @publishing_detail
        countries+=@publishing_detail.sales_rights.map{|sr| sr.territory.countries}.flatten.uniq
      end

      if @product_supplies
        countries+=@product_supplies.map{|ps| ps.markets.map{|m| m.territory.countries}.flatten}.flatten.uniq
      end

      countries.uniq
    end

    # :category: High level
    # flattened supplies with prices
    #
    # supplies is a hash symbol array in the form :
    #   [{:available=>bool,
    #     :availability_date=>date,
    #     :including_tax=>bool,
    #     :currency=>string,
    #     :territory=>string,
    #     :prices=>[{:amount=>int,
    #                :from_date=>date,
    #                :until_date=>date}]}]
    def supplies
      supplies=[]

      # add territories if missing
      if @product_supplies
        @product_supplies.each do |ps|
          ps.supply_details.each do |sd|
            sd.prices.each do |p|
              supply={}
              supply[:available]=sd.available?
              supply[:availability_date]=sd.availability_date

              unless supply[:availability_date]
                if ps.market_publishing_detail
                  if ps.market_publishing_detail.availability_date
                    supply[:availability_date]=ps.market_publishing_detail.availability_date
                  end
                end
              end
              supply[:price]=p.amount
              supply[:including_tax]=p.including_tax?
              if !p.territory or p.territory.countries.length==0
                supply[:territory]=[]
                if ps.markets
                  supply[:territory]=ps.markets.map{|m| m.territory.countries}.flatten.uniq
                end
                if supply[:territory].length==0
                  if @publishing_detail
                    supply[:territory]=self.countries_rights
                  end
                end
              else
                supply[:territory]=p.territory.countries
              end
              supply[:from_date]=p.from_date
              supply[:until_date]=p.until_date
              supply[:currency]=p.currency

              unless supply[:availability_date]
                supply[:availability_date]=@publishing_detail.publication_date
              end

              supplies << supply
            end
          end
        end
      end

      # merge territories
      grouped_supplies={}
      supplies.each do |supply|
        pr_key="#{supply[:available]}#{supply[:including_tax]}#{supply[:from_date]}:#{supply[:until_date]}#{supply[:currency]}#{supply[:price]}"
        grouped_supplies[pr_key]||=supply
        grouped_supplies[pr_key][:territory]+=supply[:territory]
        grouped_supplies[pr_key][:territory].uniq!

      end

      supplies=grouped_supplies.to_a.map{|h| h.last}

      grouped_supplies={}
      supplies.each do |supply|
        pr_key="#{supply[:available]}#{supply[:including_tax]}#{supply[:currency]}#{supply[:territory].join(',')}"
        grouped_supplies[pr_key]||=[]
        grouped_supplies[pr_key] << supply
      end

      # render prices sequentially with dates
      grouped_supplies.each do |ksup, supply|
        if supply.length > 1
#          puts "MULTIPRICES"
          global_price=supply.select{|p| not p[:from_date] and not p[:until_date]}
#          pp global_price
          global_price=global_price.first
          if global_price
#            puts "FOUND GLOBAL"
            supply.each do |p|
              if p!=global_price
                if p[:from_date]
                  global_price[:until_date]=p[:from_date]
                end

                if p[:until_date]
                  np=global_price.dup
                  np[:from_date]=p[:until_date]
                  supply << np
                end

              end
            end
          else
            # remove explicit from date
            explicit_from=supply.select{|p| p[:from_date] and not supply.select{|sp| sp[:until_date] and sp[:until_date]<=p[:from_date]}.first}.first
            if explicit_from
              explicit_from[:from_date]=nil
            end
          end
        else
          supply.each do |s|
            s[:from_date]=nil
          end
        end
      end

      supplies=[]
      grouped_supplies.each do |ksup,supply|
        fsupply=supply.first
        supplies << {:including_tax=>fsupply[:including_tax],:currency=>fsupply[:currency],:territory=>fsupply[:territory],:available=>fsupply[:available], :availability_date=>fsupply[:availability_date],
                     :prices=>supply.map{|s|
                       s[:amount]=s[:price]
                       s.delete(:price)
                       s.delete(:available)
                       s.delete(:currency)
                       s.delete(:availability_date)
                       s.delete(:including_tax)
                       s.delete(:territory)
                       s
                     }}
      end

#      supplies=grouped_supplies.to_a.map{|h| h.last}.flatten

      supplies
    end

    # :category: High level
    # flattened supplies only including taxes
    def supplies_including_tax
      self.supplies.select{|p| p[:including_tax]}
    end

    # :category: High level
    # flattened supplies only excluding taxes
    def supplies_excluding_tax
      self.supplies.select{|p| not p[:including_tax]}
    end

    # :category: High level
    # flattened supplies with default tax (excluding tax for US and CA, including otherwise)
    def supplies_with_default_tax
      self.supplies_including_tax + self.supplies_excluding_tax.select{|s| ["CAD","USD"].include?(s[:currency])}
    end

    # :category: High level
    # flattened supplies for country
    def supplies_for_country(country,currency=nil)
      country_supplies=self.supplies
      if currency
        country_supplies=country_supplies.select{|s| s[:currency]==currency}
      end
      country_supplies.select{|s|
        if s[:territory].include?(country)
          true
        else
          false
        end
      }
    end

    # :category: High level
    # price amount for given +currency+ and country at time
    def at_time_price_amount_for(time,currency,country=nil)
      sups=self.supplies_with_default_tax.select { |p| p[:currency]==currency }
      if country
        sups=sups.select{|p| p[:territory].include?(country)}
      end
      if sups.length > 0
        # exclusive
        sup=sups.first[:prices].select { |p|
          (!p[:from_date] or p[:from_date].to_date <= time.to_date) and
              (!p[:until_date] or p[:until_date].to_date > time.to_date)
        }.first

        if sup
          sup[:amount]
        else
          # or inclusive
          sup=sups.first[:prices].select { |p|
            (!p[:from_date] or p[:from_date].to_date <= time.to_date) and
                (!p[:until_date] or p[:until_date].to_date >= time.to_date)
          }.first

          if sup
            sup[:amount]
          else
            nil
          end
        end

      else
        nil
      end
    end

    # :category: High level
    # current price amount for given +currency+ and country
    def current_price_amount_for(currency,country=nil)
      at_time_price_amount_for(Time.now,currency,country)
    end

    def available_product_supplies
      @product_supplies.select{|ps| ps.available?}
    end

    # :category: High level
    # is product available ?
    def available?
      self.available_product_supplies.length > 0 and not self.delete?
    end

    # :category: High level
    # is product available for given +country+ ?
    def available_for_country?(country)
      self.supplies_for_country(country).select{|s| s[:available]}.length > 0 and self.available?
    end

    # :category: High level
    # is a deletion notification ?
    def delete?
      self.notification_type.human=="Delete"
    end

    # :category: High level
    # Contributor array
    def contributors
      @descriptive_detail.contributors
    end


    def initialize
      @identifiers=[]
      @product_supplies=[]
    end

    def parse(n)
      n.children.each do |t|
        case t.name
          when "RecordReference"
            @record_reference = t.text.strip
          when "ProductIdentifier"
            @identifiers << Identifier.parse_identifier(t, "Product")
          when "NotificationType"
            @notification_type=NotificationType.from_code(t.text)
          when "RelatedMaterial"
            @related_material=RelatedMaterial.from_xml(t)
          when "DescriptiveDetail"
            @descriptive_detail=DescriptiveDetail.from_xml(t)
          when "CollateralDetail"
            @collateral_detail=CollateralDetail.from_xml(t)
          when "PublishingDetail"
            @publishing_detail=PublishingDetail.from_xml(t)
          when "ProductSupply"
            @product_supplies << ProductSupply.from_xml(t)
        end
      end

    end
  end
end
