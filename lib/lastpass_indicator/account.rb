
module LastPassIndicator
  class Account < Struct.new(:id, :name, :username)
    def to_s
      self.class.account_name(self)
    end

    def self.account_name(account)
      return account.name if account.username.nil? || account.username.empty?
      "#{account.name} (#{account.username})"
    end

    def self.from_hash(hash)
      new(hash[:id], hash[:name], hash[:username])
    end

    def self.from_vault(account)
      new(account.id, account.name, account.username)
    end
  end
end
