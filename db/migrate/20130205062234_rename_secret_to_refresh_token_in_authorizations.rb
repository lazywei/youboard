class RenameSecretToRefreshTokenInAuthorizations < ActiveRecord::Migration
  def up
    rename_column :authorizations, :secret, :refresh_token
  end

  def down
    rename_column :authorizations, :refresh_token, :secret
  end
end
