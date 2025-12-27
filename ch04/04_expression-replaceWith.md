
参考: [$replaceWith (aggregation)](https://docs.mongodb.com/v4.4/reference/operator/aggregation/replaceWith/#mongodb-pipeline-pipe.-replaceWith)

自版本 4.2 引入。

说明: 这里说的文档即 document，简单的理解就是 json 格式数据(用 `{}` 包裹起来的)。

作用: `$replaceWith` 可以将内部嵌入式文档提升到最顶层(top-level)，也可以指定新的文档进行替换。

格式:
```json
    { $replaceWith: <replacementDocument> }
```

### 行为特征

如果 `<replacementDocument>` 不是一个文档，`$replaceWith` 将失败。

将如下测试数据插入库中:
```sh
    db.collection.insertMany([
       { "_id": 1, "name" : { "first" : "John", "last" : "Backus" } },
       { "_id": 2, "name" : { "first" : "John", "last" : "McCarthy" } },
       { "_id": 3, "name": { "first" : "Grace", "last" : "Hopper" } },
       { "_id": 4, "firstname": "Ole-Johan", "lastname" : "Dahl" },
    ])
```

执行如下命令会报错，原因是 "_id" 为 4 的那条记录并没有名字为 "name" 的文档。
```sh
    db.collection.aggregate([
       { $replaceWith: "$name" }
    ])
```

为了避免因为这个原因而产生的错误，你可以使用 `$mergeObjects` 引入一个文档作为 "name" 的默认文档。命令如下:
```sh
    db.collection.aggregate([
       { $replaceWith: { $mergeObjects: [ { _id: "$_id", first: "", last: "" }, "$name" ] } }
    ])
```
输出如下:
```json
    { "_id" : 1, "first" : "John", "last" : "Backus" }
    { "_id" : 2, "first" : "John", "last" : "McCarthy" }
    { "_id" : 3, "first" : "Grace", "last" : "Hopper" }
    { "_id" : 4, "first" : "", "last" : "" }
```

或者，你也可以使用 `$ifNull` 将 "name" 指定为其他文档:
```sh
    db.collection.aggregate([
       { $replaceWith: { $ifNull: [ "$name", { _id: "$_id", missingName: true} ] } }
    ])
```
输出如下:
```json
    { "first" : "John", "last" : "Backus" }
    { "first" : "John", "last" : "McCarthy" }
    { "first" : "Grace", "last" : "Hopper" }
    { "_id" : 4, "missingName" : true }
```

不过，上面的命令在遇到 "name" 字段存在，但却不为对象(比如字符串、数值或数组)时，仍会报错。

为此，可以针对 "name" 进行一些更合理的匹配(使用 `$match`)。

在进行新的测试之前，先添加一些更多样的数据:
```sh
    db.collection.insertMany([
        { "_id": 5, "name": "HuaAn" },
        { "_id": 6, "name": 9527 },
        { "_id": 7, "name": [ "TangYi", "Bohu" ] }
    ])
```

执行如下命令:
```sh
    db.collection.aggregate([
       { $match: { name : { $exists: true, $not: { $type: "array" }, $type: "object" } } },
       { $replaceWith: "$name" }
    ])
```
上面的命令只会输出存在 "name" 字段且类型为对象的记录，其他则跳过。
具体输出如下:
```json
    { "first" : "John", "last" : "Backus" }
    { "first" : "John", "last" : "McCarthy" }
    { "first" : "Grace", "last" : "Hopper" }
```

### 具体示例 - 创建缺省值

测试数据:
```sh
    db.people.insertMany([
       { "_id" : 1, "name" : "Arlene", "age" : 34, "pets" : { "dogs" : 2, "cats" : 1 } },
       { "_id" : 2, "name" : "Sam", "age" : 41, "pets" : { "cats" : 1, "fish" : 3 } },
       { "_id" : 3, "name" : "Maria", "age" : 25 }
    ])
```
"pets" 一共会有很多种，但是每个 "people" 可能仅有其中的几种，但在聚合时常常会列出所有的 "pets"，只是将不拥有的置为 0。这时就可以这样做:
```sh
    db.people.aggregate( [
       { $replaceWith: { $mergeObjects:  [ { dogs: 0, cats: 0, birds: 0, fish: 0 }, "$pets" ] } }
    ] )
```
输出如下:
```json
    { "dogs" : 2, "cats" : 1, "birds" : 0, "fish" : 0 }
    { "dogs" : 0, "cats" : 1, "birds" : 0, "fish" : 3 }
    { "dogs" : 0, "cats" : 0, "birds" : 0, "fish" : 0 }
```

### 具体示例 - 数组转对象

对于如下测试数据:
```sh
    db.students.insertMany([
       {
          "_id" : 1,
          "grades" : [
             { "test": 1, "grade" : 80, "mean" : 75, "std" : 6 },
             { "test": 2, "grade" : 85, "mean" : 90, "std" : 4 },
             { "test": 3, "grade" : 95, "mean" : 85, "std" : 6 }
          ]
       },
       {
          "_id" : 2,
          "grades" : [
             { "test": 1, "grade" : 90, "mean" : 75, "std" : 6 },
             { "test": 2, "grade" : 87, "mean" : 90, "std" : 3 },
             { "test": 3, "grade" : 91, "mean" : 85, "std" : 4 }
          ]
       }
    ])
```
现在假如要对 "grades" 进行 `$replaceWith` 操作，该怎么办呢?

在前面的测试中知道 `$replaceWith` 无法对数组进行操作，不过可以先尝试将数组转为对象，再进行 `$replaceWith`。

转对象可以通过 `$unwind` 实现:
```sh
    db.students.aggregate( [
       { $unwind: "$grades" },
       { $replaceWith: "$grades" }
    ] )
```
输出如下:
```json
    { "test" : 1, "grade" : 80, "mean" : 75, "std" : 6 }
    { "test" : 2, "grade" : 85, "mean" : 90, "std" : 4 }
    { "test" : 3, "grade" : 95, "mean" : 85, "std" : 6 }
    { "test" : 1, "grade" : 90, "mean" : 75, "std" : 6 }
    { "test" : 2, "grade" : 87, "mean" : 90, "std" : 3 }
    { "test" : 3, "grade" : 91, "mean" : 85, "std" : 4 }
```

在此基础上，还可以进行更多的操作，比如只想获取 "grade" 大于等于 90 的记录:
```sh
    db.students.aggregate( [
       { $unwind: "$grades" },
       { $match: { "grades.grade" : { $gte: 90 } } },
       { $replaceWith: "$grades" }
    ] )
```
执行后输出如下:
```json
    { "test" : 3, "grade" : 95, "mean" : 85, "std" : 6 }
    { "test" : 1, "grade" : 90, "mean" : 75, "std" : 6 }
    { "test" : 3, "grade" : 91, "mean" : 85, "std" : 4 }
```

### 具体示例 - 代以新字段

```sh
    db.sales.insertMany([
       { "_id" : 1, "item" : "butter", "price" : 10, "quantity": 2, date: ISODate("2019-03-01T08:00:00Z"), status: "C" },
       { "_id" : 2, "item" : "cream", "price" : 20, "quantity": 1, date: ISODate("2019-03-01T09:00:00Z"), status: "A" },
       { "_id" : 3, "item" : "jam", "price" : 5, "quantity": 10, date: ISODate("2019-03-15T09:00:00Z"), status: "C" },
       { "_id" : 4, "item" : "muffins", "price" : 5, "quantity": 10, date: ISODate("2019-03-15T09:00:00Z"), status: "C" }
    ])
```
如果想要为每行记录添加新的字段，或者将一些字段进行处理，怎么做呢?

```sh
    db.sales.aggregate([
       { $match: { status: "C" } },
       { $replaceWith: { _id: "$_id", item: "$item", amount: { $multiply: [ "$price", "$quantity"]}, status: "Complete", asofDate: "$$NOW" } }
    ])
```
上面的命令会筛选为 "status" 为 "C" 的记录。对于这些记录，会原样拷贝 "_id" 和 "item" 字段，同时对原数据中的 "price" 和 "quantity" 进行乘法，结果保存在 "amount" 字段中，之后添加两个新字段 "status" 和 "asofDate" 。"$$NOW" 用来获取当前最新时间。
具体输出如下:
```json
    { "_id" : 1, "item" : "butter", "amount" : 20, "status" : "Complete", "asofDate" : ISODate("2021-12-29T07:08:13.401Z") }
    { "_id" : 3, "item" : "jam", "amount" : 50, "status" : "Complete", "asofDate" : ISODate("2021-12-29T07:08:13.401Z") }
    { "_id" : 4, "item" : "muffins", "amount" : 50, "status" : "Complete", "asofDate" : ISODate("2021-12-29T07:08:13.401Z") }
```

### 具体示例 - 顶层根对象

`$mergeObjects` 的作用就是往指定的每个字段对象中添加其他的嵌入式字段。

事实上，每个 collection 中的每条记录，都是一个文档，它可以通过 `$$ROOT` 进行引用。

```sh
    db.contacts.insert([
       { "_id" : 1, name: "Fred", email: "fred@example.net" },
       { "_id" : 2, name: "Frank N. Stine", cell: "012-345-9999" },
       { "_id" : 3, name: "Gren Dell", cell: "987-654-3210", email: "beo@example.net" }
    ]);
```
在 "contacts" 中，`{ "_id" : 1, name: "Fred", email: "fred@example.net" }` 就是一个对象，它可以通过 `$$ROOT` 引用。这样看来，就可以对其使用 `$mergeObjects`:
```sh
    db.contacts.aggregate([
       { $replaceWith: { $mergeObjects: [ { _id: "", name: "", email: "", cell: "", home: "" }, "$$ROOT" ] } }
    ])
```
输出如下:
```json
    { "_id" : 1, "name" : "Fred", "email" : "fred@example.net", "cell" : "", "home" : "" }
    { "_id" : 2, "name" : "Frank N. Stine", "email" : "", "cell" : "012-345-9999", "home" : "" }
    { "_id" : 3, "name" : "Gren Dell", "email" : "beo@example.net", "cell" : "987-654-3210", "home" : "" }
```
