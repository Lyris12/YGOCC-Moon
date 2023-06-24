--Lifeweaver's Paradise
--Paradiso della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Add 1 "Lifeweaver" monster from your Deck to your hand, and if you do, you can Time Leap Summon 1 "Lifeweaver" monster in addition to your Time Leap Summon during this turn.
	(You can only gain this effect once per turn.)]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If you control a Future 4 "Lifeweaver" Time Leap Monster: You can shuffle this card from your GY into your Deck, and if you do, Set 1 "Lifeweaver" Trap from your GY.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
--FILTERS E1
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsAbleToHand()
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local ct,ht=Duel.Search(g,tp)
		if ct>0 and ht>0 and not Duel.PlayerHasFlagEffect(tp,id) then
			Duel.RegisterHint(tp,id,PHASE_END,1,id,2)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:Desc(3)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_EXTRA_TIMELEAP_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_LIFEWEAVER))
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

--FILTERS E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsFuture(4)
end
function s.setfilter(c)
	return c:IsTrap() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsSSetable()
end
--E2
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
		end
	end
end