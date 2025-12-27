
两种语句多集合操作时执行耗时相同。

lookup:
```js
db.lit_orders.aggregate([
	{
		$lookup: {
			from: "lit_transactions",
			localField: "id",
			foreignField: "reqId",
			as: "lit_transactions"
		}
	},
	{
		$unwind: "$lit_transactions"
	},
	{
		$match: {
			$and: [
				{ symbol: { $in: [603217, 887, 2743, 600768] } },
				{ status: { $in: [4, 7] } }
			]
		}
	},
	{
		$sort: {
			submitTime: 1,
			modify_time: -1,
			"lit_transactions.id": 1
		}
	},
	{
		$project: {
			_id: 0,
			id: 1,
			symbol: 1,
			status: 1,
			submitTime: 1,
			modify_time: 1,
			"lit_transactions.id": 1
		}
	}
])
```

graphLookup:
```js
db.lit_orders.aggregate([
	{
		$graphLookup: {
			from: "lit_transactions",
			startWith: "$id",
			connectFromField: "reqId",
			connectToField: "reqId",
			as: "lit_transactions"
		}
	},
	{
		$unwind: "$lit_transactions"
	},
	{
		$match: {
			$and: [
				{ symbol: { $in: [603217, 887, 2743, 600768] } },
				{ status: { $in: [4, 7] } }
			]
		}
	},
	{
		$sort: {
			submitTime: 1,
			modify_time: -1,
			"lit_transactions.id": 1
		}
	},
	{
		$project: {
			_id: 0,
			id: 1,
			symbol: 1,
			status: 1,
			submitTime: 1,
			modify_time: 1,
			"lit_transactions.id": 1
		}
	}
])
```

将上面的 lit_orders 和 lit_transactions 导入到同一个集合 lit_mixed_coll 中，然后再同一个集合上进行操作，也能得到相同的结果集:
```js
db.lit_mixed_coll.aggregate([
	{
		$graphLookup: {
			from: "lit_mixed_coll",
			startWith: "$id",
			connectFromField: "id",
			connectToField: "reqId",
			as: "lit_transactions"
		}
	},
	{
		$unwind: "$lit_transactions"
	},
	{
		$match: {
			$and: [
				{ symbol: { $in: [603217, 887, 2743, 600768] } },
				{ status: { $in: [4, 7] } }
			]
		}
	},
	{
		$sort: {
			submitTime: 1,
			modify_time: -1,
			"lit_transactions.id": 1
		}
	},
	{
		$project: {
			_id: 0,
			id: 1,
			symbol: 1,
			status: 1,
			submitTime: 1,
			modify_time: 1,
			"lit_transactions.id": 1
		}
	}
])
```
