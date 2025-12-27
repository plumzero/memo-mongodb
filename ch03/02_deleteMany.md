
[参考](https://docs.mongodb.com/manual/reference/method/db.collection.deleteMany/)

```js
db.collection.deleteMany(
   <filter>,
   {
      writeConcern: <document>,
      collation: <document>
   }
)
```
`filter` 指定了删除规则。如果要删除集合中的所有文档，可以设置为 `{}`。
 
### 行为特征

##### 固定集合

如果对固定集合使用 `db.collection.deleteMany()`，会抛出 `WriteError` 异常。为了删除这种集合上的所有文档，使用 `db.collection.drop()` 。

##### 时间序列集合

如果对时间序列集合使用 `db.collection.deleteMany()`，会抛出 `WriteError` 异常。为了删除这种集合上的所有文档，使用 `db.collection.drop()` 。

##### 删除单个文档

要删除单个文档，应该使用 `db.collection.deleteOne()`。或者使用一个带有唯一索引的字段域，如 _id 。


### 示例

一个 orders 集合:
```js
db.orders.insertOne(
    {
        _id: ObjectId("563237a41a4d68582c2509da"),
        stock: "Brent Crude Futures",
        qty: 250,
        type: "buy-limit",
        limit: 48.90,
        creationts: ISODate("2015-11-01T12:30:15Z"),
        expiryts: ISODate("2015-11-01T12:35:15Z"),
        client: "Crude Traders Inc."
    }
)
```

删除 `client : "Crude Traders Inc."` 内容的文档:
```js
    db.orders.deleteMany( { "client" : "Crude Traders Inc." } );
```

删除内容为 `stock : "Brent Crude Futures"` 并且 limit 大于 48.88 的文档:
```js
    db.orders.deleteMany( { "stock" : "Brent Crude Futures", "limit" : { $gt : 48.88 } } );
```

### 删除操作中指定 hint

测试集合:
```js
db.members.insertMany([
   { "_id" : 1, "member" : "abc123", "status" : "P", "points" :  0,  "misc1" : null, "misc2" : null },
   { "_id" : 2, "member" : "xyz123", "status" : "A", "points" : 60,  "misc1" : "reminder: ping me at 100pts", "misc2" : "Some random comment" },
   { "_id" : 3, "member" : "lmn123", "status" : "P", "points" :  0,  "misc1" : null, "misc2" : null },
   { "_id" : 4, "member" : "pqr123", "status" : "D", "points" : 20,  "misc1" : "Deactivated", "misc2" : null },
   { "_id" : 5, "member" : "ijk123", "status" : "P", "points" :  0,  "misc1" : null, "misc2" : null },
   { "_id" : 6, "member" : "cde123", "status" : "A", "points" : 86,  "misc1" : "reminder: ping me at 100pts", "misc2" : "Some random comment" }
])
```

为测试集合创建索引:
```js
db.members.createIndex( { status: 1 } )
db.members.createIndex( { points: 1 } )
```

在删除操作操作中使用 `{status: i}` 进行显性提示:
```js
db.members.deleteMany(
   { "points": { $lte: 20 }, "status": "P" },
   { hint: { status: 1 } }
)
```
感觉也没什么区别~
