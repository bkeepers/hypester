module Hypester
  class Resource
    attr_reader :object

    def initialize(view, object)
      @view = view
      @object = object
      @properties = ActiveSupport::OrderedHash.new
    end

    def property(*properties)
      properties.each do |name|
        @properties[name] = @object.send(name)
      end
      self
    end

    def link(*args)
      link = Link.new(*args)
      @properties[:_links] ||= ActiveSupport::OrderedHash.new
      @properties[:_links][link.rel] = link
      self
    end

    def embed(rel, object = nil)
      object = @object.send(rel) if object.nil? && @object.respond_to?(rel)
      return unless object

      result = if object.respond_to?(:to_ary)
        object.map {|o| resource(o) }
      else
        resource(object)
      end

      Array.wrap(result).each(&:partial!)

      @properties[:_embedded] ||= ActiveSupport::OrderedHash.new
      @properties[:_embedded][rel.to_s] = result
      self
    end

    def render(*args)
      options = args.extract_options!
      @view.render *args.push(options.merge(:r => self))
      self
    end

    def partial!
      render @object
      self
    end

    def as_json(options=nil)
      @properties.as_json(options)
    end

    # Internal
    def resource(object)
      Resource.new(@view, object)
    end
  end
end
