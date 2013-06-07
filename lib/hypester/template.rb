require 'active_support/core_ext/class/attribute_accessors'
require 'action_dispatch/http/mime_type'

module Hypester
  module TemplateMethods
    def resource(object = self, &block)
      Hypester::Resource.new(self, object).tap(&block)
    end
  end

  class Template
    cattr_accessor :default_format
    self.default_format = Mime::JSON

    def self.call(template)
      "extend Hypester::TemplateMethods; " +
      "begin;#{template.source};end.to_json"
    end
  end
end

ActionView::Template.register_template_handler :hype, Hypester::Template
