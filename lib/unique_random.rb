# frozen_string_literal: true

<<<<<<< HEAD
module UniqueRandom

  def unique_random(field_name:, prefix: "", suffix: "", length: nil)
=======
# Helper method for generating a unique value and checking the DB
module UniqueRandom
  def unique_random(field_name:, prefix: '', suffix: '', length: nil)
>>>>>>> upstream/master
    loop do
      rand = SecureRandom.urlsafe_base64(length, false)
      constructed = "#{prefix}#{rand}#{suffix}"
      break constructed unless exists?(field_name.to_sym => constructed)
    end
  end

  def unique_uuid(field_name:)
    loop do
      uuid = SecureRandom.uuid
      break uuid unless exists?(field_name.to_sym => uuid)
    end
  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
