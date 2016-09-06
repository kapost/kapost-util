# frozen_string_literal: true

module KapostUtil
  # Gem identity information.
  module Identity
    def self.name
      "kapost-util"
    end

    def self.label
      "KapostUtil"
    end

    def self.version
      "0.1.0"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
