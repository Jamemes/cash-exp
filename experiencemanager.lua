local function offshore_rate_exp(val)
	return math.round(val * managers.money:get_tweak_value("money_manager", "offshore_rate"))
end

local data = ExperienceManager.get_xp_dissected
function ExperienceManager:get_xp_dissected(success, num_winners, personal_win)
	local _, tbl = data(self, success, num_winners, personal_win)
	local cash_exp = game_state_machine:current_state_name() ~= "gameoverscreen" and managers.job:on_last_stage() and offshore_rate_exp(managers.money:get_potential_payout_from_current_stage()) or 0
	for id, value in pairs(tbl) do
		if type(value) == "number" and id ~= "stage_xp" then
			tbl[id] = 0
		else
			tbl[id] = cash_exp
		end
	end

	return cash_exp, tbl
end

local data = ExperienceManager.get_contract_xp_by_stars
function ExperienceManager:get_contract_xp_by_stars(job_id, job_stars, risk_stars, professional, job_days, extra_params)
	local total_payout_min, base_payout, risk_payout = managers.money:get_contract_money_by_stars(job_stars, risk_stars, job_days, job_id)
	local _, tbl = data(self, job_id, job_stars, risk_stars, professional, job_days, extra_params)

	for id, _ in pairs(tbl) do
		tbl[id] = 0
	end

	tbl[1] = offshore_rate_exp(type(risk_payout) == "table" and risk_payout[1] or base_payout)
	tbl[2] = offshore_rate_exp(type(risk_payout) == "table" and risk_payout[3] or risk_payout)
	return offshore_rate_exp(total_payout_min), tbl
end