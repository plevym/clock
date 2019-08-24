# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all
Role.destroy_all
Permission.destroy_all
TimeCheck.destroy_all

admin = User.create!(name: 'admin_user', email: 'admin@asd.com', username: 'admin_user', password: 'abfabf123', password_confirmation: 'abfabf123')
user  = User.create!(name: 'normal_user', email: 'user@asd.com', username: 'normal_user', password: 'abfabf123', password_confirmation: 'abfabf123')

admin_role = Role.create!(name: 'admin')
user_role  = Role.create!(name: 'user')

admin.roles << admin_role
user.roles << user_role

PERMISSIONS.each do |permission|
  admin_role.permissions << Permission.create!(id: permission[1], name: permission[0])
end

user_permission_names = %w[READ_USER CHECK_TIME CREATE_REPORT]

user_permission_names.each do |permission_name|
  user_role.permissions << Permission.find_by(name: permission_name)
end

admin_role.permissions << Permission.all
