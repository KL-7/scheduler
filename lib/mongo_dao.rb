require 'active_support/inflector'

class MongoDAO

  def initialize(db, models_module = nil)
    @db = db
    @models_module = models_module
  end

  def find(coll, *args)
    objectify(coll, @db[coll].find_one(*args))
  end

  def find_by_id(coll, id)
    find(coll, _id: BSON::ObjectId(id)) if BSON::ObjectId.legal?(id)
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
