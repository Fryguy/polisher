# Polisher Koji Spec
#
# Licensed under the MIT license
# Copyright (C) 2013-2014 Red Hat, Inc.

require 'polisher/koji'

module Polisher
  describe Koji do
    describe "::has_build?" do
      context "retrieved versions includes the specified version" do
        it "returns true" do
          described_class.should_receive(:versions_for).and_return(['1.0.0'])
          described_class.has_build?('foobar', '1.0.0').should be_true
        end
      end

      context "retrieved versions does not include the specified version" do
        it "returns false" do
          described_class.should_receive(:versions_for).and_return(['1.0.1'])
          described_class.has_build?('foobar', '1.0.1').should be_true
        end
      end
    end

    describe "#has_build_satisfying?" do
      context "retrieved versions satisfy the specified dependency" do
        it "returns true" do
          described_class.should_receive(:versions_for).and_return(['1.0.0'])
          described_class.has_build_satisfying?('foobar', '> 0.9.0').should be_true
        end
      end

      context "retrieved versions does not satisfy the specified dependency" do
        it "returns false" do
          described_class.should_receive(:versions_for).and_return(['1.0.0'])
          described_class.has_build_satisfying?('foobar', '< 0.9.0').should be_false
        end
      end
    end

    describe "#versions_for" do
      before(:each) do
        @client = double(XMLRPC::Client)
        described_class.should_receive(:client).and_return(@client)
      end

      it "uses xmlrpc client to retreive versions" do
        expected = ['listTagged', described_class.koji_tag, nil, false,
                    nil, false, "rubygem-rails"]
        @client.should_receive(:call).with(*expected).and_return([])
        described_class.versions_for 'rails'
      end

      it "returns versions" do
        versions = [{'version' => '1.0.0'}]
        @client.should_receive(:call).and_return(versions)
        described_class.versions_for('rails').should == ['1.0.0']
      end

      it "invokes block with versions" do
        versions = [{'version' => '1.0.0'}]
        @client.should_receive(:call).and_return(versions)

        cb = proc {}
        cb.should_receive(:call).with(:koji, 'rails', ['1.0.0'])
        described_class.versions_for('rails', &cb)
      end
    end
  end # describe Koji
end # module Polisher
