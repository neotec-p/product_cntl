module ActionView
  module Helpers
    module FormHelper
      def label_with_translation(object_name, method, text = nil, options = {})
        if text.nil?
          text = I18n.t(method,              :default => method, :scope => [:activerecord, :attributes, object_name])
          text = I18n.t(method,              :default => method, :scope => [:activerecord, :attributes, "commons"])   if text.include?("translation missing:")
          text = I18n.t(method.to_s + "_id", :default => method, :scope => [:activerecord, :attributes, object_name]) if text.include?("translation missing:")
        end
        label_without_translation(object_name, method, text, options)
      end
      #alias_method_chain :label, :translation  #:nodoc:
      alias_method :label_without_translation, :label
      alias_method :label, :label_with_translation
    end

    module DateHelper
      def date_select_without_options(object_name, method, options = {}, html_options = {})
      end

      def date_select_with_options(object_name, method, options = {}, html_options = {})
        begin
          object = options[:object]
          value = object.send(method)
          value = I18n.l(value)
        rescue
          value = nil
        end
        value = "" if value.blank?
        
        html_class = 'ymd'
        html_class = options[:class] unless options[:class].blank?
        
        options.merge!(:class     => html_class,
                       :size      => 14,
                       :maxlength => 10,
                       :readonly  => true,
                       :value     => value)
        text_field(object_name, method, options)
      end
      #alias_method_chain :date_select, :options  #:nodoc:
      alias_method :date_select_without_options, :date_select
      alias_method :date_select, :date_select_with_options
    end

    module ActiveRecordHelper
      def error_messages_for(*params)
        options = params.extract_options!.symbolize_keys

        if object = options.delete(:object)
          objects = Array.wrap(object)
        else
          objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
        end
        
        errors = Array.new
        for record in objects
          unless record.errors.empty?
            record.errors.each_full { |msg| errors.push(msg) }
          end
        end
        errors = errors.uniq
        
        unless errors.empty?
          html = {}
          [:id, :class].each do |key|
            if options.include?(key)
              value = options[key]
              html[key] = value unless value.blank?
            else
              html[key] = 'errorExplanation'
            end
          end
    
          options = options.symbolize_keys
    
          I18n.with_options :locale => options[:locale], :scope => [:activerecord, :errors, :template] do |locale|
            header_message = locale.t :header, :count => errors.size
            message = locale.t(:body)
            error_messages = errors.collect {|msg| content_tag(:li, ERB::Util.html_escape(msg)) }.join.html_safe
            
            contents = ''
            contents << content_tag(options[:header_tag] || :h2, header_message) unless header_message.blank?
            contents << content_tag(:p, message) unless message.blank?
            contents << content_tag(:ul, error_messages)
    
            content_tag(:div, contents.html_safe, html)
          end
        end
      end
    end
    
  end
end
