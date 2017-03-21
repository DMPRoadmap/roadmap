class FileUpload < ActiveRecord::Base
  #attr_accessible :file_type_id, :description, :location, :name, :published, :size, :title

  #associations between tables
  belongs_to :file_type
   
end
