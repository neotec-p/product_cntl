module ActiveSupport
  module CoreExtensions
    module Array
      module Conversions

        def to_csv(instance, options = {})
          require 'csv'
          require 'kconv'

          o_keys  = []
          o_names = []
          o_types = []
          instance.columns.each{|column|
            o_keys  << column.name
            name = I18n.t(column.name, :scope => [:activerecord, :attributes, instance.table_name.singularize])   #ApplicationController.helpers.hlabel(:order, column.name)
            name = I18n.t(column.name, :scope => [:activerecord, :attributes, :commons]) if name.index("translation missing") && name.index("translation missing").to_i >= 0
            name = column.name if name.index("translation missing") && name.index("translation missing").to_i >= 0
            o_names << name
            o_types << column.type
          }

          CSV::Writer.generate(output = ""){|csv|
            each_with_index{|all, i|
              if i == 0
                names = o_names unless o_names.blank?
                names = o_keys  if names.blank? and !o_keys.blank?
                names = all.attribute_names if names.blank?
#                csv << names
                a0 = []
                names.each{|name|
                  begin
                    s = Kconv.tosjis(name)
                  rescue
                  end
                  a0 << '"' + s + '"'
                }
                csv << a0
              end

              keys = o_keys unless o_keys.blank?
              keys = all.attribute_names if keys.blank?

              a1 = []
              keys.each_with_index{|key,j|
                begin
                  s = all.read_attribute(key)
                  s = s.gsub(/\r\n|\r|\n/, " ")
                  s = Kconv.tosjis(s)
                  s = '"' + s + '"' unless o_types[j] == ":integer"
                rescue
                end
                a1 << s
              }
              csv << a1
            }
          }
          output
        end

      end
    end
  end
end



