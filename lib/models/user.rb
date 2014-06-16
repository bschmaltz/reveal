class User
  attr_accessor :id, :username, :auth_token
  def initialize(args)
    @id = args['id']
    @username = args['username']
    @auth_token = args['auth_token']
    p "MADE USER #{self.inspect}"
  end
end