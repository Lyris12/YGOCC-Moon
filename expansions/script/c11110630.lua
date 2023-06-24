--Lifeweaver's Familiarity
--Familiarità della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Special Summon up to 2 of your "Lifeweaver" monsters that are banished and/or in your GY, but banish them during the End Phase.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
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
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_GB,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GB)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetMZoneCount(tp)
	if ft<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GB,0,1,math.min(2,ft),nil,e,tp)
	if #g>0 then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
			end
		end
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
		local e1=Effect.CreateEffect(c)
		e1:SetCustomCategory(0,CATEGORY_FLAG_DELAYED_RESOLUTION)
		e1:SetCheatCode(CHEATCODE_SET_CHAIN_ID,false,cid)
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(s.rmcon)
		e1:SetOperation(s.rmop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.rmfilter(c,fid)
	return c:HasFlagEffectLabel(id,fid)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else
		return true
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.rmfilter,nil,e:GetLabel()):Filter(Card.IsAbleToRemove,nil)
	if #tg>0 then
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
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