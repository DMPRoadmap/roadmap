module UniqueRandom

    def unique_random(field_name:, prefix: '', suffix:'', length: nil)
      return loop do
        rand = SecureRandom.urlsafe_base64(length, false)
        constructed = "#{prefix}#{rand}#{suffix}"
        break constructed unless self.exists?(field_name.to_sym => constructed)
      end
    end

    def unique_uuid(field_name:)
      return loop do
        uuid = SecureRandom.uuid
        break uuid unless self.exists?(field_name.to_sym => uuid)
      end
    end

end
