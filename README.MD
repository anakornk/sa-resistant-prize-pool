# Sybil Attack Resistant Prize Pool

Prize pool is the total amount of money that is distributed among the winners in a tournament. A popular way of distributing the prize is by distributing the total amount of money to each winners equally. This means that each winners will receive the same amount of money regardless of the order they win. In systems where identities can be easily created, like in a blockchain system where a random number (private key) represents an identity, an attacker can do sybil attacks to get higher profits. 

For instance, let's take a simple question game as an example. There is a question Q with its corresponding answer A. Players who know A can submit in the answer and get a portion of the total prize P. Assume that there is a total of N winners, each winners will receive P/N. An attacker, who currently receive P/N, can create X more identities and for each submit in the answer to get a whole total profit of P(1 + X)/(N + X) which is larger than P/N. The higher the X value, the higher the attacker's profit.

In order to prevent sybil attacks, we designed a prize pool distribution algorithm which disincentivize attackers from creating multiple identities. The main concept here is that if a attacker decides to create a new identity, the total profit he'll earn by doing so should be less than before.

---
## Proof


---
## Algorithm