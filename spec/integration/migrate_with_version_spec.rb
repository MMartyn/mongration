require 'spec_helper'

describe 'Mongration.migrate(version)' do

  context 'when the given version is above the current version' do
    it 'migrates up to the given version' do
      foo_create_migration
      bar_create_migration
      Mongration.migrate('001')

      expect(Foo.count).to eq(1)
      expect(Bar.count).to eq(0)
    end
  end

  context 'when the given version is below the current version' do
    it 'migrates down to the given version' do
      foo_create_migration
      bar_create_migration
      Mongration.migrate

      Mongration.migrate('001')

      expect(Foo.count).to eq(1)
      expect(Bar.count).to eq(0)
    end
  end

  context 'when the version does not exist' do
    it 'returns false' do
      foo_create_migration
      bar_create_migration

      expect(Mongration.migrate('003')).to eq(false)
    end
  end
end