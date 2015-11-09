#!/usr/bin/env ruby

class Factory

  include Enumerable

  def self.new(*args, &block)

    args.first.class == String and args.first[0] == args.first[0].capitalize ? name = args.shift : args.shift

    new_class = Class.new do

      args.each { |value| attr_accessor value.to_sym }

      define_method :inspect do
        string = "#{super()}".gsub(/^#<(.+)::(.+):.*? (.+)>$/){ "#<factory #{$1}::#{$2} #{$3}>" }
        string = string.gsub(/^#<(\w+)?:[^:]+? (.+)>$/){ "#<factory #{$1} #{$2}>" }
        string.gsub(/@/){ "" }
      end

      alias :to_s :inspect

      define_method :== do |object|
        return false unless self.class == object.class and self.hash == object.hash
        return true
      end

      alias :eql? :==

      define_method :hash do
        hash_variables.hash
      end

      define_method :[] do |value|
        if value.class == Fixnum
          raise "IndexError" unless 0 <= value and value <= self.instance_variables.size - 1
          return self.instance_variable_get( self.instance_variables[value] )
        else
          raise "NameError" unless self.instance_variables.include?( "@#{value.to_s}".to_sym )
          self.instance_variable_get( "@#{value.to_s}".to_sym )
        end
      end

      define_method :[]= do |value|
        if value.class == Fixnum
          raise "IndexError" unless 0 <= value and value <= self.instance_variables.size - 1
          return self.instance_variable_set( self.instance_variables[value] )
        else
          raise "NameError" unless self.instance_variables.include?( "@#{value.to_s}".to_sym )
          self.instance_variable_set( "@#{value.to_s}".to_sym )
        end
      end

      define_method :each do |&block|
        values.each( &block )
      end

      define_method :each_pair do |&block|
        hash_variables.each( &block )
      end

      define_method :length do
        values.size
      end

      alias :size :length

      define_method :length do |&block|
        values.select( &block )
      end

      define_method :to_a do
        self.instance_variables.map { |value| instance_variable_get( value ) }
      end

      alias_method :values,  :to_a

      define_method :values_at do |*values|
        values.values_at( *values )
      end

      define_method :members do
        self.instance_variables.map { |value| value.to_s.gsub(/@/){""} }
      end

      self.module_eval( &block ) if block_given?

      private

      define_method :initialize do |*attr|
        args.each_with_index do |value, index|
          self.instance_variable_set("@#{value}", attr[index])
        end
      end

      define_method :hash_variables do
        hash = {}
        self.instance_variables.each do |value|
          hash[value] = self.instance_variable_get(value)
        end
        hash
      end

    end

    name ? const_set(name, new_class) : new_class

  end

end