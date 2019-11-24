package api

import (
	"encoding/json"
	"net/http"

	"github.com/praveensastry/tradebot/pkg/trade"
)

type Payload struct {
	Prices []int `json:"prices"`
}

// Trade godoc
// @Summary Trade
// @Description Calculates the Max profit from given prices for a share
// @Tags HTTP API
// @Param prices body int true "Array on prices"
// @Router /trade/profit [post]
// @Success 200 {object} api.MapResponse
func (s *Server) tradeHandler(w http.ResponseWriter, r *http.Request) {
	payload := Payload{}

	err := json.NewDecoder(r.Body).Decode(&payload)
	if err != nil {
		s.ErrorResponse(w, r, err.Error(), http.StatusBadRequest)
		return
	}

	// validate payload

	if len(payload.Prices) < 2 {
		s.ErrorResponse(w, r, "Require atleast 2 prices to calculate profit", http.StatusBadRequest)
	} else if checkForInvalidPrices(payload.Prices) {
		s.ErrorResponse(w, r, "Invalid values for prices.", http.StatusBadRequest)
	} else {
		profit := trade.CalculateMaxProfit(payload.Prices)

		result := map[string]int{
			"Max Profit": profit,
		}

		s.JSONResponse(w, r, result)
	}
}

func checkForInvalidPrices(prices []int) bool {
	for _, price := range prices {
		if price < 0 {
			return true
		}
	}

	return false
}
