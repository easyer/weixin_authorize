# encoding: utf-8
module WeixinAuthorize
  module Token
    class RedisStore < Store

      def valid?

        Rails.logger.info("删除缓存")

       weixin_redis.del(client.redis_key)
       super
      end

      def token_expired?
        client.access_token = weixin_redis.hget(client.redis_key, "access_token")
        client.expired_at   = weixin_redis.hget(client.redis_key, "expired_at")
        Rails.logger.info("client.access_token==#{client.access_token}")
        Rails.logger.info("client.expired_at==#{client.expired_at}")
        Rails.logger.info("client.redis_key==#{client.redis_key}")
        Rails.logger.info("weixin_redis.hvals==#{weixin_redis.hvals(client.redis_key)}")
        Rails.logger.info("statu==#{weixin_redis.hvals(client.redis_key).empty?}")

        weixin_redis.hvals(client.redis_key).empty?
      end

      def refresh_token
        super
        Rails.logger.info("设置缓存access_token")
        weixin_redis.hmset(
          client.redis_key, "access_token",
          client.access_token, "expired_at",
          client.expired_at
        )
        weixin_redis.expireat(client.redis_key, client.expired_at.to_i)
        Rails.logger.info("client.access_token==#{client.access_token}")
        Rails.logger.info("client.expired_at==#{client.expired_at}")
        Rails.logger.info("weixin_redis==#{weixin_redis}")
      end

      def access_token
        super
        Rails.logger.info("获取缓存access_token")

        client.access_token = weixin_redis.hget(client.redis_key, "access_token")
        client.expired_at   = weixin_redis.hget(client.redis_key, "expired_at")

        Rails.logger.info("client.access_token==#{client.access_token}")
        Rails.logger.info("client.expired_at==#{client.expired_at}")

        client.access_token
      end

      def weixin_redis
        WeixinAuthorize.weixin_redis
      end
    end
  end

end
