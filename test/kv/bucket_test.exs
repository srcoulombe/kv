defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  describe "KV.Bucket" do
    test "stores key:value pairs" do
      {:ok, bucket} = start_supervised(KV.Bucket)
      assert is_nil(KV.Bucket.get(bucket, "milk"))

      KV.Bucket.put(bucket, "milk", 3)
      assert KV.Bucket.get(bucket, "milk") == 3
    end

    test "stores key:value pairs on a named process", config do
      {:ok, _} = start_supervised({KV.Bucket, name: config.test})
      assert is_nil(KV.Bucket.get(config.test, "milk"))

      KV.Bucket.put(config.test, "milk", 3)
      assert KV.Bucket.get(config.test, "milk") == 3
    end

    test "deletes key:value pair" do
      {:ok, bucket} = start_supervised(KV.Bucket)
      KV.Bucket.put(bucket, "milk", 3)
      assert KV.Bucket.get(bucket, "milk") == 3

      KV.Bucket.delete(bucket, "milk")
      assert KV.Bucket.get(bucket, "milk") == nil
    end

    test "subscribes to puts and deletes" do
      {:ok, bucket} = start_supervised(KV.Bucket)
      KV.Bucket.subscribe(bucket)

      KV.Bucket.put(bucket, "milk", 3)
      assert_receive {:put, "milk", 3}

      # Also check it works even from another process
      spawn(fn -> KV.Bucket.delete(bucket, "milk") end)
      assert_receive {:delete, "milk"}
    end
  end
end
