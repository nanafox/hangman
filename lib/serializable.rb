# frozen_string_literal: true

require 'msgpack'

# Serializer for saving and deserializing Hangman game objects
module Serializable
  def serialize
    MessagePack.dump(
      instance_variables.map do |var|
        [var, instance_variable_get(var)]
      end.to_h
    )
  end

  def deserialize(string)
    MessagePack.unpack(string).each do |var, value|
      instance_variable_set(var, value)
    end
  end
end
