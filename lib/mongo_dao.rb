require 'active_support/inflector'

class MongoDAO

  def initialize(db, models_module = nil)
    @db = db
    @models_module = models_module
  end

  def find(coll, spec_or_object_id = nil, opts = {})
    with_associations(opts.delete(:include)) do
      objectify(coll, @db[coll].find_one(spec_or_object_id, opts))
    end
  end

  def find_by_id(coll, ids, opts = {})
    with_associations(opts.delete(:include)) do
      if ids.is_a? Array
        all(coll, _id: { '$in' => ids.uniq.map{ |id| BSON::ObjectId(id) if BSON::ObjectId.legal?(id) }.compact })
      else
        find(coll, _id: BSON::ObjectId(ids)) if BSON::ObjectId.legal?(ids)
      end
    end
  end

  def all(coll, selector = {}, opts = {})
    with_associations(opts.delete(:include)) do
      objectify(coll, @db[coll].find(selector, opts).to_a || [])
    end
  end

  def insert(coll, *args)
    @db[coll].insert(Array(args).map { |obj| obj.to_mongo_hash })
  end

  def update(coll, doc)
    hash = doc.to_mongo_hash
    @db[coll].update({ _id: hash[:_id] }, hash)
  end

  def save(coll, doc)
    doc.id.nil? ? insert(coll, doc) : update(coll, doc)
  end

  def delete_by_id(coll, id)
    @db[coll].remove({ _id: BSON::ObjectId(id) }) if BSON::ObjectId.legal?(id)
  end

  def delete(coll, *args)
    @db[coll].remove(*args)
  end

  def collection(name)
    @db[name]
  end

  def load_associations(records, associations)
    case associations
    when Array
      associations.each { |assoc| load_one_to_one_association records, assoc }
    when Hash
      associations.each { |assoc, coll| load_one_to_one_association records, assoc, coll }
    when Symbol, String
      load_one_to_one_association records, associations.to_sym
    else
      raise ArgumentError, "associations argument should be an array, a hash, a string, or a symbol"
    end

    records
  end

  protected

  def load_one_to_one_association(records, assoc_name, assoc_collection = nil)
    records.tap do |children|
      children = Array(children)
      parent_coll = assoc_collection || assoc_name.to_s.pluralize.to_sym
      assoc_id = "#{assoc_name}_id"

      ids = children.map { |c| c.send(assoc_id) }

      parents_map = find_by_id(parent_coll, ids).each_with_object({}) { |p, memo| memo[p.id] = p }
      children.each { |c| c.send "#{assoc_name}=", parents_map[c.send(assoc_id)] }
    end
  end

  def with_associations(associations)
    if associations
      yield.tap do |result|
        load_associations result, associations
      end
    else
      yield
    end
  end

  def collection_class(coll)
    return unless coll

    if @models_module
      @models_module.const_get(coll.to_s.singularize.capitalize)
    else
      coll.to_s.singularize.capitalize.constantize
    end
  end

  def objectify(coll, result)
    return unless result && (klass = collection_class(coll))

    if result.is_a?(Array)
      result.map { |h| klass.from_mongo_hash(h) }
    else
      klass.from_mongo_hash(result)
    end
  end

end
