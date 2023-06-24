--Lifeweaver's Emancipation
--Emancipazione della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Banish 1 "Lifeweaver" monster you control or in your GY; Special Summon 1 Future 3 "Lifeweaver" Time Leap Monster from your Extra Deck. (This is treated as a Time Leap Summon.)]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[During your Main Phase, if you control a Future 4 "Lifeweaver" Time Leap Monster: You can shuffle this card into your Deck, and if you do, Set 1 "Lifeweaver" Spell from your GY.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
--FILTERS E1
function s.rmfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsMonster() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsAbleToRemoveAsCost() and Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,c,e,tp,c)
end
function s.spfilter(c,e,tp,cc)
	return c:IsMonster(TYPE_TIMELEAP) and c:IsFuture(3) and c:IsSetCard(ARCHE_LIFEWEAVER)
		and Duel.GetLocationCountFromEx(tp,tp,cc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false)
end
--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.Banish(g,nil,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if #g>0 and Duel.SpecialSummon(g,SUMMON_TYPE_TIMELEAP,tp,tp,false,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end

--FILTERS E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsFuture(4)
end
function s.setfilter(c)
	return c:IsSpell() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsSSetable()
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