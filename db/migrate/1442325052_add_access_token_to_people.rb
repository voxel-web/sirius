Sequel.migration do
  up do
    self << 'CREATE EXTENSION IF NOT EXISTS pgcrypto'
    alter_table(:people) do
      add_column :access_token, :uuid, default: Sequel.function(:gen_random_uuid), index: true
    end
    self << <<-eos
      UPDATE people
      SET access_token = tokens.uuid
      FROM tokens
      WHERE people.id = tokens.username
    eos
  end

  down do
    drop_column :people, :access_token
    self << 'DROP EXTENSION IF EXISTS pgcrypto'
  end
end
