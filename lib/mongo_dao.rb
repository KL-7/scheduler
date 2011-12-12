require 'active_support/inflector'

class MongoDAO

  def initialize(db, models_module = nil)
    @db = db
    @models_module = models_module
  end

  def find(coll, *args)
    objectify(coll, @db[coll].find_one(*args))
  end

  def find_by_id(coll, ids)
    if ids.is_a? Array
      all(coll, _id: { '$in' => ids.uniq.map{ |id| BSON::ObjectId(id) if BSON::ObjectId.legal?(id) }.compact })
    else
      find(coll, _id: BSON::ObjectId(ids)) if BSON::ObjectId.legal?(ids)
    end
  end

  def all(coll, *args)
    objectify(coll, @db[coll].find(*args).to_a || [])
  end

  def insert(coll, *args)
    @db[coll].insert(Array(args).map { |obj| obj.to_mongo_hash })
  end

  def update(coll, doc)
    hash = doc.to_mongo_hash
    @db[coll].update({ _id: hash[:_id] }, hash)
  end

  def delete(coll, id)
    @db[coll].remove({ _id: BSON::ObjectId(id) }) if BSON::ObjectId.legal?(id)
  end

  def load_one_to_one_association(records, association_name)
    records.tap do |children|
      children = Array(children)
      parent_coll = association_name.to_s.pluralize.to_sym
      association_id = "#{association_name}_id"

      ids = children.map { |c| c.send(association_id) }

      parents_map = find_by_id(parent_coll, ids).each_with_object({}) { |p, memo| memo[p.id] = p }
      children.each { |c| c.send "#{association_name}=", parents_map[c.send(association_id)] }
    end
  end

  protected

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
