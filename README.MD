# Sybil Attack Resistant Prize Pool

Prize pool is the total amount of money that is distributed among the winners in a tournament. A popular way of distributing the prize is by distributing the total amount of money to each winner equally. This means that each winner will receive the same amount of money regardless of the order they win. In systems where identities can be easily created, like in a blockchain system where a random number (private key) represents an identity, an attacker can do sybil attacks to get higher profits. 

For instance, let's take a simple question game as an example. There is a question Q with its corresponding answer A. Players who know A can submit in the answer and get a portion of the total prize P. Assume that there is a total of N winners, each winner will receive P/N. An attacker, who currently receive P/N, can create X more identities and for each submit in the answer to get a whole total profit of P(1 + X)/(N + X) which is larger than P/N. The higher the X value, the higher the attacker's profit.

In order to prevent sybil attacks, we designed a prize pool distribution algorithm which disincentivize attackers from creating multiple identities. The main concept here is that if an attacker decides to create a new identity, the total profit he'll earn by doing so should be less than before.

## Algorithm
To disincentivize attackers from doing sybil attacks, our algorithm lessen the prize per share according to the number of winners. 
Let 
1. function f(x) returns the total prize for when the number of winners equal to x. 
2. function PPS(x) returns the prize per share, which equals to f(x)/x.

For any PPS(x) that satisfies the condition below, we can guarantee that an attacker will gain less profit if he decides to create a new identity and use it to join the winners group.
```
PPS(x) < INITIAL_PRIZE_POOL_VALUE / 2^(x-1)
```

Example:

```
PPS(x) = INITIAL_PRIZE_POOL_VALUE / 2^(x-1) - 1
f(x) = x*PPS(x) = x(INITIAL_PRIZE_POOL_VALUE / 2^(x-1) - 1)
```


## Proof
Assume
1. Function f(x) returns the total prize amount when N equals x  
2. Current number of winners equal n
3. An attacker has x winner identities. x is greater than 0 and less than or equal to n.
4. PPS(x) equals to f(x)/x.


|  |  |  |  |  | | | |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Number of Winners (N)| 1 | 2 | 3 | 4 | ... | n-1 | n | 
| Total Prize (P) | f(1) | f(2) | f(3) | f(4) | ... | f(n-1) | f(n) |
| Prize per Share (PPS=P/N) | f(1)/1 | f(2)/2 | f(3)/3 | f(4)/4 | ... | f(n-1)/(n-1) | f(n)/n |

To disincentivize an attacker from creating a new identity, he should earn less profit if he chose to do so. Hence, PPS(x) should satisfy the condition below.

```
∀x ∈ [1, n-1]
xPPS(n) > (x+1)PPS(n+1)

=>

∀x ∈ [1, n-1]
x / (x+1) > PPS(n+1) / PPS(n)

=>

∀x ∈ [1, n-1]
x / (x+1) > PPS(2) / PPS(1)     [1]
x / (x+1) > PPS(3) / PPS(2)     [2]
x / (x+1) > PPS(4) / PPS(3)   [3]
...
x / (x+1) > PPS(n) / PPS(n-1)       [n-1]

By multiplying equation [1], [2], [3] ,..., [n-1] together, we can get:
(x/(x+1))^(n-1) > PPS(n) / PPS(1)

=>

∀x ∈ [1, n-1]
(x/(x+1))^(n-1) > PPS(n) / PPS(1)

=>

(1/2)^(n-1) > PPS(n) / PPS(1)       [1]
(2/3)^(n-1) > PPS(n) / PPS(1)       [2]
(3/4)^(n-1) > PPS(n) / PPS(1)       [3]
....
It is obvious that if equation [1] is true, equation [2],...[n-1] will also be true.

=> 

(1/2)^(n-1) * PPS(1) > PPS(n)

=>

PPS(n) < PPS(1) * (1/2)^(n-1)
```

## Extra
The above algorithm can be tweaked and applied to situations where the prize pool is not evenly distributed to each winner. (e.g. early winners earn more than late winners)

Assume
1. Function f(x) returns the total prize for when the number of winners equal to x and satisfies the condition below.
```
f(x) < x * f(1) / 2^(x-1)
```

Let function p(X, Y) returns the prize value for the Yth place winner when there are X winners altogether. If Y > X, function p returns 0. If the conditions below are met, an attacker should not have the incentive to do a sybil attack.
```
∀y ∈ [1, n]
p(n, y) <= f(n)/n

p(n, y) > 2*p(n+1, y)
p(n, y) > p(n, y+1)
```

