module Hypester
  class Link
    attr_reader :rel

    def initialize(rel, href, options = {})
      @rel = rel.to_s
      @attributes = options.with_indifferent_access.merge('href' => href)
    end

    def as_json(options=nil)
      @attributes
    end
  end
end
