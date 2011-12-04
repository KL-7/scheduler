module MongoFields

  RESERVED_FIELDS = [:id, :_id]

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def mongo_fields
      @mongo_fields ||= [:id]
    end

    def from_mongo_hash(attrs = {})
      new.tap do |model|
        model.id = attrs['_id'].to_s
        attrs.each do |k, v|
          if (mongo_fields - RESERVED_FIELDS).include?(k.to_sym)
            model.send("#{k}=", v)
          elsif k.to_sym == :_id
            model.id = v.to_s
          end
        end
      end
    end

    protected

    def fields(*new_fields)
      new_fields = Array(new_fields).map(&:to_sym)
      raise ArgumentError.new("Fields #{RESERVED_FIELDS * ', '} are reserved.") unless (new_fields & RESERVED_FIELDS).empty?

      duplicates = mongo_fields & new_fields
      raise ArgumentError.new("Fields #{duplicates * ', '} are already defined.") unless duplicates.empty?

      mongo_fields.concat new_fields
    end

  end

  def to_mongo_hash
    self.class.mongo_fields.inject({}){ |m, k| m.merge k => send(k) }.tap do |h|
      id = h.delete :id
      h.merge!(:_id => BSON::ObjectId(id)) if BSON::ObjectId.legal?(id)
    end
  end

  def fields
    @fields ||= {}
  end

  def method_missing(*args, &block)
    field_name, setter = args.first.to_s.match(/(\w+)(=)?/)[1..-1]
    field_name = field_name.to_sym

    if self.class.mongo_fields.include? field_name
      if setter
        fields[field_name] = args[1]
      else
        fields[field_name]
      end
    else
      super
    end
  end

end