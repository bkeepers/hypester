require 'active_support/core_ext/class/attribute_accessors'
require 'action_dispatch/http/mime_type'

module Hypester
  module TemplateMethods
    def pretty_json?
      !(request.user_agent !~ /(^(curl|Wget)|\b(Safari|Firefox))\b/)
    end

    def resource(object = self, &block)
      Hypester::Resource.new(self, object).tap(&block)
    end
  end

  class Template
    cattr_accessor :default_format
    self.default_format = Mime::JSON

    def self.call(template)
      "extend Hypester::TemplateMethods;" +
      "MultiJson.dump(begin;#{template.source};end.as_json, :pretty => pretty_json?)" +
      "+ (pretty_json? ? \"\n\" : '')"
    end
  end
end

ActionView::Template.register_template_handler :hype, Hypester::Template
