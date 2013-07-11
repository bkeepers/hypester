require 'spec_helper'

describe Hypester::Resource do
  let(:view) { double(:view) }
  let(:object) { double(:object, :id => 1, :name => 'Brandon') }
  let(:resource) { Hypester::Resource.new(view, object) }

  it 'has an object accessor' do
    resource.object.should == object
  end

  describe 'method_missing' do
    it 'extracts the property' do
      resource.name
      expect(resource.as_json).to eql('name' => 'Brandon')
    end

    it 'uses given value' do
      resource.jeans 'skinny'
      expect(resource.as_json).to eql('jeans' => 'skinny')
    end
  end

  describe 'respond_to?' do
    it 'is true for defined methods' do
      expect(resource).to respond_to(:property)
    end

    it 'is true for methods on the object' do
      expect(resource).to respond_to(:name)
    end

    it 'is false for methods not defined on the object' do
      expect(resource).to_not respond_to(:never_heard_of_it)
    end
  end

  describe 'property' do
    it 'extracts the properties from the object' do
      resource.property :id
      expect(resource.as_json).to eql('id' => 1)
    end

    it 'uses the given value' do
      resource.property :favorite_beer, 'PBR'
      expect(resource.as_json).to eql('favorite_beer' => 'PBR')
    end

    it 'returns itself' do
      expect(resource.property(:id)).to be(resource)
    end
  end

  describe 'properties' do
    it 'extracts the given properties' do
      resource.properties :id, :name
      expect(resource.as_json).to eql('id' => 1, 'name' => 'Brandon')
    end

    it 'returns itself' do
      expect(resource.properties(:id)).to be(resource)
    end
  end

  describe 'link' do
    it 'adds links' do
      resource.link :self, '/self'
      expect(resource.as_json).to eql('_links' => {'self' => {'href' => '/self'}})
    end

    it 'returns itself' do
      expect(resource.link(:self, '/self')).to be(resource)
    end
  end

  describe 'embed' do
    let(:dog) { double(:dog) }

    before { object.stub :dog => dog }

    it 'renders a partial using the object from the named property' do
      view.should_receive(:render).with(dog,
        :r => instance_of(Hypester::Resource))

      resource.embed :dog
    end

    it 'renders a partial with the given object' do
      view.should_receive(:render).with(dog,
        :r => instance_of(Hypester::Resource))

      resource.embed :thing, dog
    end

    it 'returns itself' do
      view.stub :render

      expect(resource.embed(:dog, dog)).to be(resource)
    end
  end
end
