module ONIX
  class Subject < Subset
    attr_accessor :code, :heading_text, :scheme_identifier, :scheme_name, :scheme_version


    def parse(n)
      n.children.each do |t|
        case t
          when tag_match("SubjectHeadingText")
            @heading_text=t.text.strip
          when tag_match("SubjectCode")
            @code=t.text.strip
          when tag_match("SubjectSchemeIdentifier")
            @scheme_identifier=SubjectSchemeIdentifier.from_code(t.text)
          when tag_match("SubjectSchemeName")
            @scheme_name=t.text.strip
          when tag_match("SubjectSchemeVersion")
            @scheme_version=t.text.strip
        end
      end
    end
  end
end