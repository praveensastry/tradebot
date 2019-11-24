package trade

// Ideally, this should be configurable
// through CLI / config maps
const noProfit int = 0

func CalculateMaxProfit(arr []int) int {
	// when there are less than two prices to calculate profit
	// This will be handled by route handler but still
	// included it as a defensive strateegy
	if len(arr) < 2 {
		return noProfit
	}

	var maxDiff = arr[1] - arr[0]

	// minimum number visited so far
	var minElement = arr[0]

	for i := 1; i < len(arr); i++ {
		// re-calculate max diff
		if arr[i]-minElement > maxDiff {
			maxDiff = arr[i] - minElement
		}

		// update when new min is found
		if arr[i] < minElement {
			minElement = arr[i]
		}
	}

	// when there is no profit
	if maxDiff < 0 {
		return noProfit
	}

	return maxDiff
}
