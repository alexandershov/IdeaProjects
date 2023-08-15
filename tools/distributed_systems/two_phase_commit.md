## Two-phase commit 

Two-phase commit (2pc) allows to atomically commit/rollback distributed 
transaction on several nodes.

It's a simple consensus protocol, that's not that great when failures occur. 

Client tells us to do a distributed transaction.
Coordinator node generates transaction id, prepares data, and sends the data
to the worker nodes. (Coordinator node can be any node, it's not important).

Then coordinator node asks each node if it can commit this transaction.
If any node answers "no", then coordinator cancels transaction on each node.

If all nodes answer "yes", then coordinator commits transaction on each node.

If node answers "yes", then it should be able to commit this transaction always, after
answering "yes" node can't say "I changed my mind" later.

In a case of coordinator node failure we wait when it becomes available again.
In a case of worker node failure we also wait.

With all this waiting, it's possible to create not very responsive transactions, if we're not
careful.