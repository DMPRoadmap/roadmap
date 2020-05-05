module UniqueRandom

    def unique_random(field_name:, prefix: '', suffix:'', length: nil)
      return loop do
        rand = SecureRandom.urlsafe_base64(length, false)
        constructed = "#{prefix}#{rand}#{suffix}"
        break constructed unless self.exists?(field_name.to_sym => constructed)
      end
    end

end
