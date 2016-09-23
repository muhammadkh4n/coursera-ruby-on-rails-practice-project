class Racer
  include ActiveModel::Model

  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

  def initialize(params = {})
    @id = params[:_id].nil? ? params[:id] : params[:_id].to_s
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i
  end

  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    self.mongo_client[:racers]
  end

  def self.all(prototype = {}, sort = {}, skip = 0, limit = nil)
    res = self.collection.find(prototype).sort(sort).skip(skip)
    return res if limit.nil?
    return res.limit(limit)
  end

  def self.paginate(params)
    page = (params[:page] ||= 1).to_i
    limit = (params[:per_page] ||= 30).to_i
    skip = (page - 1) * limit
    racers = []
    all({}, {number: 1}, skip, limit).each do |racer|
      racers << Racer.new(racer)
    end
    total = collection.count

    WillPaginate::Collection.create(page, limit, total) do |pager|
      pager.replace(racers)
    end
  end

  def self.find(id)
    id = BSON::ObjectId.from_string(id)
    res = collection.find(_id: id).first
    return res.nil? ? nil : Racer.new(res)
  end

  def save
    res = self.class.collection
        .insert_one(number: @number, first_name: @first_name, last_name: @last_name, group: @group, gender: @gender, secs: @secs)
    @id = res.inserted_id
  end

  def update(params)
    id = BSON::ObjectId.from_string(@id)
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i

    params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
    res = self.class.collection.find(:_id => id).replace_one(params)
  end

  def destroy
    self.class.collection.find(number: @number).delete_one
  end

  def persisted?
    !@id.nil?
  end

  def created_at
    nil
  end

  def updated_at
    nil
  end
end