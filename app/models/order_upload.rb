class OrderUpload
  require 'kconv'

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

  def import(orders)
    result = true
    
    self.to_a.each_with_index{|row,i|
      if i > 0
        order = Order.new
        order.id = i
        
        row.each_with_index{|data,j|
          data = Kconv.toutf8(data.to_s)
          case j
          when 0
            codes = data.split("-")
            order.item_customer_code = codes[0]
            order.item_code = codes[1]
          when 2
            order.order_no = data
            # order.delivery_ymd = conv_date(data)
          when 3
            order.order_amount = data.to_i unless data.blank?
          when 9
            order.delivery_ymd = conv_date(data)
          when 10
            order.order_ymd = conv_date(data)
          else
            #do nothing
          end
        }
        #order.valid?
        
        orders << order unless order.delivery_ymd.nil?
      end
    }
    
    return result
  end

  private 
  
  def conv_date(date, params = nil)
    begin
      val = Date.strptime(date, "%y/%m/%d")
    rescue
      begin
        val = Date.strptime(date, "%Y/%m/%d")
      rescue
        val = nil
      end
    end
    
    return val
  end

end
