require 'spec_helper'
require 'multi_json'

describe Hypester::Template, :type => :view do
  def render(template)
    stub_template 'json.hype' => template
    super :file => 'json'
  end

  context 'rendering' do
    it 'renders json' do
      json = render "resource {|r| r.link :foo, '/foo' }"
      expect(MultiJson.load(json)).to eql({'_links' => {'foo' => {'href' => '/foo'}}})
    end

    it 'can access instance variables' do
      assign :href, "http://example.com/"
      json = render "resource {|r| r.link :self, @href }"
      expect(MultiJson.load(json)).to eql({'_links' => {'self' => {'href' => 'http://example.com/'}}})
    end

    context 'embedding' do
      class Category < Struct.new(:name)
        extend ActiveModel::Naming
      end

      before { stub_template 'categories/_category.hype' => "r.property :name" }

      it 'can embed an object' do
        assign :category, Category.new('Hypermedia')
        json = render 'resource {|r| r.embed :category, @category }'
        expect(MultiJson.load(json)).to eql({
          '_embedded' => {'category' => {'name' => 'Hypermedia'}}
        })
      end

      it 'can embed a collection' do
        assign :categories, [Category.new('Hypermedia'), Category.new('APIs')]
        json = render 'resource {|r| r.embed :categories, @categories }'
        expect(MultiJson.load(json)).to eql({
          '_embedded' => {
            'categories' => [{'name' => 'Hypermedia'}, {'name' => 'APIs'}]
          }
        })
      end

      it 'skips embed if object is nil' do
        json = render 'resource {|r| r.embed :things, nil }'
        expect(MultiJson.load(json)).to eql({})
      end
    end
  end
end
