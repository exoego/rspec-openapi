# frozen_string_literal: true

require 'spec_helper'
require 'rspec/openapi'

# Mock Rails
module Rails
  def self.application
    nil
  end
end unless defined?(::Rails)

require 'rspec/openapi/extractors/rails'

RSpec.describe RSpec::OpenAPI::Extractors::Rails do
  describe '.find_rails_route (private)' do
    subject { described_class.send(:find_rails_route, request, app: app) }

    let(:request) { instance_double(ActionDispatch::Request, params: { id: 1 }) }
    let(:app) { instance_double('RailsApplication', routes: routes) }
    let(:router) { instance_double(ActionDispatch::Journey::Router) }
    let(:routes) { instance_double(ActionDispatch::Routing::RouteSet, router: router) }
    let(:route) { instance_double(ActionDispatch::Journey::Route, path: path, app: route_app) }
    let(:route_app) { instance_double(ActionDispatch::Routing::RouteSet::Dispatcher) }
    let(:path_spec) { instance_double(ActionDispatch::Journey::Path::Pattern, to_s: '/users/:id(.:format)') }
    let(:path) { instance_double(ActionDispatch::Journey::Path::Pattern, spec: path_spec) }

    context 'when route does not match request' do
      before do
        allow(route_app).to receive(:matches?).with(request).and_return(false)
        allow(router).to receive(:recognize) do |_req, &block|
          block.call(route, {})
        end
      end

      it { is_expected.to be_nil }
    end

    context 'when route matches request' do
      before do
        allow(route_app).to receive(:matches?).with(request).and_return(true)
        allow(route_app).to receive(:engine?).and_return(false)
        allow(router).to receive(:recognize) do |_req, &block|
          block.call(route, {})
        end
      end

      it { is_expected.to eq([route, '/users/:id']) }
    end
  end
end
