package trade

import (
	"testing"
)

func TestStandardInput(t *testing.T) {
	prices := []int{10, 7, 5, 8, 11, 9}
	res := CalculateMaxProfit(prices)
	if res != 6 {
		t.Fail()
	}
}

func TestEmptyPrices(t *testing.T) {
	prices := []int{}
	res := CalculateMaxProfit(prices)
	if res != 0 {
		t.Fail()
	}
}

func TestDescreasingPricees(t *testing.T) {
	prices := []int{10, 9, 8, 7, 5}
	res := CalculateMaxProfit(prices)
	if res != 0 {
		t.Fail()
	}
}

func TestIncreasingPrices(t *testing.T) {
	prices := []int{1, 2, 3, 4, 5, 6}
	res := CalculateMaxProfit(prices)
	if res != 5 {
		t.Fail()
	}
}

func TestEqualPrices(t *testing.T) {
	prices := []int{6, 6, 6, 6, 6, 6, 6, 6}
	res := CalculateMaxProfit(prices)
	if res != 0 {
		t.Fail()
	}
}

func TestSinglePrices(t *testing.T) {
	prices := []int{1}
	res := CalculateMaxProfit(prices)
	if res != 0 {
		t.Fail()
	}
}

func TestTwoPrices(t *testing.T) {
	prices := []int{1, 2}
	res := CalculateMaxProfit(prices)
	if res != 1 {
		t.Fail()
	}
}

func TestZeroValuedPrices(t *testing.T) {
	prices := []int{1, 0, 3}
	res := CalculateMaxProfit(prices)
	if res != 3 {
		t.Fail()
	}
}
