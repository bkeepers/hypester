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

    it 'does not pretty print json by default' do
      json = render "resource {|r| r.link :foo, '/foo' }"
      expect(json).to_not include("\n")
    end

    {
      'Safari' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.56 Safari/536.5',
      'Curl' => 'curl/7.24.0 (x86_64-apple-darwin12.0) libcurl/7.24.0 OpenSSL/0.9.8x zlib/1.2.5',
      'Wget' => 'Wget/1.9.1'
    }.each do |name, useragent|
      it "pretty prints for #{name}" do
        view.request.stub :user_agent => useragent
        json = render "resource {|r| r.foo 'bar' }"
        expect(json).to include("\n")
        expect(json[-1]).to eql("\n")
      end
    end

    context 'embedding' do
      class Category < Struct.new(:name)
        extend ActiveModel::Naming

        def to_partial_path
          'categories/category'
        end
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
