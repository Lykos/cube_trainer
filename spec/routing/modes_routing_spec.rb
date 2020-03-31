require "rails_helper"

RSpec.describe ModesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/modes").to route_to("modes#index")
    end

    it "routes to #new" do
      expect(:get => "/modes/new").to route_to("modes#new")
    end

    it "routes to #show" do
      expect(:get => "/modes/1").to route_to("modes#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/modes/1/edit").to route_to("modes#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/modes").to route_to("modes#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/modes/1").to route_to("modes#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/modes/1").to route_to("modes#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/modes/1").to route_to("modes#destroy", :id => "1")
    end
  end
end
