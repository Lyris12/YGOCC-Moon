--[[
Perfect ZERO
ZERO Perfetto
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_POWER_VACUUM_BLADE,CARD_POWER_VACUUM_ZONE,CARD_VACUOUS_ARCHFIEND)
	--[[While you control "Power Vacuum Blade", "Power Vacuum Zone", and "Vacuous Archfiend", and your opponent has not taken any battle or effect damage from a card(s) you own previously this turn:
	Banish as many cards from your opponent's field and GY as possible, face-down, then if your opponent has 30 or more banished cards, your opponent loses LP equal to the number of their banished
	cards x 150. Also, immediately after this effect resolves, if your opponent's LP is 1000 or lower, their LP becomes 0, or if they control a face-up monster that was Summoned from the Extra Deck
	using 4 or more materials, their LP becomes 1, instead.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(
		s.condition,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_DAMAGE)
		ge:SetOperation(s.regop)
		Duel.RegisterEffect(ge,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if ec and r&(REASON_BATTLE|REASON_EFFECT)>0 and ec:IsOwner(1-ep) and not Duel.PlayerHasFlagEffect(ep,id) then
		Duel.RegisterFlagEffect(ep,id,RESET_PHASE|PHASE_END,0,1,0)
	end
end

--E1
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.PlayerHasFlagEffect(1-tp,id)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil,CARD_POWER_VACUUM_BLADE)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil,CARD_POWER_VACUUM_ZONE)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil,CARD_VACUOUS_ARCHFIEND)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
	if chk==0 then
		return #g>0
	end
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,100000373,RESET_PHASE|PHASE_END,0,1)
	local g=Duel.Group(aux.Necro(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)>0 then
		local ct=Duel.GetBanishmentCount(1-tp)
		if ct>=30 then
			Duel.BreakEffect()
			Duel.LoseLP(1-tp,ct*150)
		end
	end
	aux.ApplyEffectImmediatelyAfterResolution(s.lpop,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp,_e,isChainEnd)
	if Duel.GetLP(1-tp)<=1000 then
		local lp=Duel.IsExists(false,s.lpfilter,tp,0,LOCATION_MZONE,1,nil) and 1 or 0
		Duel.SetLP(1-tp,lp,LP_REASON_BECOME)
	end
end
function s.lpfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:GetMaterialCount()>=4
end