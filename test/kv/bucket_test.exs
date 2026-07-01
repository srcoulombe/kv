defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  describe "KV.Bucket" do
    test "stores key:value pairs" do
      {:ok, bucket} = KV.Bucket.start_link([])
      assert KV.Bucket.get(bucket, "milk") == nil

      KV.Bucket.put(bucket, "milk", 3)
      assert KV.Bucket.get(bucket, "milk") == 3
    end

    test "stores key:value pairs on a named process" do
      {:ok, _} = KV.Bucket.start_link(name: :shopping_list)
      assert KV.Bucket.get(:shopping_list, "milk") == nil

      KV.Bucket.put(:shopping_list, "milk", 3)
      assert KV.Bucket.get(:shopping_list, "milk") == 3
    end

    test "deletes key:value pair" do
      {:ok, bucket} = KV.Bucket.start_link([])
      KV.Bucket.put(bucket, "milk", 3)
      assert KV.Bucket.get(bucket, "milk") == 3

      KV.Bucket.delete(bucket, "milk")
      assert KV.Bucket.get(bucket, "milk") == nil
    end   
  end
end
