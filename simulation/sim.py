import random
import matplotlib.pyplot as plt

# Initial reserves
reserveA = 1000
reserveB = 1000

FEE = 0.003

# Users
LPs = [{"A": 1000, "B": 1000} for _ in range(5)]
traders = [{"A": 500, "B": 500} for _ in range(8)]

N = 90  # number of transactions

# Metrics
prices = []
tvls = []
slippages = []

def get_price():
    return reserveB / reserveA

def get_amount_out(amount_in, reserve_in, reserve_out):
    amount_in_with_fee = amount_in * (1 - FEE)
    return (reserve_out * amount_in_with_fee) / (reserve_in + amount_in_with_fee)

for t in range(N):

    actor_type = random.choice(["LP", "TRADER"])

    # ---------------- LP ACTION ----------------
    if actor_type == "LP":
        lp = random.choice(LPs)

        action = random.choice(["add", "remove"])

        if action == "add" and lp["A"] > 0 and lp["B"] > 0:
            amountA = random.uniform(0, lp["A"] * 0.1)
            amountB = (amountA * reserveB) / reserveA

            lp["A"] -= amountA
            lp["B"] -= amountB

            reserveA += amountA
            reserveB += amountB

        elif action == "remove":
            share = random.uniform(0, 0.05)

            amountA = reserveA * share
            amountB = reserveB * share

            reserveA -= amountA
            reserveB -= amountB

            lp["A"] += amountA
            lp["B"] += amountB

    else:
        trader = random.choice(traders)

        direction = random.choice(["AtoB", "BtoA"])

        if direction == "AtoB" and trader["A"] > 0:
            amountA = random.uniform(0, min(trader["A"], 0.1 * reserveA))

            expected_price = reserveB / reserveA

            amountB = get_amount_out(amountA, reserveA, reserveB)

            actual_price = amountB / amountA
            slippage = (actual_price - expected_price) / expected_price * 100

            trader["A"] -= amountA
            trader["B"] += amountB

            reserveA += amountA
            reserveB -= amountB

            slippages.append(slippage)

        elif direction == "BtoA" and trader["B"] > 0:
            amountB = random.uniform(0, min(trader["B"], 0.1 * reserveB))

            expected_price = reserveA / reserveB

            amountA = get_amount_out(amountB, reserveB, reserveA)

            actual_price = amountA / amountB
            slippage = (actual_price - expected_price) / expected_price * 100

            trader["B"] -= amountB
            trader["A"] += amountA

            reserveB += amountB
            reserveA -= amountA

            slippages.append(slippage)

    price = get_price()
    tvl = reserveA + (reserveB * price)

    prices.append(price)
    tvls.append(tvl)

# PLOTS

plt.figure()
plt.plot(prices)
plt.title("Spot Price over Time")
plt.xlabel("Transaction")
plt.ylabel("Price (B per A)")
plt.savefig("price.png")

plt.figure()
plt.plot(tvls)
plt.title("TVL over Time")
plt.xlabel("Transaction")
plt.ylabel("Total Value Locked")
plt.savefig("tvl.png")

plt.figure()
plt.plot(slippages)
plt.title("Slippage over Time (%)")
plt.xlabel("Swap Index")
plt.ylabel("Slippage (%)")
plt.savefig("slippage.png")

print("Simulation complete. Graphs saved.")