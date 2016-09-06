# frozen_string_literal: true

require "spec_helper"

require "active_support/core_ext/class/attribute"

require "kapost/env"

RSpec.describe Kapost::Env do
  let(:env) { {"KAPOST_ENV_TEST_KEY" => "SOME VALUE"} }

  subject(:kapost_env) { Kapost::Env.new(env, app_env: app_env) }

  shared_examples_for "normal #fetch semantics" do |opts|
    it "should fetch values from the ENV" do
      expect(kapost_env.fetch("KAPOST_ENV_TEST_KEY")).to eq "SOME VALUE"
    end

    unless opts && opts[:normal_default_behavior] == false
      it "should use the default for missing ENV var" do
        expect(kapost_env.fetch("missing_key") { "default" }).to eq "default"
      end
    end

    it "should raise a KeyError for missing ENV var with no default" do
      expect { kapost_env.fetch("missing_key") }.to raise_error Kapost::Env::KeyError
    end
  end

  context "when application environment is \"development\"" do
    let(:app_env) { "development" }

    describe "#fetch" do
      it_behaves_like "normal #fetch semantics"
    end

    describe "#fetch!" do
      it_behaves_like "normal #fetch semantics"
    end
  end

  context "when application environment is \"production\"" do
    let(:app_env) { "production" }

    describe "#fetch" do
      it_behaves_like "normal #fetch semantics"
    end

    describe "#fetch!" do
      it_behaves_like "normal #fetch semantics", normal_default_behavior: false

      it "should NOT use the default for missing ENV var" do
        expect { kapost_env.fetch!("missing_key") }.to raise_error Kapost::Env::ProductionKeyError
      end
    end
  end

  describe Kapost::ENV do
    subject(:kapost_env) { Kapost::ENV }

    before { ENV["KAPOST_ENV_TEST_KEY"] = "SOME VALUE" }
    after  { ENV.delete("KAPOST_ENV_TEST_KEY") }

    context "in a Rails app" do
      before do
        class ::Rails
          class_attribute :env
        end
      end

      after do
        Object.send(:remove_const, :Rails)
      end

      context "when Rails.env is \"development\"" do
        before { Rails.env = "development" }

        describe "#fetch" do
          it_behaves_like "normal #fetch semantics"
        end

        describe "#fetch!" do
          it_behaves_like "normal #fetch semantics"
        end
      end

      context "when Rails.env is \"production\"" do
        before { Rails.env = "production" }

        describe "#fetch" do
          it_behaves_like "normal #fetch semantics"
        end

        describe "#fetch!" do
          it_behaves_like "normal #fetch semantics", normal_default_behavior: false

          it "should NOT use the default for missing ENV var" do
            expect { kapost_env.fetch!("missing_key") }.to raise_error Kapost::Env::ProductionKeyError
          end
        end
      end
    end

    context "in a Rack app" do
      context "when RACK_ENV is \"development\"" do
        before { ENV["RACK_ENV"] = "development" }

        describe "#fetch" do
          it_behaves_like "normal #fetch semantics"
        end

        describe "#fetch!" do
          it_behaves_like "normal #fetch semantics"
        end
      end

      context "when RACK_ENV is \"production\"" do
        before { ENV["RACK_ENV"] = "production" }

        describe "#fetch" do
          it_behaves_like "normal #fetch semantics"
        end

        describe "#fetch!" do
          it_behaves_like "normal #fetch semantics", normal_default_behavior: false

          it "should NOT use the default for missing ENV var" do
            expect { kapost_env.fetch!("missing_key") }.to raise_error Kapost::Env::ProductionKeyError
          end
        end
      end
    end
  end
end
