require 'spec_helper'

describe Hypester::Resource do
  let(:view) { mock(:view) }
  let(:object) { mock(:object, :id => 1, :name => 'Brandon') }
  let(:resource) { Hypester::Resource.new(view, object) }

  it 'has an object accessor' do
    resource.object.should == object
  end

  describe 'property' do
    it 'extracts properties from context' do
      resource.property :id, :name
      expect(resource.as_json).to eql('id' => 1, 'name' => 'Brandon')
    end
  end

  describe 'link' do
    it 'adds links' do
      resource.link :self, '/self'
      expect(resource.as_json).to eql('_links' => {'self' => {'href' => '/self'}})
    end
  end

  describe 'embed' do
    let(:dog) { mock(:dog) }

    before { object.stub! :dog => dog }

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
  end
end
