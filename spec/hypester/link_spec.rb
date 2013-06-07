require 'spec_helper'

describe Hypester::Link do
  def link(*args)
    Hypester::Link.new(*args)
  end

  describe 'rel' do
    it 'gets converted to a string' do
      expect(link(:foo, '/foo').rel).to eql('foo')
    end
  end

  describe 'as_json' do
    it { expect(link(:foo, '/foo').as_json).to eql({'href' => '/foo'}) }
    it { expect(link(:foo, '/foo', :title => 'Foo').as_json).to eql({'href' => '/foo', 'title' => 'Foo'}) }
  end
end
