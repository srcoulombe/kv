defmodule KVTest do
  use ExUnit.Case

  describe "create_bucket/1" do
    test "creates new buckets" do
      name = "a unique name that won't be shared"
      existing_process = KV.lookup_bucket(name)
      assert is_nil(existing_process)

      assert {:ok, bucket} = KV.create_bucket(name)
      assert bucket == KV.lookup_bucket(name)
    end

    test "does not create buckets that already exist" do
      name = "already exists"
      {:ok, bucket} = KV.create_bucket(name)

      assert {:error, {:already_started, bucket}} == KV.create_bucket(name)
    end
  end

  describe "lookup_bucket/1" do
    test "returns the bucket when it exists" do
      name = "exists"
      {:ok, bucket} = KV.create_bucket(name)
 
      assert bucket == KV.lookup_bucket(name)
    end

    test "returns nil when the specified bucket doesn't exist" do
      assert is_nil(KV.lookup_bucket("doesn't exist"))
    end
  end
end
