
MongoDB 支持聚合查询，但多集合聚合查询性能消耗很大，时间很长，需要建立索引。

MongoDB 为了提高并发性对锁进行了细化，但并没有像一些 SQL 型数据库一样提供更改某种操作的锁级别/锁模式的语句。MDB 将锁进行分类，开发者应该根据此分类将自己的数据模型向更快的锁级别/锁模式方向靠拢设计。

- [并发性](https://docs.mongoing.com/faq/concurrency)
- [数据模型设计](https://docs.mongodb.com/manual/core/data-model-design/#data-modeling-embedding)

在多联查键情况下，SQL 比 Mongo 要简单。

在多分组情况下，Mongo 比 SQL 要简单一些，但是思路还是 SQL 的思路。