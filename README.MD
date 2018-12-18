# Sybil Attack Resistant Prize Pool

Prize pool is the total amount of money that is distributed among the winners in a tournament. A popular way of distributing the prize is by distributing the total amount of money to each winner equally. This means that each winner will receive the same amount of money regardless of the order they win. In systems where identities can be easily created, like in a blockchain system where a random number (private key) represents an identity, an attacker can do sybil attacks to get higher profits. 

For instance, let's take a simple question game as an example. There is a question Q with its corresponding answer A. Players who know A can submit in the answer and get a portion of the total prize P. Assume that there is a total of N winners, each winner will receive P/N. An attacker, who currently receive P/N, can create X more identities and for each submit in the answer to get a whole total profit of P(1 + X)/(N + X) which is larger than P/N. The higher the X value, the higher the attacker's profit.

In order to prevent sybil attacks, we designed a prize pool distribution algorithm which disincentivize attackers from creating multiple identities. The main concept here is that if an attacker decides to create a new identity, the total profit he'll earn by doing so should be less than before.

## Algorithm
To disincentivize attackers from doing sybil attacks, our algorithm lessen the total prize according to the number of winners. 
Let 
1. function f(x) returns the total prize for when the number of winners equal to x. 
2. function PPS(x) returns the prize per share, which equals to f(x)/x.

For any PPS(x) that satisfies the condition below, we can guarantee that an attacker will gain less profit if he decides to create a new identity and use it to join the winners group.
```
PPS(x) > 2*PPS(x+1)
```
We can compute f(x) as below
```
f(x) = x*PPS(x)
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
∀x ∈ [1, n]
xPPS(n) > (x+1)PPS(n+1)

=>

∀x ∈ [1, n]
x / (x+1) > PPS(n+1) / PPS(n)

=>

1 / 2 > PPS(n+1) / PPS(n)           [1]
2 / 3 > PPS(n+1) / PPS(n)           [2]
3 / 4 > PPS(n+1) / PPS(n)           [3]
....
It is obvious that if equation [1] is true, equation [2],...[n] will also be true.

=> 

1 / 2 > PPS(n+1) / PPS(n)           [1]

=>

PPS(n) > 2*PPS(n+1)
```

## Example
Let's find a valid PPS function. First we solve PPS(x) = 2*PPS(x+1)
```
1 / 2 =  PPS(2) / PPS(1)        [1]
1 / 2 =  PPS(3) / PPS(2)        [2]
1 / 2 =  PPS(4) / PPS(3)        [3]
...
1 / 2 =  PPS(x) / PPS(x-1)      [x-1]

By multiplying equation [1], [2], [3] ,..., [x-1] together, we can get:
(1/2)^(x-1) = PPS(x) / PPS(1)

==>

PPS(x) = PPS(1) / 2^(x-1)
```

Minus the above PPS by a positive constant C to make sure that `PPS(x) > 2*PPS(x+1)` is always true.
Hence, we get 
```
PPS(x) = [PPS(1) / 2^(x-1)] - C
```

To make sure that `PPS(x) > 2*PPS(x+1)` always return true. Let's put the new PPS into the recursive function.
```
PPS(x) > 2*PPS(x+1)

===>

[PPS(1) / 2^(x-1)] - C > (2 *PPS(1) / 2^(x)) - 2C

===>

2*PPS(1) - 2^(x)*C > 2*PPS(1) - 2^(x+1)*C

===>

2^(x)*C > 0

===>

true
```

Summary:  

We have now proved that 
```
PPS(x) = [PPS(1) / 2^(x-1)] - C
```
satisfies the requirement to be sybil resistant.

We can compute f(x) as follows
```
f(x) = x*PPS(x) = x([PPS(1) / 2^(x-1)] - C)
```


## Extra
The above algorithm can be tweaked and applied to situations where the prize pool is not evenly distributed to each winner. (e.g. early winners earn more than late winners)

Let function p(X, Y) returns the prize value for the Yth place winner when there are X winners altogether. If Y > X, function p returns 0. If the conditions below are met, an attacker should not have the incentive to do a sybil attack.

Assume there are currrently n winners.
```
∀y ∈ [1, n],
p(n, y) > 2*p(n+1, y)

p(n+1, n) >= p(n+1, n+1)
```