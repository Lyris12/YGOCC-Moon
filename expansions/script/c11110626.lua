--Lifeweaver's Destination
--Destinazione della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Return 1 "Lifeweaver" Time Leap Monster you control to your Extra Deck, and if you do, Special Summon 1 "Lifeweaver" Time Leap with the same Future
	but a different Attribute from your Extra Deck, ignoring the Time Leap Limit. (This is treated as a Time Leap Summon.)]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON)
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
function s.tdfilter(c,e,tp,nocheck)
	return c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsAbleToExtra()
		and (nocheck or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,cc,c:GetFuture(),c:GetAttribute()))
end
function s.spfilter(c,e,tp,cc,fut,attr)
	return c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsFuture(fut) and c:GetAttribute()~=attr
		and Duel.GetLocationCountFromEx(tp,tp,cc,c) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_TODECK,false,tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,false)
	if #g<=0 then
		g=Duel.Select(HINTMSG_TODECK,false,tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,true)
	end
	if #g>0 then
		local tc=g:GetFirst()
		local fut,attr = tc:GetFuture(),tc:GetAttribute()
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and aux.PLChk(tc,tp,LOCATION_EXTRA) then
			local sg=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil,fut,attr)
			if #sg>0 and Duel.SpecialSummon(sg,SUMMON_TYPE_TIMELEAP,tp,tp,false,false,POS_FACEUP)>0 then
				sg:GetFirst():CompleteProcedure()
			end
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