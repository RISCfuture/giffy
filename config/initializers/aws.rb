credentials = Aws::SharedCredentials.new rescue nil
unless credentials&.loadable?
  credentials = Aws::Credentials.new(Giffy::Configuration.aws.access_key_id,
                                     Giffy::Configuration.aws.secret_access_key)
end

Aws.config.update region:      Giffy::Configuration.aws.region,
                  credentials: credentials

S3 = Aws::S3::Client.new
