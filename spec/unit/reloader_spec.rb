require 'spec_helper'

# Ensure we have both constants to play with
begin
  ActionDispatch::Reloader
rescue
  module ActionDispatch; module Reloader; def self.to_prepare; end; end; end
end

begin
  ActionDispatch::Callbacks
rescue
  module ActionDispatch; module Callbacks; def self.to_prepare; end; end; end
end

major_rails_version = Rails.version[0..2]


describe ActiveAdmin::Reloader do

  let(:rails_app){ mock(:reload_routes! => true)}
  let(:mock_app){ mock(:load_paths => ["app/admin"], :unload! => true)}
  let(:reloader){ ActiveAdmin::Reloader.build(rails_app, mock_app, rails_version) }

  context "when Rails >= 3.2" do
    let(:rails_version){ TRAVIS_RAILS_VERSIONS.grep(/^3.2/).first }

    describe "initialization" do

      it "should build a Rails32Reloader" do
        reloader.class.should == ActiveAdmin::Reloader::Rails32Reloader
      end

    end

    describe "attach!" do
      before do
        mock_app.load_paths << "app/active_admin"
        ActionDispatch::Reloader.stub!(:to_prepare => true)
      end

      it "should the load paths to the watchable_dirs" do
        config = mock(:watchable_dirs => {})
        rails_app.should_receive(:config).twice.and_return(config)
        reloader.attach!

        config.watchable_dirs["app/admin"].should == [:rb]
        config.watchable_dirs["app/active_admin"].should == [:rb]
      end
    end
  end

end
