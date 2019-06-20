class CalendarUpload

  attr_accessor :filename
  attr_accessor :content_type
  attr_accessor :size
  attr_accessor :data
  def initialize(file)
    unless file.blank?
      begin
        @filename = file.original_filename.gsub(/[^\w!\#$%&()=^~|@`\[\]\{\};+,.-]/u, '')
        @content_type = file.content_type.gsub(/[^\w.+;=_\/-]/n, '')
        @size = file.size
        @data = file.read
      rescue
      end
    end
  end

  def to_a
    require 'csv'

    arrs = []
    return arrs if @size.blank?

    CSV.parse(@data){|line|
      row = []
      line.each_with_index{|col,j|
        row << col
      }
      arrs << row
    }
    return arrs
  end

  def import(calendars)
    result = true

    self.to_a.each_with_index{|row,i|
      if i > 0
        year = nil
        month = nil
        day = nil
        holiday = nil

        row.each_with_index{|data,j|
          #data = Kconv.toutf8(data.to_s)
          data = data.to_s

          case j
          when 0
            year = data
          when 1
            month = data
          when 2
            day = data
          when 3
            holiday = data
          else
          #do nothing
          end
        }

        calendar = Calendar.find_by_ymd(year, month, day)
        calendar ||= Calendar.new(:year => year, :month => month, :day => day)

        calendar.holiday = holiday
        
        result = calendar.valid?
        
        calendars << calendar

      end
    }
    
#    upload_msga  = []
    
#    ActiveRecord::Base::transaction do
#      calendars.each {|calendar|
#       if calendar.invalid?
#          error_msgs << calendar.errors.full_messages.to_s
=begin
          object_name = ""
          begin
            object_name = calendar.disp_text
          rescue
            object_name = "error"
          end
          upload_msga << object_name + (id == 0 ? "を追加" : "を更新")
=end
#        else
#          calendar.save!
#        end
#      }
#    end
    
    return result
  end

end
