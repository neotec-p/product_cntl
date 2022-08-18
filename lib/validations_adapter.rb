module ValidationsAdapter
  @new_record = true
  def self.included(base)
    base.extend(ActiveRecord::Validations::ClassMethods)
    base.extend(ClassMethods)

    base.class_eval do
      include InstanceMethods
    end
  end

  module ClassMethods
    def human_name(options = {})
      defaults = self_and_descendants_from_active_record.map do |klass|
        klass.name.underscore.to_sym
      end

      defaults << self.name.humanize
      I18n.translate(defaults.shift, {:scope => [:activerecord, :models], :count => 1, :default => defaults}.merge(options))
    end

    def human_attribute_name(attribute_name)
      defaults = self_and_descendants_from_active_record.map do |klass|
        :"#{klass.name.underscore}.#{attribute_name}"
      end
      
      ActiveRecord::Base.human_attribute_name(attribute_name, :default => defaults)
    end

    def self_and_descendants_from_active_record#nodoc:
      [self]
    end
  end

  module InstanceMethods
    attr_accessor :id
    def initialize(params = {})
      return unless params

      params.each do |k,v|
        self.send("#{k}=", v)
      end
    end

    def new_record?
      @new_record
    end

    def valid?
      super
    end

    def invalid?
      super
    end

    def save
      save_method
    end

    def save!
      raise "override me." unless save_method
    end

    def self_and_descendants_from_active_record
    end

    def update_attribute; update_method
    end

  end
=begin
=end

end