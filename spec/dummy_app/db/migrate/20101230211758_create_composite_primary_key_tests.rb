class CreateCompositePrimaryKeyTests < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE composite_primary_key_tests (
        pk1 INT(11) NOT NULL,
        pk2 VARCHAR(200) NOT NULL,
        pk3 DATE NOT NULL,
        description VARCHAR(250),
        PRIMARY KEY (pk1, pk2, pk3)
      )
    SQL
  end

  def self.down
    drop_table :composite_primary_key_tests
  end
end