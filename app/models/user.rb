class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  attr_accessor :login
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,  :authentication_keys => [:login]
  validates :username,  :uniqueness => { :case_sensitive => false }
  validates :first_name, :presence => true
        
  has_many :events, dependent: :destroy
  
  ROLES = [ENV["ROLE_ADMIN"], ENV["ROLE_USER"]]
  
  before_create :user_role
  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

 def self.find_for_database_authentication(warden_conditions)
  conditions = warden_conditions.dup
  if login = conditions.delete(:login)
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  else
    where(conditions).first
  end
end

  def user_role
    self.role = ENV["ROLE_USER"] if self.role.blank?
  end
end
